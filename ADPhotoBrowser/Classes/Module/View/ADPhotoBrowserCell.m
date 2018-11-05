//
//  ADPhotoBrowserCollectionViewCell.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
/**
 *  1.单击双击的响应需要设置双击的优先级
 *  2.scrollView的panGestureRecognizer在某些情况不走stateBegan状态，哭，记录起始点要换个方式了...
 */

#import "ADPhotoBrowserCell.h"
#import "UIView+ADExtension.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"

@interface ADPhotoBrowserCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, strong) UIImageView *moveImageView;

@end

static CGRect mMainImageViewOriginFrame;
static BOOL panning;        // 记录拖拽状态是否第一次（为了首次操作不可向上滑的实现）
static CGPoint originCenter;    // 图片的初始中心点
static CGPoint originLocation;  // 移动手势初始点

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
    [self addGestureRecognizer:self.longPress];
}

- (void)resetViews {
    
    if (!self.mainImageView.image) {
        return;
    }
    
    if (_moveImageView) {
        [_moveImageView removeFromSuperview];
        _moveImageView = nil;
    }
    
    // 拖拽状态初始化
    panning = NO;
    
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
        self.mainImageView.ad_width = imageSize.width * yRate;
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


#pragma mark - Pan Action
- (void)panBegan {
    CGPoint velocity = [self.contentScrollView.panGestureRecognizer velocityInView:self.contentView];
    
    // 向下拖拽的判定条件：1.向下; 2.图片显示了顶部
    // 允许20像素的偏差，也可以设置为0不允许偏差
    if (velocity.y > 0 && self.contentScrollView.contentOffset.y <= 20) {
        // 标记状态
        panning = YES;
        // 记录图片初始frame
        mMainImageViewOriginFrame = [self.contentScrollView convertRect:self.mainImageView.frame toView:self.contentView];
        // 记录图片初始center
        originCenter = [self.contentScrollView convertPoint:self.mainImageView.center toView:self.contentView];
        // 记录收拾初始location
        originLocation = [self.contentScrollView.panGestureRecognizer locationInView:self.contentView];
        
        self.mainImageView.hidden = YES;
    }
}

- (void)panChange {
    CGPoint location = [self.contentScrollView.panGestureRecognizer locationInView:self.contentView];
    CGPoint translation = [self.contentScrollView.panGestureRecognizer translationInView:self.contentView];
    
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
    self.moveImageView.center = CGPointMake(location.x - (originLocation.x - originCenter.x) * scale, location.y - (originLocation.y - originCenter.y) * scale);
}

- (void)panEnded {
    if (!_moveImageView) {
        return;
    }
    // 拖拽手势状态：结束
    panning = NO;
    
    CGPoint velocity = [self.contentScrollView.panGestureRecognizer velocityInView:self.contentView];
    CGPoint location = [self.contentScrollView.panGestureRecognizer locationInView:self.contentView];
    CGPoint translation = [self.contentScrollView.panGestureRecognizer translationInView:self.contentView];
    
    // 触发条件: 1.滑动至屏幕底部20的距离; 2.速度快且有一定距离
    BOOL shouldDismiss = (location.y >= self.contentView.ad_height - 20) || (velocity.y > 300 && translation.y > 50);
    
    // 判断是否需要推出界面
    if (!shouldDismiss) {
        // 达不到推出的条件，复位
        [UIView animateWithDuration:0.25 animations:^{
            self.moveImageView.frame = mMainImageViewOriginFrame;
        } completion:nil];
    }
    
    // 回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserDidEndDragMovingView:dismiss:)]) {
        [self.delegate photoBrowserDidEndDragMovingView:self.moveImageView dismiss:shouldDismiss];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 开始拖拽
    [self panBegan];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 正在拖拽
    if (panning) {
        [self panChange];
    } else {
        // 图片高度比屏幕小，不允许向上滑动
        CGPoint velocity = [self.contentScrollView.panGestureRecognizer velocityInView:self.contentView];
        if (self.mainImageView.ad_height < self.contentView.ad_height && velocity.y <= 0 && scrollView.panGestureRecognizer.numberOfTouches == 1) {
            [self.contentScrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // 结束拖拽
    [self panEnded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 在scrollView完全停止滑动，mainImageView完全复位的时候可以无缝切换显示
    self.mainImageView.hidden = NO;
    if (_moveImageView) {
        [_moveImageView removeFromSuperview];
        _moveImageView = nil;
    }
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

// 长按手势事件
- (void)longPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        // 传递给controller
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellShouldPerformLongPress:)]) {
            [self.delegate cellShouldPerformLongPress:self];
        }
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

- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    }
    return _longPress;
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
        scrollView.alwaysBounceVertical = YES;
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


@end
