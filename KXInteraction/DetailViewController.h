//
//  DetailViewController.h
//  KXInteraction
//
//  Created by Alex Olson on 8/2/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KXInteraction.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate> // I think the split vew crap is for iPad stuff.

@property (strong, nonatomic) NSDictionary* trip;
@property (strong, nonatomic) IBOutlet UILabel* startTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel* endTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel* durationLabel;

@end
