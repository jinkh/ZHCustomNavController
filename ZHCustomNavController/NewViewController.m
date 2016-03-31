//
//  NewViewController.m
//  ZHCustomController
//
//  Created by Zinkham on 16/3/30.
//  Copyright © 2016年 Zinkham. All rights reserved.
//

#import "NewViewController.h"

@interface NewViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *bgView;
    NSArray *data;
}

@end

@implementation NewViewController

-(void)dealloc
{
    NSLog(@"release class:%@",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    
    //new nav
    UIImageView *navView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 63)];
    navView.backgroundColor = self.view.backgroundColor;
    //navView.image = [UIImage imageNamed:@"nav_bg"];
    navView.contentMode = UIViewContentModeScaleAspectFill;
    navView.userInteractionEnabled = YES;
    navView.layer.masksToBounds = YES;
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 44, 44)];
    backBtn.backgroundColor = [UIColor clearColor];
    backBtn.contentMode = UIViewContentModeCenter;
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20 , [UIScreen mainScreen].bounds.size.width-100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont systemFontOfSize:18];  //设置文本字体与大小
    titleLabel.textColor = [UIColor blackColor];  //设置文本颜色
    titleLabel.textAlignment = UIBaselineAdjustmentAlignCenters;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.text = @"new nav, not defalut";
    [navView addSubview:titleLabel];
    self.zh_customNav = navView;
    self.zh_showCustomNav = YES;
    self.zh_autoDisplayCustomNav = YES;
    
    CGFloat navHeight = self.zh_customNav.frame.size.height;
    data = @[@"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test", @"test"];
    bgView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,  self.view.frame.size.width, self.view.frame.size.height)];
    bgView.contentInset = UIEdgeInsetsMake(navHeight, 0, 0, 0);
    bgView.delegate = self;
    bgView.dataSource = self;
    bgView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:bgView];
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    self.zh_customNav.alpha = 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [data objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
