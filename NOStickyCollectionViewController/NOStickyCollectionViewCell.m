//
//  NOStickyCollectionViewCell.m
//
//  Created by Yuriy Panfyorov on 30/05/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "NOStickyCollectionViewCell.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#pragma mark - Error image

static UIImage *_AMPErrorImage()
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"Error"];
    });
    return image;
}

static NSMutableSet *erroneousImageURLs = nil;

// some URLS at placekitten.com return an empty HTML,
// so in order to avoid re-requesting them, store those
static BOOL _AMPIsErroneousImageAtURL(NSString *URL)
{
    return [erroneousImageURLs containsObject:URL];
}

static void _AMPSetErrorneousImageAtURL(NSString *URL)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        erroneousImageURLs = [NSMutableSet set];
    });
    [erroneousImageURLs addObject:URL];
}

#pragma mark - APMCollectionViewCell

@interface NOStickyCollectionViewCell ()

@property (nonatomic) IBOutlet UIView *dimmingView;
@property (nonatomic) IBOutlet UIView *checkbox;

@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation NOStickyCollectionViewCell

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

- (void)setSelectedState:(BOOL)selectedState
{
    if (_selectedState == selectedState) return;
    
    _selectedState = selectedState;
    
    self.dimmingView.hidden = !selectedState;
    self.checkbox.hidden = !selectedState;
}

- (void)prepareView
{
    self.selected = NO;
    self.selectedState = NO;
    self.dimmingView.hidden = YES;
    self.checkbox.hidden = YES;
    self.activityIndicatorView.hidden = YES;
    self.imageURL = nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self prepareView];
}

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL && [_imageURL isEqualToString:imageURL]) return;
    
    _imageURL = imageURL;

    if (imageURL)
    {
        // some of placekitten.com URLs return an empty image, ignore those
        if (_AMPIsErroneousImageAtURL(imageURL))
        {
            self.imageView.image = _AMPErrorImage();
        }
        else
        {
            self.imageView.image = nil; // hide the error image
        
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

            // cancels the previous request automatically
            __weak typeof(self) weakSelf = self;
            [self.imageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               __strong typeof(self) strongSelf = weakSelf;
                                               
                                               [strongSelf.activityIndicatorView stopAnimating];
                                               strongSelf.activityIndicatorView.hidden = YES;
                                               
                                               if (image)
                                               {
                                                   [UIView transitionWithView:strongSelf.imageView
                                                                     duration:.25
                                                                      options:UIViewAnimationOptionTransitionCrossDissolve
                                                                   animations:^{
                                                                       __strong typeof(self) strongSelf = weakSelf;
                                                                       strongSelf.imageView.image = image;
                                                                   } completion:nil];
                                               }
                                               else
                                               {
                                                   _AMPSetErrorneousImageAtURL(imageURL);
                                                   strongSelf.imageView.image = _AMPErrorImage();
                                               }
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               __strong typeof(self) strongSelf = weakSelf;
                                               
                                               [strongSelf.activityIndicatorView stopAnimating];
                                               strongSelf.activityIndicatorView.hidden = YES;
                                               
                                               strongSelf.imageView.image = _AMPErrorImage();
                                           }];
        }
    }
    else
    {
        self.imageView.image = _AMPErrorImage();
    }
}

@end
