//
//  NOAlbum.h
//
//  Created by Yuriy Panfyorov on 01/06/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A value object.
 */
@interface NOAlbum : NSObject

@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) NSString *title;
/**
 *  An array of NSString objects containing URLs to loadable photos.
 */
@property (nonatomic, readonly) NSArray *photos;

/**
 *
 *  @param title  Album title
 *  @param photos An array of NSString objects containing URLs to loadable photos.
 *
 *  @return A new immutable instance of NOAlbum
 */
+(instancetype)albumWithTitle:(NSString *)title photos:(NSArray *)photos;

@end
