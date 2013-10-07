//
//  DetailViewController.h
//  KXInteraction
//
//  Created by Alex Olson on 8/2/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KXInteraction.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSDictionary* trip;
@property (strong, nonatomic) IBOutlet UILabel* startTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel* endTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel* durationLabel;
@property (strong, nonatomic) IBOutlet MKMapView* tripMap;

@end
