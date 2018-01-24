//
//  ADPhotoBrowserViewController.m
//  ADPhotoBrowser
//
//  Created by Runzhi.Zhao on 2018/1/24.
//

#import "ADPhotoBrowserViewController.h"
#import "ADPhotoBrowserCollectionViewCell.h"
#import "UIView+ADExtension.h"

@interface ADPhotoBrowserViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ADPhotoBrowserViewController

NSString * const ADPhotoBrowserCollectionViewCellID = @"ADPhotoBrowserCollectionViewCell";

#pragma mark - Init

+ (instancetype)photoBrowserViewWithDelegate:(id<ADPhotoBrowserViewControllerDelegate>)delegate {
    ADPhotoBrowserViewController *vc = [[ADPhotoBrowserViewController alloc] init];
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
    ADPhotoBrowserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ADPhotoBrowserCollectionViewCellID forIndexPath:indexPath];
    cell.imageURLString = self.imageURLStringArray[indexPath.item];
    return cell;
}


#pragma mark - Private

- (void)configViews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
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
        
        [collectionView registerClass:[ADPhotoBrowserCollectionViewCell class] forCellWithReuseIdentifier:ADPhotoBrowserCollectionViewCellID];
        
        _collectionView = collectionView;
    }
    return _collectionView;
}



@end
