//
//  NOStickyCollectionViewCell.h
//
//  Created by Yuriy Panfyorov on 30/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NOStickyCollectionViewCell : UICollectionViewCell

/**
 *  When set to YES, displays the photo in selected state, showing an overlay and a small checkbox icon.
 */
@property (nonatomic) BOOL selectedState;

/**
 *  URL of the image to display. If the URL is not accessible or erroneous, the cell displays a placeholder image.
 */
@property (nonatomic) NSString *imageURL;

@end
