//
//  KXInteraction.h
//  KXInteraction
//
//  Created by Alex Olson on 8/3/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@protocol KXInteractionDelegate <NSObject>

// Gets called on completion of succesful CloudOS OAuthentication
- (void) oauthHandshakeDidSucced;

// Gets called on completion of failed CloudOS OAuthentication
- (void) oauthHandshakeDidFailWithError:(NSError*)error;


@end

@interface KXInteraction : NSObject <UIWebViewDelegate, NSURLConnectionDelegate>

// KXInteraction uses a delegate to communicate with the calling class.
// all messages from KXInteraction will be sent to this delegate.
@property (strong, nonatomic) id <KXInteractionDelegate> delegate;

// The instance of KNS that KXInteraction should communicate with.
// The official production instance of KNS is cs.kobj.net
@property (strong, nonatomic) NSURL* evalHost;

// This creates an instance of KXInteraction
- (id) init;

- (id) initWithEvalHost:(NSString*)host andDelegate:(id <KXInteractionDelegate>)delegate;

// begins the proccess of OAuthenticating to CloudOS
// this is the only outward facing method that is called
// to oauthenticate to cloudOS
- (void) beginOAuthHandshakeWithAppKey:(NSString*)appKey andCallbackURL:(NSString*)callbackURL andParentViewController:(UIViewController*)viewController;

// this method returns true if we are authorized, false if we are not.
- (BOOL) authorized;

// retrieves a list of all things registered to an account
- (void) getMyThings:(void (^)(NSDictionary* things))success;

// calls sky cloud API.
- (void) callSkyCloudWithModule:(NSString*)module andFunction:(NSString*)func withParamaters:(id)params andECI:(id)eci andSuccess:(void (^)(id response))success;

// insert UTC-compliant seperators into a non-seperated UTC timestamp
// and return the result as an NSDate.
+ (NSDate*) insertSeperatorsIntoUTCTimestamp:(NSString*)UTCTimestamp;

// converts an unfriendly UTC timestamp into a human-readable datetime
+ (NSString*) evaluateHumanFriendlyTimeFromUTCTimestamp:(NSString*)unfriendlyUTCTimestamp;

// since we are using Automatic Reference Counting, we shouldn't need this, but we have to nil-out
// the webviews delegate we are using for oauth when we are done using it.
// Otherwise it is retained and causes all sorts of lovely stuff.
- (void) dealloc;

@end
