//
//  NOAlbum.h
//
//  Created by Yuriy Panfyorov on 01/06/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NOAlbum : NSObject

@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *photos;

+(instancetype)albumWithTitle:(NSString *)title photos:(NSArray *)photos;

@end
