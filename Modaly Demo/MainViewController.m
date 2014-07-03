//
//  MainViewController.m
//  Modaly
//
//  Created by Jorge Maroto García on 03/07/14.
//  Copyright (c) 2014 Jorge Maroto García. All rights reserved.
//

#import "MainViewController.h"
#import "JMGModaly.h"

@interface MainViewController ()

    @property (nonatomic, strong) JMGModaly *modalSegue;

@end

@implementation MainViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue isKindOfClass:[JMGModaly class]]) {
        self.modalSegue = (JMGModaly *)segue;
    }
}

@end
