//
//  ViewController.m
//  ZHCustomNavController
//
//  Created by Zinkham on 16/3/29.
//  Copyright © 2016年 Zinkham. All rights reserved.
//

#import "ViewController.h"
#import "NewViewController.h"
#import "ChangeViewController.h"
#import "NormalViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *bgView;
    NSArray *data;
}

@end

@implementation ViewController

-(void)dealloc
{
    NSLog(@"release class:%@",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"main view controller";
    self.view.backgroundColor = [UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1];
    self.zh_showCustomNav = YES;
    
    data = @[@"default nav", @"change default nav", @"new nav"];
    bgView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64,  self.view.frame.size.width, self.view.frame.size.height-64)];
    bgView.delegate = self;
    bgView.dataSource =self;
    bgView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    bgView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:bgView];
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
    if (indexPath.row == 0) {
        NormalViewController *test = [[NormalViewController alloc] init];
        [self.navigationController pushViewController:test animated:YES];
    } else if (indexPath.row == 1) {
        ChangeViewController *test = [[ChangeViewController alloc] init];
        [self.navigationController pushViewController:test animated:YES];
    } else if (indexPath.row == 2) {
        NewViewController *test = [[NewViewController alloc] init];
        [self.navigationController pushViewController:test animated:YES];
    }
}

@end
