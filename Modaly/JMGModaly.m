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

#import "JMGModaly.h"

@interface JMGModaly () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

    @property (nonatomic) CGRect originalSize;
    @property (nonatomic, strong) UIView *shadow;
    @property (nonatomic) BOOL modalPanelIsPresented;

@end


@implementation JMGModaly

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination {
    self = [super initWithIdentifier:identifier source:source destination:destination];
    
    if (self == nil) {
        return nil;
    }
    
    self.originalSize = destination.view.frame;
    
    return self;
}

- (void)perform {
    
    UIViewController *vcs = self.sourceViewController;
    UIViewController *vcd = self.destinationViewController;
    
    if ([vcd isKindOfClass:[UINavigationController class]]) {
        UIViewController *rootViewController = [(UINavigationController *)vcd viewControllers][0];
        self.originalSize = rootViewController.view.frame;
    }
    
    vcd.transitioningDelegate = self;
    vcd.modalPresentationStyle = UIModalPresentationCustom;
    
    [vcs presentViewController:vcd animated:YES completion:nil];
    
    vcd.view.frame = self.originalSize;
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        // Invert bounds when iDevice is on portrait
        vcd.view.bounds = CGRectMake(0, 0, vcd.view.bounds.size.height, vcd.view.bounds.size.width);
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *presentingViewController = nil;
    UIViewController *modalViewController = nil;
    UIView *container = [transitionContext containerView];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(container.bounds.size.width, 0);
    
    if (!self.modalPanelIsPresented) {
        presentingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        modalViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        self.shadow = [[UIView alloc] initWithFrame:container.bounds];
        self.shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.shadow.alpha = 0;
        [self.shadow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        
        [container addSubview:self.shadow];
        [container addSubview:modalViewController.view];
        
        modalViewController.view.center = container.center;
        modalViewController.view.frame = CGRectIntegral(modalViewController.view.frame); // This line fix blurry effect with partial pixels.
        modalViewController.view.transform = CGAffineTransformConcat(modalViewController.view.transform, transform);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.shadow.alpha = 1;
            modalViewController.view.transform = CGAffineTransformConcat(modalViewController.view.transform, CGAffineTransformInvert(transform));
        } completion:^(BOOL finished) {
            self.modalPanelIsPresented = YES;
            [transitionContext completeTransition:YES];
        }];
    } else {
        presentingViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        modalViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.shadow.alpha = 0;
            modalViewController.view.transform = CGAffineTransformConcat(modalViewController.view.transform, transform);
        } completion:^(BOOL finished) {
            self.modalPanelIsPresented = NO;
            [transitionContext completeTransition:YES];
        }];
    }
    
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    [(UIViewController *)self.destinationViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
