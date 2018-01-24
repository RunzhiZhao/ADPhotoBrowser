//
//  ADViewController.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 01/24/2018.
//  Copyright (c) 2018 Runzhi.Zhao. All rights reserved.
//

#import "ADViewController.h"
#import "ADPhotoBrowserViewController.h"

@interface ADViewController ()<ADPhotoBrowserViewControllerDelegate>

@property (nonatomic, strong) ADPhotoBrowserViewController *browserVC;

@end

@implementation ADViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(100, 100, 60, 30);
        [btn setTitle:@"show" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    })];
}

- (void)buttonAction:(UIButton *)sender {
    [self presentViewController:self.browserVC animated:YES completion:nil];
}

- (ADPhotoBrowserViewController *)browserVC {
    if (!_browserVC) {
        _browserVC = [ADPhotoBrowserViewController photoBrowserViewWithDelegate:self];
        _browserVC.imageURLStringArray = @[
                                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801112228&di=e7882af21f9c60c15f18daf83f7feabd&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D7e378409b1a1cd1111bb7a60d06aad90%2Fe7cd7b899e510fb389cf17aed233c895d1430c30.jpg",
                                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801152764&di=71d32e1595c7699430147cab650450de&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D735bc4ee3dd12f2eda08a62026bab00e%2F48540923dd54564e9aef4100b8de9c82d1584f04.jpg",
                                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801112228&di=e7882af21f9c60c15f18daf83f7feabd&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D7e378409b1a1cd1111bb7a60d06aad90%2Fe7cd7b899e510fb389cf17aed233c895d1430c30.jpg",
                                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801152764&di=71d32e1595c7699430147cab650450de&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D735bc4ee3dd12f2eda08a62026bab00e%2F48540923dd54564e9aef4100b8de9c82d1584f04.jpg",
                                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801112228&di=e7882af21f9c60c15f18daf83f7feabd&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D7e378409b1a1cd1111bb7a60d06aad90%2Fe7cd7b899e510fb389cf17aed233c895d1430c30.jpg",
                                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516801152764&di=71d32e1595c7699430147cab650450de&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3D735bc4ee3dd12f2eda08a62026bab00e%2F48540923dd54564e9aef4100b8de9c82d1584f04.jpg"
                                           ];
    }
    return _browserVC;
}

- (void)didSomething {
    
}

@end
