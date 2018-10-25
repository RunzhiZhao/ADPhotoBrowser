//
//  UIView+ADExtension.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import "UIView+ADExtension.h"

@implementation UIView (ADExtension)

#pragma mark - setter

- (void)setAd_x:(CGFloat)ad_x {
    CGRect frame = self.frame;
    frame.origin.x = ad_x;
    self.frame = frame;
}

- (void)setAd_y:(CGFloat)ad_y {
    CGRect frame = self.frame;
    frame.origin.y = ad_y;
    self.frame = frame;
}

- (void)setAd_width:(CGFloat)ad_width {
    CGRect frame = self.frame;
    frame.size.width = ad_width;
    self.frame = frame;
}

- (void)setAd_height:(CGFloat)ad_height {
    CGRect frame = self.frame;
    frame.size.height = ad_height;
    self.frame = frame;
}


#pragma mark - getter
- (CGFloat)ad_x {
    return self.frame.origin.x;
}

- (CGFloat)ad_y {
    return self.frame.origin.y;
}

- (CGFloat)ad_width {
    return self.frame.size.width;
}

- (CGFloat)ad_height {
    return self.frame.size.height;
}



@end
