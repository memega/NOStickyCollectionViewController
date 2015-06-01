//
//  NOStickyCollectionViewController.h
//
//  Created by Yuriy Panfyorov on 29/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const NOStickyCollectionSelectedItemsDidChangeNotification;

@interface NOStickyCollectionViewController : UICollectionViewController

@property (nonatomic) NSInteger maxSelectedCellCount;

// an array of NOAlbum
@property (nonatomic) NSArray *albums;

@property (nonatomic, readonly) NSArray *indexPathsForSelectedItems;

@end

