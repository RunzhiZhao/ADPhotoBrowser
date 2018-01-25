//
//  ADPhotoBrowserCollectionViewCell.h
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import <UIKit/UIKit.h>

@class ADPhotoBrowserCell;
@protocol ADPhotoBrowserCellDelegate <NSObject>

- (void)cellShouldPerformSingleTap:(ADPhotoBrowserCell *)cell;

@end

@interface ADPhotoBrowserCell : UICollectionViewCell<UIScrollViewDelegate>

@property (nonatomic, copy) NSString *imageURLString;

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) UIImageView *mainImageView;

@property (nonatomic, weak) id <ADPhotoBrowserCellDelegate> delegate;

@end
