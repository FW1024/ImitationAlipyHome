//
//  ViewController.m
//  AlipayHomeDemo
//
//  Created by FW on 2017/10/9.
//  Copyright © 2017年 FW. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import "HomeNavView.h"
#import "HomeItemView.h"
#import "UIView+ViewFrameGeometry.h"

#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define kScreen_Height [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (nonatomic , strong) UITableView * tableView;

@property (nonatomic , strong) HomeItemView * itemView;

@property (nonatomic , strong) HomeNavView * navView;

@property (nonatomic , strong) UIView * coverView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _navView = [[[NSBundle mainBundle] loadNibNamed:@"HomeNavView" owner:self options:nil] firstObject];
    [self.view addSubview:_navView];
    [_navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.equalTo(@64);
    }];
    
    [self createTable];
    
    _itemView = [[[NSBundle mainBundle] loadNibNamed:@"HomeItemView" owner:self options:nil] lastObject];
    _itemView.frame = CGRectMake(0, -155, kScreen_Width, 95);
    [_tableView addSubview:_itemView];
    
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, -60, kScreen_Width, 60)];
    _coverView.backgroundColor = [UIColor grayColor];
    [_tableView addSubview:_coverView];
}

- (void)createTable
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 80.0f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(64, 0, 0, 0));
        }];
        _tableView.contentInset = UIEdgeInsetsMake(155, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(155, 0, 0, 0);
        MJRefreshStateHeader * mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_tableView.mj_header endRefreshing];
            });
        }];
        mj_header.ignoredScrollViewContentInsetTop = 60;
        _tableView.mj_header = mj_header;
    }
}

#pragma mark - tableViewDelegate + dataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"UITableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"indexPath - row:%ld",indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.01)];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.01)];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > -155 && offsetY <= -60)
    {
        if (offsetY + 65 <= -45)
        {
            [scrollView setContentOffset:CGPointMake(0, -155) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0, -65) animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY <= -155)
    {
        _itemView.top = offsetY;
        _itemView.alphView.alpha = 1;
        _navView.merchantName.alpha = 1;
        _navView.alphView.alpha = 0;
    }
    else
    {
        
        if (offsetY <= -65)
        {
            CGFloat scale = 65.0 / 155.0;
            _itemView.top = offsetY * scale - 90;
            if (offsetY + 65 <= -45)
            {
                CGFloat alpha = - (offsetY + 65 + 45) / 45.0;
                _navView.merchantName.alpha = alpha;
                _navView.alphView.alpha = 0;
            }
            else
            {
                CGFloat alpha = 1 + (offsetY + 65) / 45.0;
                _navView.alphView.alpha = alpha;
                _navView.merchantName.alpha = 0;
            }
            
            CGFloat alpha = -(offsetY + 65) / 90.0;
            _itemView.alphView.alpha = alpha;
        }
        else
        {
            _itemView.alphView.alpha = 0;
            _navView.alphView.alpha = 1;
            _navView.merchantName.alpha = 0;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
