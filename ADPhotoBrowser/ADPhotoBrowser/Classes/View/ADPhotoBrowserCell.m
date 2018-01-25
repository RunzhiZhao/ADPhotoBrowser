//
//  ADPhotoBrowserCollectionViewCell.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
/**
 *  1.单击双击的响应需要设置双击的优先级
 *  2.scrollView的panGestureRecognizer在某些情况不走began方法，哭，记录起始点要换个方式了...
 */

#import "ADPhotoBrowserCell.h"
#import "UIView+ADExtension.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"

@interface ADPhotoBrowserCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;


@property (nonatomic, strong) UIImageView *moveImageView;

@end

static CGRect ad_mMainImageViewOriginFrame;
static BOOL hasBeganPan;        // 记录拖拽状态是否第一次（为了首次操作不可向上滑的实现）
static CGPoint originCenter;    // 图片的初始中心点

@implementation ADPhotoBrowserCell

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}


#pragma mark - Lifecycle
- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetViews];
}


#pragma mark - Private
- (void)commonInit {
    // UI
    [self.contentView addSubview:self.contentScrollView];
    [self.contentScrollView addSubview:self.mainImageView];
    // 添加手势
    [self addGestureRecognizer:self.singleTap];
    [self addGestureRecognizer:self.doubleTap];
    [self.mainImageView addGestureRecognizer:self.panGesture];
}

- (void)resetViews {
    
    if (!self.mainImageView.image) {
        return;
    }
    
    // 拖拽状态初始化
    hasBeganPan = NO;
    
    // 重置scrollView当前缩放比例，使每次图片复位
    self.contentScrollView.zoomScale = 1;
    
    CGSize imageSize = self.mainImageView.image.size;
    
    // 计算图片水平方向和竖直方向的缩放比例
    float xRate = self.contentScrollView.ad_width / imageSize.width;
    float yRate = self.contentScrollView.ad_height / imageSize.height;
    
    // 根据图片宽高比跟屏幕宽高比，设置imageView的size
    if (xRate > yRate) {
        // imageSize 缩放比例按yRate计算，高满屏
        self.mainImageView.ad_height = self.ad_height;
        self.mainImageView.ad_width = self.ad_width / xRate;
    } else {
        // imageSize 缩放比例按xRate计算，宽满屏
        self.mainImageView.ad_width = self.ad_width; // imageSize.width * xRate
        self.mainImageView.ad_height = imageSize.height * xRate;
    }
    
    // 图片居中
    self.mainImageView.center = self.contentScrollView.center;
    self.mainImageView.hidden = NO;
    
    // 设置scrllView的contentSize
    self.contentScrollView.contentSize = CGSizeMake(self.mainImageView.ad_width, self.mainImageView.ad_height);
}

- (void)panEnded {
    if (!_moveImageView) {
        return;
    }
    
    CGPoint velocity = [self.panGesture velocityInView:self.contentView];
    CGPoint location = [self.panGesture locationInView:self.contentView];
    CGPoint translation = [self.panGesture translationInView:self.contentView];
    // 触发条件: 1.滑动至屏幕底部20的距离; 2.速度快且有一定距离
    BOOL shouldDismiss = (location.y >= self.contentView.ad_height - 20) || (velocity.y > 500 && translation.y > 60);
    
// Todo: 判断是否需要推出界面
    if (!shouldDismiss) {
        // 达不到推出的条件，复位
        [UIView animateWithDuration:0.25 animations:^{
            self.moveImageView.frame = ad_mMainImageViewOriginFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.mainImageView.hidden = NO;
                    [_moveImageView removeFromSuperview];
                    _moveImageView = nil;
                    hasBeganPan = NO;
                });
            }
        }];
        if (self.delegate && [self.delegate respondsToSelector:@selector(shouldChangeAlpha: animate:)]) {
            [self.delegate shouldChangeAlpha:1.0 animate:YES];
        }
    }
    // 界面需要推出
    else {
        // 对moveImageView的操作，可加动画之类的
        if (self.delegate && [self.delegate respondsToSelector:@selector(shouldChangeAlpha: animate:)]) {
            [self.delegate shouldChangeAlpha:0.0 animate:YES];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.moveImageView removeFromSuperview];
            _moveImageView = nil;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserDidDownDragToDismiss)]) {
                [self.delegate photoBrowserDidDownDragToDismiss];
            }
        });
        
    }
}

#pragma mark - UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    // 让图片保持居中
    CGFloat offsetX = (scrollView.ad_width > scrollView.contentSize.width)?
    (scrollView.ad_width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.ad_height > scrollView.contentSize.height)?
    (scrollView.ad_height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.mainImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                            scrollView.contentSize.height * 0.5 + offsetY);
}


#pragma mark - Action

- (void)singleTapAction:(UITapGestureRecognizer *)sender {
    // 传递给controller
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellShouldPerformSingleTap:)]) {
        [self.delegate cellShouldPerformSingleTap:self];
    }
}

// 双击事件，zoomScale的处理
- (void)doubleTapAction:(UITapGestureRecognizer *)sender {
    // 已经放大的复原，否则放大
    if (self.contentScrollView.zoomScale > 1.0) {
        [self.contentScrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint location = [sender locationInView:self.contentScrollView];
        [self.contentScrollView zoomToRect:CGRectMake(location.x, location.y, 1, 1) animated:YES];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)sender {
    
    // 相对cell的拖拽偏移量
    CGPoint translation = [sender translationInView:self.contentView];
    
    // 一开始向上滑动不进行操作
    if (!hasBeganPan && translation.y < 0) {
        return;
    }
    // 标记正在滑动
    hasBeganPan = YES;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // 记录图片起始中心点
        ad_mMainImageViewOriginFrame = [self.contentScrollView convertRect:self.mainImageView.frame toView:self.contentView];
        
        // 记录图片起始中心点
        ad_mMainImageViewOriginFrame = [self.contentScrollView convertRect:self.mainImageView.frame toView:self.contentView];
        
        originCenter = self.mainImageView.center;
        self.mainImageView.hidden = YES;
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        // scrollView的偏移量
        CGFloat offsetX = self.contentScrollView.contentOffset.x;
        CGFloat offsetY = self.contentScrollView.contentOffset.y;
        
        // 根据滑动的方向和距离，显示移动的图片视图，并改变背景色
        CGFloat alpha = translation.y > 0 ? MAX((1 - translation.y / (self.contentScrollView.ad_height * 0.6)), 0.0) : 1.0;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(shouldChangeAlpha:animate:)]) {
            [self.delegate shouldChangeAlpha:alpha animate:NO];
        }
        
        // 移动图片的缩放
        CGFloat scale = translation.y > 0 ? (1.0 - translation.y / self.contentScrollView.ad_height) : 1;
        self.moveImageView.ad_height = self.mainImageView.ad_height * scale;
        self.moveImageView.ad_width = self.mainImageView.ad_width * scale;
        // 移动图片的中心点
        CGPoint center = [self.contentScrollView convertPoint:originCenter toView:self.contentView];
        self.moveImageView.center = CGPointMake(center.x + offsetX + translation.x, center.y + translation.y + offsetY);
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        // 拖拽结束
        [self panEnded];
    }
}


#pragma mark - setter
- (void)setImageURLString:(NSString *)imageURLString {
    _imageURLString = imageURLString;
    
    __weak typeof(self) weakSelf = self;
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakSelf resetViews];
    }];
}


#pragma mark - getter

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
    }
    return _singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        _doubleTap.numberOfTapsRequired = 2;
    }
    return _doubleTap;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _panGesture.maximumNumberOfTouches = 1;
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        // scrollView用于存放图片，支持手势
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        scrollView.maximumZoomScale = 3.0f;
        scrollView.minimumZoomScale = 1.0f;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.alwaysBounceHorizontal = NO;
        scrollView.alwaysBounceVertical = NO;
        scrollView.scrollEnabled = NO;
        _contentScrollView = scrollView;
    }
    return _contentScrollView;
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        [imgView sd_addActivityIndicator];
        _mainImageView = imgView;
    }
    return _mainImageView;
}

- (UIImageView *)moveImageView {
    if (!_moveImageView) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:self.mainImageView.image];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.frame = [self.contentScrollView convertRect:self.mainImageView.frame toView:self.contentView];
        [self.contentView addSubview:imgView];
        _moveImageView = imgView;
    }
    return _moveImageView;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // velocity.x != 0 表示左右滑动，会与collectionView冲突，不给响应
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)gestureRecognizer;
        if ([panGR velocityInView:self.contentView].x != 0) {
            return NO;
        }
    }
    return YES;
}

@end
