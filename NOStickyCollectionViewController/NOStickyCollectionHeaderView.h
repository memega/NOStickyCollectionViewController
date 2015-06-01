//
//  NOStickyCollectionHeaderView.h
//
//  Created by Yuriy Panfyorov on 29/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NOStickyCollectionHeaderView : UICollectionReusableView

@property (nonatomic) IBOutlet UILabel *label;
@property (nonatomic) IBOutlet UIView *disclosure;

@property (nonatomic) NSInteger sectionIndex;

/**
 *  Toggles the disclosure icon orientation.
 */
@property (nonatomic) BOOL collapsedState;
- (void)setCollapsedState:(BOOL)collapsedState animated:(BOOL)animated;

/**
 *  Block is executed whenever a user taps on the section header.
 */
@property (nonatomic, copy) void (^tap)();

@end
