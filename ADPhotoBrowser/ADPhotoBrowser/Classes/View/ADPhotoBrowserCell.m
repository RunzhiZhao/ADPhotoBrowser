//
//  ADPhotoBrowserCollectionViewCell.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
/**
 *  1.单击双击的响应需要设置双击的优先级
 *
 */

#import "ADPhotoBrowserCell.h"
#import "UIView+ADExtension.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"

@interface ADPhotoBrowserCell ()

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation ADPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetViews];
}

- (void)commonInit {
    // 添加手势
    [self addGestureRecognizer:self.singleTap];
    [self addGestureRecognizer:self.doubleTap];
    
    // UI
    [self.contentView addSubview:self.contentScrollView];
    [self.contentScrollView addSubview:self.mainImageView];
    
}

- (void)setImageURLString:(NSString *)imageURLString {
    _imageURLString = imageURLString;
    
    __weak typeof(self) weakSelf = self;
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakSelf resetViews];
    }];
}

- (void)resetViews {
    
    if (!self.mainImageView.image) {
        return;
    }
    
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
    // 设置scrllView的contentSize
    self.contentScrollView.contentSize = CGSizeMake(self.mainImageView.ad_width, self.mainImageView.ad_height);
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {

}


#pragma mark - Action

- (void)singleTapAction:(UITapGestureRecognizer *)sender {
    NSLog(@"single tap to dismiss");
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
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.alwaysBounceVertical = YES;
        _contentScrollView = scrollView;
    }
    return _contentScrollView;
}

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [imgView sd_addActivityIndicator];
        _mainImageView = imgView;
    }
    return _mainImageView;
}

@end
