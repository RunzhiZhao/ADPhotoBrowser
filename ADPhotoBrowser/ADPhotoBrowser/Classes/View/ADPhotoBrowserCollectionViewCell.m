//
//  ADPhotoBrowserCollectionViewCell.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import "ADPhotoBrowserCollectionViewCell.h"
#import "UIView+ADExtension.h"
#import "UIImageView+WebCache.h"

@implementation ADPhotoBrowserCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    scrollView.maximumZoomScale = 3.0f;
    scrollView.delegate = self;
    [self.contentView addSubview:scrollView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imgView];
    
    self.contentScrollView = scrollView;
    self.mainImageView = imgView;
}

- (void)setImageURLString:(NSString *)imageURLString {
    _imageURLString = imageURLString;
    
    __weak typeof(self) weakSelf = self;
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            [weakSelf setupViewsWithImageSize:image.size];
        }
    }];
}

- (void)setupViewsWithImageSize:(CGSize)imageSize {
    float xRate = self.contentScrollView.ad_width / self.mainImageView.ad_width;
    float yRate = self.contentScrollView.ad_height / self.mainImageView.ad_height;
    self.contentScrollView.minimumZoomScale = MIN(MIN(xRate, yRate), 1);
    
    CGFloat rate = imageSize.height / imageSize.width;
    if (rate > self.ad_height/self.ad_width) {
        self.mainImageView.ad_height = self.ad_height;
        self.mainImageView.ad_width = self.ad_height / rate;
    } else {
        self.mainImageView.ad_width = self.ad_width;
        self.mainImageView.ad_height = self.ad_width * rate;
    }
    self.mainImageView.center = self.contentScrollView.center;
    self.contentScrollView.contentSize = CGSizeMake(self.mainImageView.ad_width, self.mainImageView.ad_height);
}

#pragma mark - UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 刷新contentSize
    scrollView.contentSize = CGSizeMake(self.mainImageView.ad_width, self.mainImageView.ad_height);
    // 让图片保持居中
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.mainImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {

}

@end
