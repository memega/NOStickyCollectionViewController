//
//  NOStickyCollectionViewController.h
//
//  Created by Yuriy Panfyorov on 29/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Notification posted after cell selection changed.
 */
FOUNDATION_EXPORT NSString * const NOStickyCollectionSelectedItemsDidChangeNotification;

@interface NOStickyCollectionViewController : UICollectionViewController

/**
 *  Maximum count of cells that can be selected simultaneously. If set to 0, any number of cell can be selected. Default 0.
 */
@property (nonatomic) NSInteger maxSelectedCellCount;

/**
 *  An array of NOAlbum objects to be displayed in the attached UICollectionView
 */
@property (nonatomic) NSArray *albums;

/**
 *  An array of NSIndexPath objects specifying current selection of the attached UICollectionView.
 *  Returns collectionView's -indexPathsForSelectedItems.
 */
@property (nonatomic, readonly) NSArray *indexPathsForSelectedItems;

@end

