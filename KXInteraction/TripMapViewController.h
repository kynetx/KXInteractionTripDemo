//
//  TripMapViewController.h
//  KXInteraction
//
//  Created by Alex Olson on 10/9/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TripMapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) NSDictionary* trip;
@property (strong, nonatomic) IBOutlet MKMapView* tripMap;

@end
