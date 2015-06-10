//
//  NOStickyCollectionViewController.m
//
//  Created by Yuriy Panfyorov on 29/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "NOStickyCollectionViewController.h"

#import "NOStickyCollectionHeaderView.h"
#import "NOStickyCollectionViewCell.h"
#import "NOAlbum.h"

NSString * const NOStickyCollectionSelectedItemsDidChangeNotification = @"NOStickyCollectionSelectedItemsDidChangeNotification";

#pragma mark -

@interface NOStickyCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic) NSMutableSet *collapsedSections;
@property (nonatomic) NSMutableSet *selectedCells;
@property (nonatomic) NSMutableDictionary *collectionViewHeaders;

@end

@implementation NOStickyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // in nested view controller on iOS 7 automaticallyAdjustsScrollViewInsets doesn't seem to work
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]), 0, 0, 0);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
    
    self.collectionView.allowsMultipleSelection = YES;
    self.selectedCells = [NSMutableSet new];
}

#pragma mark - Public properties

- (NSArray *)indexPathsForSelectedItems
{
    return self.collectionView.indexPathsForSelectedItems;
}

- (void)setAlbums:(NSArray *)albums
{
    if (self.albums && [self.albums isEqualToArray:albums]) return;
    
    _albums = albums;
    
    // assuming that section count and contents may change, reset the collapsed section list
    // 5. По умолчанию открыт первый альбом, остальные свернуты;
    NSMutableSet *collapsedSections = [NSMutableSet new];
    for (NSUInteger i = 1; i < self.albums.count; i++)
    {
        [collapsedSections addObject:@(i)];
    }
    self.collapsedSections = collapsedSections;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.albums.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.collapsedSections containsObject:@(section)])
    {
        return 0;
    }
    
    NOAlbum *album = self.albums[section];
    return album.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NOStickyCollectionViewCell *cell = (NOStickyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"KittenCell" forIndexPath:indexPath];
    if (cell)
    {
        BOOL cellSelected = [self.selectedCells containsObject:indexPath];
        cell.selected = cellSelected;
        if (cellSelected)
        {
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        else
        {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        cell.selectedState = cellSelected;
        
        NOAlbum *album = self.albums[indexPath.section];
        cell.imageURL = album.photos[indexPath.item];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NOStickyCollectionHeaderView *headerView = (NOStickyCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"KittenHEader" forIndexPath:indexPath];
    if (headerView)
    {
        // configure
        NSInteger sectionIndex = [indexPath indexAtPosition:0];
        headerView.sectionIndex = sectionIndex;

        NOAlbum *album = self.albums[sectionIndex];
        headerView.label.text = album.title;
        
        headerView.tap = ^{
            [self toggleSection:sectionIndex];
        };
        
        headerView.collapsedState = [self.collapsedSections containsObject:@(sectionIndex)];
        
        if (self.collectionViewHeaders == nil) self.collectionViewHeaders = [NSMutableDictionary new];
        self.collectionViewHeaders[@(sectionIndex)] = headerView;
    }
    return headerView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionViewHeaders removeObjectForKey:@(indexPath.section)];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NOStickyCollectionViewCell *cell = (NOStickyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.maxSelectedCellCount > 0 && self.selectedCells.count >= self.maxSelectedCellCount)
    {
        // Cannot select anymore
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:[NSString stringWithFormat:@"You cannot select more than %tu images at once. Try deselecting some images first.", self.maxSelectedCellCount]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        cell.selectedState = NO;
    }
    else
    {
        [self.selectedCells addObject:indexPath];
        cell.selectedState = YES;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOStickyCollectionSelectedItemsDidChangeNotification object:self];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NOStickyCollectionViewCell *cell = (NOStickyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.selectedCells containsObject:indexPath])
    {
        [self.selectedCells removeObject:indexPath];
        
        cell.selectedState = NO;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:NOStickyCollectionSelectedItemsDidChangeNotification object:self];
}

#pragma mark - Interaction

- (void)toggleSection:(NSInteger)sectionIndex
{
    NSMutableArray *addedItems, *deletedItems;
    
    if ([self.collapsedSections containsObject:@(sectionIndex)])
    {
        // expand
        [self.collapsedSections removeObject:@(sectionIndex)];

        addedItems = [NSMutableArray new];
        for (NSUInteger i = 0; i < [self collectionView:self.collectionView numberOfItemsInSection:sectionIndex]; i++)
        {
            [addedItems addObject:[NSIndexPath indexPathForItem:i inSection:sectionIndex]];
        }
    }
    else
    {
        // collapse
        deletedItems = [NSMutableArray new];
        for (NSUInteger i = 0; i < [self collectionView:self.collectionView numberOfItemsInSection:sectionIndex]; i++)
        {
            [deletedItems addObject:[NSIndexPath indexPathForItem:i inSection:sectionIndex]];
        }

        [self.collapsedSections addObject:@(sectionIndex)];
    }

    NOStickyCollectionHeaderView *headerView = self.collectionViewHeaders[@(sectionIndex)];
    [headerView setCollapsedState:[self.collapsedSections containsObject:@(sectionIndex)] animated:YES];

    [self.collectionView performBatchUpdates:^{
        if (addedItems)
        {
            [self.collectionView insertItemsAtIndexPaths:addedItems];
        }
        
        if (deletedItems)
        {
            [self.collectionView deleteItemsAtIndexPaths:deletedItems];
        }
    }
                                  completion:NULL];
    
    // force content size update if actual content size changes
    self.collectionView.contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
}

@end
