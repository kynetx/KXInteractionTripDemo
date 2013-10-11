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
        MKPinAnnotationView* locationAnnotation = (MKPinAnnotationView*)[tripMap dequeueReusableAnnotationViewWithIdentifier:KXTripLocationIdentifier];
        
        if (locationAnnotation == nil) {
            locationAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:KXTripLocationIdentifier];
            locationAnnotation.enabled = YES;
            locationAnnotation.canShowCallout = YES;
            locationAnnotation.animatesDrop = YES;
            locationAnnotation.pinColor = MKPinAnnotationColorRed;
        } else {
            locationAnnotation.annotation = annotation;
        }
        
        return locationAnnotation;
    }
    
    return nil;
}

// setup the polyline drawing awesomness.
- (MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView* tripPolylineView = [[MKPolylineView alloc] initWithOverlay:overlay];
    tripPolylineView.strokeColor = [UIColor blueColor];
    tripPolylineView.lineWidth = 3.0;
    return tripPolylineView;
}

- (void) plotTrip {
    // begin by removing the annotations for the previously plotted trip, if any.
    for (id<MKAnnotation> staleAnnotation in tripMap.annotations) {
        [tripMap removeAnnotation:staleAnnotation]; // stale is gross. Like stale chips. Eww! Get rid of it! Banish said horribleness henceforth and forever!
    }
    
    double startLat = 0.0, startLong = 0.0, endLat = 0.0, endLong = 0.0;
    @try {
        startLat = [[trip valueForKeyPath:@"startWaypoint.latitude"] doubleValue];
        startLong = [[trip valueForKeyPath:@"startWaypoint.longitude"] doubleValue];
        
        endLat = [[trip valueForKeyPath:@"endWaypoint.latitude"] doubleValue];
        endLong = [[trip valueForKeyPath:@"endWaypoint.longitude"] doubleValue];
    }
    @catch (NSException* exception) {
        UIAlertView* broken = [[UIAlertView alloc] initWithTitle:@"API Failure" message:@"The Carvoyant API is being stupid." delegate:nil cancelButtonTitle:@"Yeah, I get it" otherButtonTitles:nil];
        [broken show];
    }

    
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    
    CLLocationCoordinate2D tripStartCoord = CLLocationCoordinate2DMake(startLat, startLong);
    CLLocationCoordinate2D tripEndCoord = CLLocationCoordinate2DMake(endLat, endLong);
    
    CLLocation* tripStartLocation = [[CLLocation alloc] initWithLatitude:tripStartCoord.latitude longitude:tripStartCoord.longitude];
    CLLocation* tripEndLocation = [[CLLocation alloc] initWithLatitude:tripEndCoord.latitude longitude:tripEndCoord.longitude];
    
    // TODO: Nesting the reverse geocoding is not the most awesome thing in the world. Figure out a better way. There's always a better way.
    [geocoder reverseGeocodeLocation:tripStartLocation completionHandler:^(NSArray* placemarks, NSError* error) {
        // TODO: Check the error pointer for any possible errors and fail gracefully. For another day.
        
        // rarely, if ever, will the reverse geocoding service return
        // more than one placemark. Even if it does, I sill only care about
        // the first (most-accurate) one.
        CLPlacemark* tripStartLocationPlacemark = placemarks[0];
        NSString* address = ABCreateStringWithAddressDictionary(tripStartLocationPlacemark.addressDictionary, NO);
        NSArray* addressComponents = [address componentsSeparatedByString:@"\n"];
        NSString* betterAddressFormat = [addressComponents componentsJoinedByString:@", "];
        [tripMap addAnnotation:[[KXTripLocationAnnotation alloc] initWithName:@"Trip Start" address:betterAddressFormat coordinate:tripStartLocationPlacemark.location.coordinate]];
        
        [geocoder reverseGeocodeLocation:tripEndLocation completionHandler:^(NSArray* placemarks, NSError* error) {
            CLPlacemark* tripEndLocationPlacemark = placemarks[0];
            NSString* address = ABCreateStringWithAddressDictionary(tripEndLocationPlacemark.addressDictionary, NO);
            NSArray* addressComponents = [address componentsSeparatedByString:@"\n"];
            NSString* betterAddressFormat = [addressComponents componentsJoinedByString:@", "];
            [tripMap addAnnotation:[[KXTripLocationAnnotation alloc] initWithName:@"Trip End" address:betterAddressFormat coordinate:tripEndLocationPlacemark.location.coordinate]];
            
            // zoom to the annotations
            MKMapRect zoomRect = MKMapRectNull;
            for (id<MKAnnotation> annotation in tripMap.annotations) {
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
            
            // add a little padding
            double inset = -zoomRect.size.width * 2;
            [tripMap setVisibleMapRect:MKMapRectInset(zoomRect, inset, inset) animated:YES];
            
            CLLocationCoordinate2D* tripPolylineCoords = malloc(2 * sizeof(CLLocationCoordinate2D));
            tripPolylineCoords[0] = tripStartLocationPlacemark.location.coordinate;
            tripPolylineCoords[1] = tripEndLocationPlacemark.location.coordinate;
            
            MKPolyline* tripPolyline = [MKPolyline polylineWithCoordinates:tripPolylineCoords count:2];
            free(tripPolylineCoords);
            
            [tripMap addOverlay:tripPolyline];
        }];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showTripDetail"]) {
        if ([[segue destinationViewController] respondsToSelector:@selector(setTrip:)]) {
            [[segue destinationViewController] setTrip:trip];
        }
    }
}

@end