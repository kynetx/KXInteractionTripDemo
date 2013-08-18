//
//  KXInteraction.h
//  KXInteraction
//
//  Created by Alex Olson on 8/3/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KXInteractionDelegate <NSObject>

// Gets called on completion of succesful CloudOS OAuthentication
- (void) oauthHandshakeDidSuccedWithECI:(NSString*)eci;

// Gets called on completion of failed CloudOS OAuthentication
- (void) oauthHandshakeDidFailWithError:(NSError*)error;


@end

@interface KXInteraction : NSObject <UIWebViewDelegate>

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
- (void) beginOAuthHandshakeWithAppKey:(NSString*)appKey andCallbackURL:(NSString*)callbackURL;

@end
