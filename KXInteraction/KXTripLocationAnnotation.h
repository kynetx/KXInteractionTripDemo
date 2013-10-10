//
//  KXTripLocationAnnotation.h
//  KXInteraction
//
//  Created by Alex Olson on 10/10/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface KXTripLocationAnnotation : NSObject <MKAnnotation>

- (id) initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;

@end
