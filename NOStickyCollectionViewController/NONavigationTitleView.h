//
//  NONavigationTitleView.h
//
//  Created by Yuriy Panfyorov on 30/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A simple UIView with two labels, displaying title and number of selected items in format "<selectedCount> of <totalCount>"
 */
@interface NONavigationTitleView : UIView

@property (nonatomic) NSUInteger selectedCount;
@property (nonatomic) NSUInteger totalCount;

@end
