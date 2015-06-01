//
//  NOStickyFlowLayout.m
//
//  Created by Yuriy Panfyorov on 29/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "NOStickyFlowLayout.h"

@interface NOStickyFlowLayout ()

@property (nonatomic) NSInteger expandingSection;
@property (nonatomic) NSInteger collapsingSection;

@property (nonatomic) NSMutableDictionary *currentHeaderAttributes;
@property (nonatomic) NSMutableDictionary *headerAttributesBeforeLayout;

@property (nonatomic) NSInteger currentMinVisibleSectionIndex;
@property (nonatomic) NSInteger minVisibleSectionIndexBeforeLayout;

@property (nonatomic) NSInteger currentMaxVisibleSectionIndex;
@property (nonatomic) NSInteger maxVisibleSectionIndexBeforeLayout;

@end

@implementation NOStickyFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.currentHeaderAttributes = [NSMutableDictionary dictionary];
        self.currentMinVisibleSectionIndex = NSNotFound;
        self.currentMaxVisibleSectionIndex = NSNotFound;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.currentHeaderAttributes = [NSMutableDictionary dictionary];
        self.currentMinVisibleSectionIndex = NSNotFound;
        self.currentMaxVisibleSectionIndex = NSNotFound;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // default layout attributes
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    UICollectionView * const collectionView = self.collectionView;
    CGPoint const contentOffset = collectionView.contentOffset;
    CGSize const contentSize = collectionView.bounds.size;
    
    NSUInteger const numberOfSections = self.collectionView.numberOfSections;
    
    NSInteger minSectionIndex = NSIntegerMax;
    NSInteger maxSectionIndex = -1;
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *allSections = [NSMutableIndexSet indexSet];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            maxSectionIndex = MAX(maxSectionIndex, layoutAttributes.indexPath.section);
            minSectionIndex = MIN(minSectionIndex, layoutAttributes.indexPath.section);
            [missingSections addIndex:layoutAttributes.indexPath.section];
            [allSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            maxSectionIndex = MAX(maxSectionIndex, layoutAttributes.indexPath.section);
            minSectionIndex = MIN(minSectionIndex, layoutAttributes.indexPath.section);
            [missingSections removeIndex:layoutAttributes.indexPath.section];
            [allSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    // missingSections now contains sections of all visible cells
    if (maxSectionIndex < numberOfSections - 1)
    {
        // layout also the next one
        [missingSections addIndex:maxSectionIndex + 1];
        [allSections addIndex:maxSectionIndex + 1];
    }
    
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        [answer addObject:layoutAttributes];
    }];
    
    // remove all headers from the answer for now
    NSMutableDictionary *attributesBySection = [NSMutableDictionary dictionary];
    NSIndexSet *headerIndexSet = [answer indexesOfObjectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {
        return [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader];
    }];
    NSArray *headerAttributes = [answer objectsAtIndexes:headerIndexSet];
    [answer removeObjectsAtIndexes:headerIndexSet];
    
    NSInteger lastVisibleSectionHeaderIndex = -1;
    for (UICollectionViewLayoutAttributes *layoutAttributes in headerAttributes)
    {
        NSInteger section = layoutAttributes.indexPath.section;
        attributesBySection[@(section)] = layoutAttributes;
        if (CGRectGetMinY(layoutAttributes.frame) < contentOffset.y + contentSize.height)
        {
            lastVisibleSectionHeaderIndex = MAX(lastVisibleSectionHeaderIndex, section);
        }
    }

    NSInteger startSectionIndex = minSectionIndex, endSectionIndex = maxSectionIndex + 1;
    
    if (self.minVisibleSectionIndexBeforeLayout != NSNotFound && self.minVisibleSectionIndexBeforeLayout < startSectionIndex) {
        startSectionIndex = self.minVisibleSectionIndexBeforeLayout;
    }
    if (self.maxVisibleSectionIndexBeforeLayout != NSNotFound && self.maxVisibleSectionIndexBeforeLayout > endSectionIndex) {
        endSectionIndex = self.maxVisibleSectionIndexBeforeLayout;
    }
    
    self.currentMinVisibleSectionIndex = minSectionIndex;
    self.currentMaxVisibleSectionIndex = maxSectionIndex + 1;
    
    endSectionIndex = MIN(collectionView.numberOfSections - 1, endSectionIndex);
    
    CGFloat verticalAdjustment = 0.0;
    for (NSInteger i = startSectionIndex; i <= endSectionIndex; i++)
    {
        UICollectionViewLayoutAttributes *layoutAttributes;
        
        if (i == lastVisibleSectionHeaderIndex + 1)
        {
            // get the vertical adjustment for the lowest sticky header
            layoutAttributes = [self headerLayoutAttributesForSection:i verticalAdjustment:&verticalAdjustment];
        }
        else
        {
            layoutAttributes = [self headerLayoutAttributesForSection:i verticalAdjustment:NULL];
        }
        
        [answer addObject:layoutAttributes];
        
        if (i > lastVisibleSectionHeaderIndex + 1)
        {
            // need to apply the adjustment calculated by the lowest sticky header
            // so that the following header stick to that one instead of default behaviour
            CGRect frame = layoutAttributes.frame;
            frame.origin.y += verticalAdjustment;
            layoutAttributes.frame = frame;
        }
        
        // store current header attributes
        [self.currentHeaderAttributes setObject:layoutAttributes
                                         forKey:layoutAttributes.indexPath];
    }
    
    return answer;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    if (self.expandingSection != NSNotFound || self.collapsingSection != NSNotFound)
    {
        // adjust positions of items that belong to the sticky header
        if (itemIndexPath.section > self.collapsingSection)
        {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:itemIndexPath.section];
            UICollectionViewLayoutAttributes *cachedHeaderLayoutAttributes = [self.headerAttributesBeforeLayout objectForKey:headerIndexPath];
            if (cachedHeaderLayoutAttributes)
            {
                UICollectionViewLayoutAttributes *headerLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                atIndexPath:headerIndexPath];
                CGRect proposedFrame = layoutAttributes.frame;
                // adjustment: add the difference between initial header position and final header position
                proposedFrame.origin.y += CGRectGetMaxY(cachedHeaderLayoutAttributes.frame) - CGRectGetMaxY(headerLayoutAttributes.frame);
                layoutAttributes.frame = proposedFrame;
            }
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader])
    {
        if (self.expandingSection != NSNotFound || self.collapsingSection != NSNotFound)
        {
            UICollectionViewLayoutAttributes *layoutAttributes = [[self.headerAttributesBeforeLayout objectForKey:elementIndexPath] copy];
            return layoutAttributes;
        }
    }
    
    return [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader])
    {
        if (self.expandingSection != NSNotFound || self.collapsingSection != NSNotFound)
        {
            UICollectionViewLayoutAttributes *layoutAttributes = [[self.currentHeaderAttributes objectForKey:elementIndexPath] copy];
            return layoutAttributes;
        }
    }
    
    return [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.collapsingSection = NSNotFound;
    self.expandingSection = NSNotFound;

    // 1. store current header positions
    // Deep-copy attributes in current cache
    self.headerAttributesBeforeLayout = [[NSMutableDictionary alloc] initWithDictionary:self.currentHeaderAttributes copyItems:YES];

    // 2. store current visible headers
    self.minVisibleSectionIndexBeforeLayout = self.currentMinVisibleSectionIndex;
    self.maxVisibleSectionIndexBeforeLayout = self.currentMaxVisibleSectionIndex;
    
    // 3. layoutAttributesForElementsInRect is called
    //    if minVisibleSectionIndex and maxVisibleSectionIndex are set, it should calculate (correctly!) and return those too
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];

    // can be only inserted or updated
    UICollectionViewUpdateItem *updateItem = [updateItems firstObject];
    if (updateItem.updateAction == UICollectionUpdateActionDelete)
    {
        self.collapsingSection = updateItem.indexPathBeforeUpdate.section;
    }
    else
    {
        self.expandingSection = updateItem.indexPathAfterUpdate.section;
    }
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];

    self.expandingSection = NSNotFound;
    self.collapsingSection = NSNotFound;
}

- (UICollectionViewLayoutAttributes *)headerLayoutAttributesForSection:(NSInteger)section verticalAdjustment:(CGFloat *)verticalAdjustment;
{
    UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                              atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    if (layoutAttributes == nil)
        return nil;
    
    UICollectionView const * collectionView = self.collectionView;
    CGPoint const contentOffset = collectionView.contentOffset;
    CGSize const contentSize = collectionView.bounds.size;
    
    NSInteger numberOfItemsInSection = [collectionView numberOfItemsInSection:section];
    
    CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
    CGRect frameWithEdgeInsets = UIEdgeInsetsInsetRect(layoutAttributes.frame, collectionView.contentInset);
    CGPoint origin = frameWithEdgeInsets.origin;
    CGFloat originalY = CGRectGetMinY(frameWithEdgeInsets);
    
    // vertical range of the previous section contents and header
    CGFloat minPreviousContentsY = - INFINITY;
    if (section > 0)
    {
        NSInteger numberOfItemsInPreviousSection = [collectionView numberOfItemsInSection:section - 1];
        if (numberOfItemsInPreviousSection)
        {
            NSIndexPath *firstItemInPreviousSectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section - 1];
            UICollectionViewLayoutAttributes *firstItemInPreviousSectionAttributes = [self layoutAttributesForItemAtIndexPath:firstItemInPreviousSectionIndexPath];
            minPreviousContentsY = CGRectGetMinY(firstItemInPreviousSectionAttributes.frame);
        }
        else
        {
            NSIndexPath *headerInPreviousSectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section - 1];
            UICollectionViewLayoutAttributes *headerInPreviousSectionAtttibutes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headerInPreviousSectionIndexPath];
            minPreviousContentsY = CGRectGetMaxY(headerInPreviousSectionAtttibutes.frame);
        }
    }
    
    // vertical range of current section contents and header
    CGFloat minContentsY, maxContentsY;
    if (numberOfItemsInSection)
    {
        NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
        UICollectionViewLayoutAttributes *firstObjectAttributes = [self layoutAttributesForItemAtIndexPath:firstItemIndexPath];
        UICollectionViewLayoutAttributes *lastObjectAttributes = [self layoutAttributesForItemAtIndexPath:lastItemIndexPath];
        
        minContentsY = CGRectGetMinY(firstObjectAttributes.frame);
        maxContentsY = CGRectGetMaxY(lastObjectAttributes.frame);
    }
    else
    {
        UICollectionViewLayoutAttributes *sectionHeaderAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        minContentsY = CGRectGetMaxY(sectionHeaderAttributes.frame);
        maxContentsY = minContentsY;
    }
    
    origin.y = MIN(
                   MAX(minContentsY - headerHeight,
                       contentOffset.y + collectionView.contentInset.top),
                   maxContentsY - headerHeight);
    
    origin.y = MIN(origin.y, contentOffset.y + contentSize.height - headerHeight);
    origin.y = MAX(origin.y, minPreviousContentsY); // do not overlap with the lowest section header
    
    layoutAttributes.zIndex = 1024;
    layoutAttributes.frame = (CGRect){
        .origin = origin,
        .size = layoutAttributes.frame.size
    };
    
    if (verticalAdjustment) {
        *verticalAdjustment = CGRectGetMinY(layoutAttributes.frame) - originalY + headerHeight;
    }
    
    return layoutAttributes;
}

@end
