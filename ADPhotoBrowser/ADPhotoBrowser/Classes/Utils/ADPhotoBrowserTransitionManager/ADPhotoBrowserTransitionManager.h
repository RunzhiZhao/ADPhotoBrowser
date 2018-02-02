//
//  ADPhotoBrowserTransitionManager.h
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/26.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ADPhotoBrowserTransitionType) {
    ADPhotoBrowserTransitionTypePresent,
    ADPhotoBrowserTransitionTypeDismiss
};

@interface ADPhotoBrowserTransitionManager : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) ADPhotoBrowserTransitionType transitionType;

@property (nonatomic, strong) UIImageView *originView;

@property (nonatomic, assign) CGRect originFrame;

+ (instancetype)transitionWithType:(ADPhotoBrowserTransitionType)transitionType;


@end
