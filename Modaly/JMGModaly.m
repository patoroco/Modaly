/*
 
 Copyright (c) 2014 Jorge Maroto García ( http://maroto.me )
 
 Permission is hereby granted, free of charge, to any
 person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the
 Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the
 Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice
 shall be included in all copies or substantial portions of
 the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
 KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
 OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#define JMGInvertSides(rect) CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width)

#import "JMGModaly.h"

@interface JMGModaly ()

@property (nonatomic) CGRect presentingViewControllerFrame;
@property (nonatomic) CGRect presentedViewControllerFrame;
@property (nonatomic, strong) UIView *shadow;
@property (nonatomic) BOOL modalPanelIsPresented;

@end


@implementation JMGModaly

- (void)perform
{
    UIViewController *vcs = self.sourceViewController;
    UIViewController *vcd = self.destinationViewController;
    
    self.presentedViewControllerFrame = [self topDestinationViewController].view.frame;
    self.presentingViewControllerFrame = vcs.view.frame;
    
    vcd.transitioningDelegate = self;
    vcd.modalPresentationStyle = UIModalPresentationCustom;
    [vcs presentViewController:vcd animated:YES completion:self.presentBlock];
    
    vcd.view.frame = self.presentedViewControllerFrame;
}


#pragma mark - Animation

#pragma mark UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}


#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}


- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *presentingViewController = nil;
    UIViewController *modalViewController = nil;
    UIView *container = [transitionContext containerView];
    
    CGAffineTransform transform;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) &&
        [[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"fixedCoordinateSpace")] == NO)
    {
        NSInteger sign = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ? 1 : -1;
        transform = CGAffineTransformMakeTranslation(sign * container.bounds.size.width, 0);
    } else {
        transform = CGAffineTransformMakeTranslation(0, container.bounds.size.height);
    }
    
    if (!self.modalPanelIsPresented) {
        presentingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        modalViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [presentingViewController viewWillDisappear:YES];
        [modalViewController viewWillAppear:YES];
        
        self.shadow = [[UIView alloc] initWithFrame:container.bounds];
        self.shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.shadow.alpha = 0;
        [self.shadow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        
        [container addSubview:self.shadow];
        [container addSubview:modalViewController.view];
        
        if (self.fullScreen == YES) {
            modalViewController.view.bounds = container.bounds;
        }
        modalViewController.view.bounds = CGRectIntegral(modalViewController.view.bounds); // This line fix blurry effect with partial pixels.
        
        modalViewController.view.center = container.center;
        
        if ([[self class] needsRotateSides]) {
            modalViewController.view.bounds = JMGInvertSides(modalViewController.view.bounds);
        }
        
        modalViewController.view.transform = CGAffineTransformConcat(modalViewController.view.transform, transform);
        
        [presentingViewController viewWillDisappear:YES];
        [modalViewController viewWillAppear:YES];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.shadow.alpha = 1;
            modalViewController.view.transform = CGAffineTransformConcat(modalViewController.view.transform, CGAffineTransformInvert(transform));
        } completion:^(BOOL finished) {
            self.modalPanelIsPresented = YES;
            [presentingViewController viewDidDisappear:YES];
            [modalViewController viewDidAppear:YES];
            [transitionContext completeTransition:YES];
        }];
    } else {
        presentingViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        modalViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        if (self.respectPresentingViewControllerFrame) {
            presentingViewController.view.frame = self.presentingViewControllerFrame;
        }
        
        presentingViewController.view.center = container.center;
        
        [presentingViewController viewWillAppear:YES];
        [modalViewController viewWillDisappear:YES];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.shadow.alpha = 0;
            modalViewController.view.transform = CGAffineTransformConcat(modalViewController.view.transform, transform);
        } completion:^(BOOL finished) {
            self.modalPanelIsPresented = NO;
            [presentingViewController viewDidAppear:YES];
            [modalViewController viewDidDisappear:YES];
            [transitionContext completeTransition:YES];
            if (self.dismissBlock != nil) {
                self.dismissBlock();
            }
        }];
    }
    
}


#pragma mark - Gesture callbacks

- (void)tap:(UITapGestureRecognizer *)gesture
{
    [(UIViewController *)self.destinationViewController dismissViewControllerAnimated:YES completion:^{
        [(UIViewController *)self.destinationViewController setTransitioningDelegate:nil];
        
        if (self.dismissBlock != nil) {
            self.dismissBlock();
        }
    }];
}


#pragma mark - Convenience methods

- (UIViewController *)topDestinationViewController
{
    UIViewController *vcd = self.destinationViewController;
    
    if ([vcd isKindOfClass:[UINavigationController class]]) {
        vcd = [[(UINavigationController *)vcd viewControllers] firstObject];
    } else if ([vcd isKindOfClass:[UITabBarController class]]) {
        vcd = [(UITabBarController *)vcd selectedViewController];
    }
    
    return vcd;
}

/**
 Sides should be changed (width <-> height) before iOS8
 @return YES if should change width by height
 */
+ (BOOL)needsRotateSides
{
    return (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) &&
            [[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"fixedCoordinateSpace")] == NO);
}

@end