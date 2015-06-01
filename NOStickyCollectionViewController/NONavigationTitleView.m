//
//  NONavigationTitleView.m
//
//  Created by Yuriy Panfyorov on 30/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "NONavigationTitleView.h"

@interface NONavigationTitleView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *counterLabel;

@end

@implementation NONavigationTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self prepareView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self prepareView];
    }
    return self;
}

- (void)prepareView
{
    self.selectedCount = 0;
    self.totalCount = 0;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Выбрать фото";
    titleLabel.font = [UIFont boldSystemFontOfSize:14.];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *counterLabel = [[UILabel alloc] init];
    counterLabel.text = @"0 из 0";
    counterLabel.font = [UIFont systemFontOfSize:12.];
    counterLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:counterLabel];
    self.counterLabel = counterLabel;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    
    self.counterLabel.text = [NSString stringWithFormat:@"%tu из %tu", self.selectedCount, self.totalCount];
    [self.counterLabel sizeToFit];
    
    CGFloat totalHeight = CGRectGetHeight(self.titleLabel.frame) + CGRectGetHeight(self.counterLabel.frame);

    self.titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds),
                                         (CGRectGetHeight(self.bounds) - totalHeight) * 0.5 + CGRectGetHeight(self.titleLabel.frame) * .5);
    
    self.counterLabel.center = CGPointMake(CGRectGetMidX(self.bounds),
                                           CGRectGetMaxY(self.titleLabel.frame) + CGRectGetHeight(self.counterLabel.frame) * .5);
}

#pragma mark - Public properties

- (void)setSelectedCount:(NSUInteger)selectedCount
{
    if (_selectedCount == selectedCount) return;
    
    _selectedCount = selectedCount;
    
    [self setNeedsLayout];
}

- (void)setTotalCount:(NSUInteger)totalCount
{
    if (_totalCount == totalCount) return;
    
    _totalCount = totalCount;
    
    [self setNeedsLayout];
}

@end
