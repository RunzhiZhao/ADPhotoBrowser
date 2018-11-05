//
//  ADViewController.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 01/24/2018.
//  Copyright (c) 2018 Runzhi.Zhao. All rights reserved.
//

#import "ADViewController.h"
#import "ADPhotoBrowserViewController.h"
#import <UIImageView+WebCache.h>
#import <UIView+ADExtension.h>

@interface ADViewController ()<ADPhotoBrowserViewControllerDelegate>

//@property (nonatomic, strong) ADPhotoBrowserViewController *browserVC;

@property (nonatomic, strong) NSArray *images;

@end

@implementation ADViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 200, 200)];
    imgView.userInteractionEnabled = YES;
    [imgView sd_setImageWithURL:[NSURL URLWithString:self.images[0]]];
    [self.view addSubview:imgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [imgView addGestureRecognizer:tap];
}

- (void)tapImageView:(UITapGestureRecognizer *)sender {
    ADPhotoBrowserViewController *browser = [self browserVC];
    browser.originImageView = (UIImageView *)sender.view;
    [self presentViewController:browser animated:YES completion:nil];
}

- (ADPhotoBrowserViewController *)browserVC {
    //    if (!_browserVC) {
    ADPhotoBrowserViewController *browserVC = [ADPhotoBrowserViewController photoBrowserViewWithDelegate:self];
    browserVC.imageURLStringArray = self.images;
    browserVC.currentIndex = 0;
    browserVC.delegate = self;
    //    }
    return browserVC;
}

- (void)photoBrowserViewController:(ADPhotoBrowserViewController *)controller shouldPerformLongPressAtImageView:(UIImageView *)imageView {
    NSLog(@"long press");
}

#pragma mark - getter

- (NSArray *)images {
    if (!_images) {
        _images = @[
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801112228&di=e7882af21f9c60c15f18daf83f7feabd&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D7e378409b1a1cd1111bb7a60d06aad90%2Fe7cd7b899e510fb389cf17aed233c895d1430c30.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801152764&di=71d32e1595c7699430147cab650450de&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D735bc4ee3dd12f2eda08a62026bab00e%2F48540923dd54564e9aef4100b8de9c82d1584f04.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801112228&di=e7882af21f9c60c15f18daf83f7feabd&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D7e378409b1a1cd1111bb7a60d06aad90%2Fe7cd7b899e510fb389cf17aed233c895d1430c30.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801152764&di=71d32e1595c7699430147cab650450de&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D735bc4ee3dd12f2eda08a62026bab00e%2F48540923dd54564e9aef4100b8de9c82d1584f04.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801112228&di=e7882af21f9c60c15f18daf83f7feabd&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D7e378409b1a1cd1111bb7a60d06aad90%2Fe7cd7b899e510fb389cf17aed233c895d1430c30.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801152764&di=71d32e1595c7699430147cab650450de&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D735bc4ee3dd12f2eda08a62026bab00e%2F48540923dd54564e9aef4100b8de9c82d1584f04.jpg"
                    ];
    }
    return _images;
}

@end
