//
//  KXTripLocationAnnotation.m
//  KXInteraction
//
//  Created by Alex Olson on 10/10/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

// this turns off instance variable shadowing warning. I don't care about that warning in this class's constructor and
// its really annoying to see all the time. I actually want the param names in the constructor to match those of the instance variables.
// So I tell clang to shut up about it.
#pragma clang diagnostic ignored "-Wshadow-ivar"

#import "KXTripLocationAnnotation.h"

@interface KXTripLocationAnnotation()

@property (strong, nonatomic) NSString* name;

@property (strong, nonatomic) NSString* address;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation KXTripLocationAnnotation

@synthesize name, address, coordinate;

- (id) initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
    
    if (self = [super init]) {
        self.name = name;
        self.address = address;
        self.coordinate = coordinate;
    }
    
    return self;
}

- (NSString*) title {
    return name;
}

- (NSString*) subtitle {
    return address;
}

@end
