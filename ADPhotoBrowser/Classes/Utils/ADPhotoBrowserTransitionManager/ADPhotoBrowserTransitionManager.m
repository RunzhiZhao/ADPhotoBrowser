//
//  ADPhotoBrowserTransitionManager.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/26.
//

#import "ADPhotoBrowserTransitionManager.h"
#import "UIView+ADExtension.h"



@implementation ADPhotoBrowserTransitionManager

#pragma mark - Init
+ (instancetype)transitionWithType:(ADPhotoBrowserTransitionType)transitionType {
    ADPhotoBrowserTransitionManager *transition = [[ADPhotoBrowserTransitionManager alloc] init];
    return transition;
}


#pragma mark - Private
- (void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    __block UIView *containerView = [transitionContext containerView];
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // 1.画布添加目标控制器视图
    toVC.view.alpha = 0;
    toVC.view.frame = CGRectMake(0, 0, containerView.ad_width, containerView.ad_height);
    [containerView addSubview:toVC.view];
    [UIView animateWithDuration:0.2 animations:^{
        toVC.view.alpha = 1;
    }];
    
    // 2.如果是点击图片视图进来的给个放大动画
    if (self.originView && self.originView.image) {
        UIView *animateView = [self.originView snapshotViewAfterScreenUpdates:NO];
        // 记录frame初始值
        self.originFrame = [fromVC.view convertRect:self.originView.frame toView:containerView];
        animateView.frame = self.originFrame;
        [containerView addSubview:animateView];
        
        // get target size
        CGFloat targetWidth = 0.0f, targetHeight = 0.0f;
        CGSize imageSize = self.originView.image.size;
        
        // 计算图片水平方向和竖直方向的缩放比例
        float xRate = toVC.view.ad_width / imageSize.width;
        float yRate = toVC.view.ad_height / imageSize.height;
        
        // 根据图片宽高比跟屏幕宽高比，设置imageView的size
        if (xRate > yRate) {
            // imageSize 缩放比例按yRate计算，高满屏
            targetHeight = toVC.view.ad_height;
            targetWidth = imageSize.width / yRate;
        } else {
            // imageSize 缩放比例按xRate计算，宽满屏
            targetWidth = toVC.view.ad_width; // imageSize.width * xRate
            targetHeight = imageSize.height * xRate;
        }
        
        // 执行动画
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.0f/[self transitionDuration:transitionContext] options:UIViewAnimationOptionCurveEaseInOut animations:^{
            animateView.ad_width = targetWidth;
            animateView.ad_height = targetHeight;
            animateView.center = CGPointMake(containerView.ad_width/2.0, containerView.ad_height/2.0);
        } completion:^(BOOL finished) {
            [animateView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    } else {
        [transitionContext completeTransition:YES];
    }
}

- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    __block UIView *containerView = [transitionContext containerView];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // 1.隐藏源视图, 使用透明度动画
    fromVC.view.alpha = 1;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.alpha = 0;
    }];

    // 2.如果是点击图片视图，给复位动画
    if (self.originView && self.originView.image) {
        UIView *animateView = [self.originView snapshotViewAfterScreenUpdates:NO];
        animateView.frame = [fromVC.view convertRect:self.originView.frame toView:containerView];
        [containerView addSubview:animateView];
        self.originView.hidden = YES;
        
        // 执行动画
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.0f/[self transitionDuration:transitionContext] options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromVC.view.alpha = 0;
            animateView.frame = self.originFrame;
        } completion:^(BOOL finished) {
            [animateView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
        
    } else {
        [transitionContext completeTransition:YES];
    }
}


#pragma mark - setter



#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionType == ADPhotoBrowserTransitionTypePresent) {
        // present
        [self presentAnimateTransition:transitionContext];
    } else if (self.transitionType == ADPhotoBrowserTransitionTypeDismiss) {
        // dismiss
        [self dismissAnimateTransition:transitionContext];
    }
}

@end
