//
//  ADPhotoBrowserCollectionViewCell.h
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import <UIKit/UIKit.h>

@interface ADPhotoBrowserCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>

@property (nonatomic, copy) NSString *imageURLString;

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) UIImageView *mainImageView;

@end
