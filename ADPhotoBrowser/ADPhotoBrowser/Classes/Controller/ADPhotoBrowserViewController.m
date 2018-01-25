//
//  ADPhotoBrowserViewController.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import "ADPhotoBrowserViewController.h"
#import "ADPhotoBrowserCell.h"
#import "UIView+ADExtension.h"

@interface ADPhotoBrowserViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, ADPhotoBrowserCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ADPhotoBrowserViewController

NSString * const ADPhotoBrowserCellID = @"ADPhotoBrowserCell";

#pragma mark - Init
+ (instancetype)photoBrowserViewWithDelegate:(id<ADPhotoBrowserViewControllerDelegate>)delegate {
    ADPhotoBrowserViewController *vc = [[ADPhotoBrowserViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.delegate = delegate;
    return vc;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configViews];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private

- (void)configViews {
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
}


#pragma mark - Action


#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(self.view.ad_width, self.view.ad_height);
        flowLayout.minimumLineSpacing = CGFLOAT_MIN;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.alwaysBounceVertical = NO;
        collectionView.pagingEnabled = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        [collectionView registerClass:[ADPhotoBrowserCell class] forCellWithReuseIdentifier:ADPhotoBrowserCellID];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}



@end
