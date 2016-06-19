//
//  ViewController.m
//  05-相册
//
//  Created by qingyun on 16/5/10.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "ViewController.h"

#define QYScreenW [UIScreen mainScreen].bounds.size.width
#define QYScreenH [UIScreen mainScreen].bounds.size.height
#define ImageViewCount 6
@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;     //滚动的scrollView
@property (nonatomic) NSInteger currentPage;                      //将要开始拖动的时候,当前页码
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.在self.view上添加滚动的scrollView
    [self addScrollView];
    //2.在滚动的scrollView上添加三个缩放的scrollView
    [self addZoomScrollViewForScrollView];
    
    // Do any additional setup after loading the view, typically from a nib.
}
//添加滚动的scrollView
-(void)addScrollView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, QYScreenW + 25.0, QYScreenH)];
    [self.view addSubview:scrollView];
    //设置背景颜色
    scrollView.backgroundColor = [UIColor blackColor];
    //设置contentSize
    scrollView.contentSize = CGSizeMake((QYScreenW + 25.0) * ImageViewCount, QYScreenH);
    //分页
    scrollView.pagingEnabled = YES;
    //设置代理
    scrollView.delegate = self;
    
    _scrollView = scrollView;
}

//在滚动的scrollView上添加个缩放的scrollView
-(void)addZoomScrollViewForScrollView{
    for (int i = 0; i < ImageViewCount; i++) {
        //添加缩放的scrollView
        UIScrollView *zoomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((QYScreenW + 25.0) * i, 0, QYScreenW, QYScreenH)];
        [_scrollView addSubview:zoomScrollView];
        
        //在缩放的scrollView上添加imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:zoomScrollView.bounds];
        [zoomScrollView addSubview:imageView];
        //设置图片
        NSString *imageName = [NSString stringWithFormat:@"new_feature_%d",i + 1];
        imageView.image = [UIImage imageNamed:imageName];
        imageView.tag = 1001;
        
        //设置zoomScrollView的缩放比例范围
        zoomScrollView.maximumZoomScale = 2.0;
        zoomScrollView.minimumZoomScale = 0.3;
        //设置代理
        zoomScrollView.delegate = self;
        
        //添加双击
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        
        tap.numberOfTapsRequired = 2;
        
        [zoomScrollView addGestureRecognizer:tap];
    }
}
//双击
-(void)doubleClick:(UITapGestureRecognizer *)tap{
    UIScrollView *zoomScrollView = (UIScrollView *)tap.view;
    //1.当前zoomScrollView的zoomScale不为1.0,置为1.0
    if (zoomScrollView.zoomScale != 1.0) {
        [zoomScrollView setZoomScale:1.0 animated:YES];
        return;
    }
    //2.当前zoomScrollView的zoomScale为1.0,放大
    CGPoint point = [tap locationInView:zoomScrollView];
    CGRect rect = CGRectMake(point.x - 100, point.y - 100, 200, 200);
    [zoomScrollView zoomToRect:rect animated:YES];
}

#pragma mark  -UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _scrollView) {
        _currentPage = scrollView.contentOffset.x / (QYScreenW + 25.0);
    }
}

//减速完成的时候,把所有的zoomScrollView的zoomScale重置为1.0
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //判断当前的scrollView是滚动的scrollView的时候,需要把所有的zoomScrollView的内容视图缩放比例置为1.0
    if (scrollView == _scrollView) {
        
        if (_currentPage == scrollView.contentOffset.x / (QYScreenW + 25.0)) {
            return;
        }
        
        [scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIScrollView class]]) {
                UIScrollView *zoomScrollView = (UIScrollView *)obj;
                zoomScrollView.zoomScale = 1.0;
            }
        }];
    }
}

//指定缩放视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    //判断当前的scrollView是滚动的scrollView的时候,需要return
    if (scrollView == _scrollView) {
        return nil;
    }
    //判断当前的scrollView是zoomScrollView时候,找到对应的imageView
    UIImageView *imageView = [scrollView viewWithTag:1001];
    return imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
