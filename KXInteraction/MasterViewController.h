//
//  MasterViewController.h
//  KXInteraction
//
//  Created by Alex Olson on 8/2/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import "KXInteraction.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <KXInteractionDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

// this loads a list of all things registered with an account into the tableview.
- (void) loadMyThingsList;

@end
