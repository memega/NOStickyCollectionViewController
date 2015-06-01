//
//  NOAlbum.m
//
//  Created by Yuriy Panfyorov on 01/06/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "NOAlbum.h"

@interface NOAlbum ()

@property (nonatomic) UIImage *icon;
@property (nonatomic) NSString *title;
@property (nonatomic) NSArray *photos;

@end

@implementation NOAlbum

+(instancetype)albumWithTitle:(NSString *)title photos:(NSArray *)photos
{
    NOAlbum *album = [NOAlbum new];
    album.title = title;
    album.photos = photos;
    return album;
}

@end
