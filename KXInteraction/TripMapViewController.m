//
//  TripMapViewController.m
//  KXInteraction
//
//  Created by Alex Olson on 10/9/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "TripMapViewController.h"
#import "KXTripLocationAnnotation.h"

@interface TripMapViewController()

// plots the trip selected in the tableview on the map.
- (void) plotTrip;

@end

@implementation TripMapViewController

@synthesize trip, tripMap;

- (void) setTrip:(NSDictionary *)newTrip {
    if (trip != newTrip) {
        trip = newTrip;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // plot the trip.
    [self plotTrip];
    
    NSLog(@"%@", trip);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// setup the annotationn. iOS basically calls this anytime I add an annotation to the map and I'm supposed to be
// polite and check to se if there's a resuable annotation to use thats gone out of view of the map before trying
// to create a new one. Apple's lucky I'm nice.
- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString* KXTripLocationIdentifier = @"KXTripLocationAnnotation";
    
    if ([annotation isKindOfClass:[KXTripLocationAnnotation class]]) {
        MKAnnotationView* locationAnnotation = [tripMap dequeueReusableAnnotationViewWithIdentifier:KXTripLocationIdentifier];
        
        if (locationAnnotation == nil) {
            locationAnnotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:KXTripLocationIdentifier];
            locationAnnotation.enabled = YES;
            locationAnnotation.canShowCallout = YES;
        } else {
            locationAnnotation.annotation = annotation;
        }
        
        return locationAnnotation;
    }
    
    return nil;
}

- (void) plotTrip {
    // begin by removing the annotations for the previously plotted trip, if any.
    for (id<MKAnnotation> staleAnnotation in tripMap.annotations) {
        [tripMap removeAnnotation:staleAnnotation]; // stale is gross. Like stale chips. Eww! Get rid of it! Banish said horribleness henceforth and forever!
    }
    
    // now grab the
    
}

@end