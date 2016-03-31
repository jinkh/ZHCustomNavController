//
//  ChangeViewController.m
//  ZHCustomController
//
//  Created by Zinkham on 16/3/30.
//  Copyright © 2016年 Zinkham. All rights reserved.
//

#import "ChangeViewController.h"
#import "ViewController.h"

@interface ChangeViewController ()

@end

@implementation ChangeViewController

-(void)dealloc
{
    NSLog(@"release class:%@",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"change the default nav";
    self.view.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    self.zh_showCustomNav = YES;
    UIButton *jump = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 20, 44, 44)];
    jump.backgroundColor = [UIColor clearColor];
    [jump setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [jump setTitle:@"jump" forState:UIControlStateNormal];
    [jump addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.zh_customNav addSubview:jump];
}

-(void)jumpAction:(id)sender
{
    ViewController *test = [[ViewController alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}

@end
