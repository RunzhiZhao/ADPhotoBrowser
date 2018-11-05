//
//  ADPhotoBrowserViewController.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import "ADPhotoBrowserViewController.h"
#import "ADPhotoBrowserTransitionManager.h"
#import "ADPhotoBrowserCell.h"
#import "UIView+ADExtension.h"

@interface ADPhotoBrowserViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, ADPhotoBrowserCellDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) ADPhotoBrowserTransitionManager *transitionManager;

@end

@implementation ADPhotoBrowserViewController

static NSString * const ADPhotoBrowserCellID = @"ADPhotoBrowserCell";

#pragma mark - Init
+ (instancetype)photoBrowserViewWithDelegate:(id<ADPhotoBrowserViewControllerDelegate>)delegate {
    ADPhotoBrowserViewController *vc = [[ADPhotoBrowserViewController alloc] init];
    vc.transitioningDelegate = vc;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.delegate = delegate;
    return vc;
}


#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configViews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 复原collectionView
    [self resetCollectionView];
}

- (void)dealloc {
    NSLog(@"ADPhotoBrowserViewController  - dealloc");
}


#pragma mark - UICollectionView delegate & dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageURLStringArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ADPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ADPhotoBrowserCellID forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ((ADPhotoBrowserCell *)cell).imageURLString = self.imageURLStringArray[indexPath.item];
}


#pragma mark - ADPhotoBrowserCellDelegate

- (void)cellShouldPerformSingleTap:(ADPhotoBrowserCell *)cell {
    // 拿到当前图片的frame和image, 进行转场动画
    self.originImageView = cell.mainImageView;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cellShouldPerformLongPress:(ADPhotoBrowserCell *)cell {
    // 长按弹出选项栏
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserViewController:shouldPerformLongPressAtImageView:)]) {
        [self.delegate photoBrowserViewController:self shouldPerformLongPressAtImageView:cell.mainImageView];
    }
}

// 拖拽进度回调，更改透明度
- (void)shouldChangeAlpha:(CGFloat)alpha animate:(BOOL)animate {
    self.collectionView.scrollEnabled = NO;
    if (animate) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
        }];
    } else {
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    }
}

// 结束拖拽回调
- (void)photoBrowserDidEndDragMovingView:(UIImageView *)moveImageView dismiss:(BOOL)dismiss {
    
    self.collectionView.scrollEnabled = YES;
    
    // dismiss
    if (dismiss) {
        self.originImageView = moveImageView;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // change alpha
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        }];
    }
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.transitionManager.transitionType = ADPhotoBrowserTransitionTypePresent;
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.transitionManager.transitionType = ADPhotoBrowserTransitionTypeDismiss;
    return self.transitionManager;
}


#pragma mark - Private

- (void)configViews {
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
}

- (void)resetCollectionView {
    
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - Action


#pragma mark - setter
- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _currentIndex = currentIndex;
}

- (void)setOriginImageView:(UIImageView *)originImageView {
    _originImageView = originImageView;
    self.transitionManager.originView = originImageView;
}

- (void)setImageURLStringArray:(NSArray *)imageURLStringArray {
    _imageURLStringArray = [imageURLStringArray copy];
}


#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(self.view.ad_width, self.view.ad_height);
        flowLayout.minimumLineSpacing = CGFLOAT_MIN;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
        collectionView.alwaysBounceVertical = NO;
        collectionView.pagingEnabled = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerClass:[ADPhotoBrowserCell class] forCellWithReuseIdentifier:ADPhotoBrowserCellID];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (ADPhotoBrowserTransitionManager *)transitionManager {
    if (!_transitionManager) {
        ADPhotoBrowserTransitionManager *transition = [[ADPhotoBrowserTransitionManager alloc] init];
        _transitionManager = transition;
    }
    return _transitionManager;
}

@end
