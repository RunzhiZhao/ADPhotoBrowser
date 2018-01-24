//
//  ADPhotoBrowserViewController.h
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import <UIKit/UIKit.h>

@class ADPhotoBrowserViewController;

@protocol ADPhotoBrowserViewControllerDelegate <NSObject>

- (void)didSomething;

@end

@interface ADPhotoBrowserViewController : UIViewController

+ (instancetype)photoBrowserViewWithDelegate:(id<ADPhotoBrowserViewControllerDelegate>)delegate;


@property (nonatomic, weak) id <ADPhotoBrowserViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *imageURLStringArray;

@end
