//
//  KXInteraction.m
//  KXInteraction
//
//  Created by Alex Olson on 8/3/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import "KXInteraction.h"

@interface KXInteraction()

// eventually more private properties and/or methods here
// need to think about what should be private and
// what should be forward-facing.

@property NSURL* KNSEvaluationHost;

- (NSURL*) constructOAuthHandshakeDoorbellURL:(NSString*)appKey;

@end

@implementation KXInteraction

@synthesize delegate, evalHost;

- (id) init {
    return [self initWithEvalHost:nil andDelegate:nil];
}

- (id) initWithEvalHost:(NSString*)host andDelegate:(id)del {
    
    if (self = [super init]) {
        self.evalHost = [NSURL URLWithString:host];
        self.delegate = del;
    }
    
    return self;
}

- (void) beginOAuthHandshakeWithAppKey:(NSString *)appKey andCallbackURL:(NSString*)callbackURL {
    
    NSString* escapedCallbackURL = [callbackURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* oauthURL = [self constructOAuthHandshakeDoorbellURL:appKey withCallback:[NSURL URLWithString:escapedCallbackURL]];
    NSURLRequest* oauthRequest = [NSURLRequest requestWithURL:oauthURL];
    
    // get the main window of the application
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    // get a frame to size our webview
    CGRect webViewFrame =  [keyWindow bounds];
    
    // create the webview
    UIWebView* squaretagOAuthView = [[UIWebView alloc] initWithFrame:webViewFrame];
    squaretagOAuthView.scalesPageToFit = YES;
    //squaretagOAuthView.delegate = self;
    
    // start loading the oauth request in the webview
    [squaretagOAuthView loadRequest:oauthRequest];
    // add the webview to the applications window
    [keyWindow addSubview:squaretagOAuthView];
}

#pragma mark -
#pragma mark private methods
- (NSURL*) constructOAuthHandshakeDoorbellURL:(NSString *)appKey withCallback:(NSURL*)callback {
    
    // this random number is passed to the client_state paramater that CloudOS OAuth requires
    // honestly Im not really sure why we need client_state anyway....but oh well. :)
    NSInteger state = arc4random_uniform(10000);
    
    // since this is a mobile app and not a website, I dont really care about a callback (redirect_url),
    // but CloudOS OAuth will throw a tantrum if we dont use the callback url that we used when we registered
    // our client app through the Kynetx Developer Kit.
    NSString* oauthURLFragment = [NSString stringWithFormat:@"oauth/authorize?response_type=code&redirect_uri=%@&client_id=%@&state=%i", callback, appKey, state];
    
    // combine our oauth url with our evaluation host
    return [NSURL URLWithString:oauthURLFragment relativeToURL:self.evalHost];
}

@end
