//
//  NormalViewController.m
//  ZHCustomController
//
//  Created by Zinkham on 16/3/30.
//  Copyright © 2016年 Zinkham. All rights reserved.
//

#import "NormalViewController.h"

@interface NormalViewController ()

@end

@implementation NormalViewController

-(void)dealloc
{
    NSLog(@"release class:%@",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"default nav";
    self.view.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    self.zh_showCustomNav = YES;
}

@end
