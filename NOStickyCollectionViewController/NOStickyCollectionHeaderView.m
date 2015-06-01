//
//  NOStickyCollectionHeaderView.m
//
//  Created by Yuriy Panfyorov on 29/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "NOStickyCollectionHeaderView.h"

@implementation NOStickyCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self prepareView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self prepareView];
}

- (IBAction)tap:(id)sender
{
    if (self.tap)
    {
        self.tap();
    }
}

- (void)prepareForReuse
{
    [self prepareView];
}

- (void)prepareView
{
    self.collapsedState = NO;
}

- (void)setCollapsedState:(BOOL)collapsedState
{
    [self setCollapsedState:collapsedState animated:NO];
}

- (void)setCollapsedState:(BOOL)collapsedState animated:(BOOL)animated
{
    if (_collapsedState == collapsedState) return;
    
    _collapsedState = collapsedState;
    
    UIView *disclosure = self.disclosure;
    void (^propertiesBlock)() = ^{
        if (collapsedState)
        {
            disclosure.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else
        {
            disclosure.transform = CGAffineTransformIdentity;
        }
    };
    
    if (animated)
    {
        [UIView animateWithDuration:.25 animations:propertiesBlock];
    }
    else
    {
        propertiesBlock();
    }
}

@end
