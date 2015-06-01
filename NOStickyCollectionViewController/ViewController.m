//
//  ViewController.m
//
//  Created by Yuriy Panfyorov on 01/06/15.
//  Copyright (c) 2015 Yuriy Panfyorov. All rights reserved.
//

#import "ViewController.h"

#import "NOStickyCollectionViewController.h"

#import "NOAlbum.h"
#import "NONavigationTitleView.h"

static NSUInteger const _NOMaxSelectedCellsCount = 20;

@interface ViewController ()

@property (nonatomic) NONavigationTitleView *titleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // prepare data
    NSMutableArray *albums = [NSMutableArray new];
    for (NSUInteger i = 0; i < 50; i++)
    {
        NSMutableArray *photos = [NSMutableArray new];
        NSUInteger numberOfPhotos = 3 + (arc4random() % 47);
        if (i == 0)
        {
            numberOfPhotos = 23;
        }
        for (NSUInteger j = 0; j < numberOfPhotos; j++)
        {
            NSUInteger photoSize = 120 + j + i;
            NSString *photoURLString = [NSString stringWithFormat:@"http://placekitten.com/%tu/%tu", photoSize, photoSize];
            [photos addObject:photoURLString];
        }
        
        NSString *albumTitle = (i == 0 ? @"Camera Roll" : (i == 1 ? @"My Album" : [NSString stringWithFormat:@"My Album %tu", i-1]));
        NOAlbum *album = [NOAlbum albumWithTitle:albumTitle photos:photos];
        [albums addObject:album];
    }

    // in nested view controller on iOS 7 automaticallyAdjustsScrollViewInsets doesn't seem to work
    // so we need to disable the default behaviour
    self.automaticallyAdjustsScrollViewInsets = NO;

    // load sticky collection view controller
    NOStickyCollectionViewController *stickyCollectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StickyViewController"];
    [self addChildViewController:stickyCollectionViewController];

    stickyCollectionViewController.view.frame = self.view.bounds;
    stickyCollectionViewController.albums = [NSArray arrayWithArray:albums];

    [self.view addSubview:stickyCollectionViewController.view];
    
    // observe selection changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stickyCollectionSelectionDidChange:)
                                                 name:NOStickyCollectionSelectedItemsDidChangeNotification
                                               object:stickyCollectionViewController];
    
    // display current selection
    NONavigationTitleView *titleView = [[NONavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    titleView.totalCount = _NOMaxSelectedCellsCount; // max selected
    titleView.selectedCount = 0;
    self.titleView = titleView;

    self.navigationItem.titleView = titleView;
}

- (void)stickyCollectionSelectionDidChange:(NSNotification *)notification
{
    NOStickyCollectionViewController *stickyViewController = notification.object;
    self.titleView.selectedCount = stickyViewController.indexPathsForSelectedItems.count;
}

@end
