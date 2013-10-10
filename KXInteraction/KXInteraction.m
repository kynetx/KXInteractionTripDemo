//
//  KXInteraction.m
//  KXInteraction
//
//  Created by Alex Olson on 8/3/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXInteraction.h"

@interface KXInteraction()

// an event channel for the master personal cloud we are
// connected to
@property (strong, nonatomic) NSString* masterECI;

// private property that stores the oauth code returned from
// cloudOS that is then used to request an ECI
@property (strong, nonatomic) NSString* oauthCode;

// the webview we use to start the oauth handshake and retrieve
// an oauth code
@property (strong, nonatomic) UIWebView* squaretagOAuthView;

// the container view controller that we place our UIWebview in
@property (strong, nonatomic) UIViewController* containerViewController;

// the applications key, which we exchange for an OAuth code
// from CloudOS
@property (strong, nonatomic) NSString* appkey;

// the callback url for this application. We can really disregard this because
// we dont use it for a mobile app but CloudOS throws fits when the callback url
// is not passed in tandem with the app key in every request.
@property (strong, nonatomic) NSURL* callbackURL;

// this is a dictionary that maps our various connection objects to the data that they
// return
@property (nonatomic) CFMutableDictionaryRef connectionInfoMap;

// private helper method to construct an OAuth code request URL
- (NSURL*) constructOAuthHandshakeDoorbellURL:(NSString*)applicationKey withCallback:(NSURL*)callback;

// private helper method to initiate request to exchange oauth code for an ECI.
- (void) exchangeCodeForECI;

@end

@implementation KXInteraction

@synthesize delegate, evalHost, oauthCode, squaretagOAuthView, containerViewController, appkey, callbackURL, connectionInfoMap, masterECI;

- (id) init {
    return [self initWithEvalHost:nil andDelegate:nil];
}

- (id) initWithEvalHost:(NSString*)host andDelegate:(id)del {
    
    if (self = [super init]) {
        self.evalHost = [NSURL URLWithString:host];
        // this will be nil if theres nothing in nsuserdefaults under that key
        self.masterECI = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.kxinteraction.masterECI"];
        self.delegate = del;
        self.oauthCode = nil;
        self.appkey = nil;
        self.callbackURL = nil;
        self.connectionInfoMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    
    return self;
}

- (void) beginOAuthHandshakeWithAppKey:(NSString *)appKey andCallbackURL:(NSString*)cbURL andParentViewController:(UIViewController *)viewController {
    
    // check to see if we are already authorized, if we are, get the heck outta dodge.
    if ([self authorized]) {
        return;
    }
    
    NSString* escapedCallbackURL = [cbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* oauthURL = [self constructOAuthHandshakeDoorbellURL:appKey withCallback:[NSURL URLWithString:escapedCallbackURL]];
    NSURLRequest* oauthRequest = [NSURLRequest requestWithURL:oauthURL];
    
    // programatically add UIWebview to handle user approval of OAuthentication.
    // it turns out you've gotta go through some serious sludge to do so! I tried
    // to do this in the most portable way possible. IE add view to the current
    // applications key window, and also frame the UIWebview to the current screens
    // bounds, accomodating the applications status bar height. 
    
    // get current application
    UIApplication* currentApp = [UIApplication sharedApplication];
    
    // get the bounds of the current screen
    CGRect currentScreenBounds = [[UIScreen mainScreen] bounds];
    
    // extract the height and width out of the current screens bounds
    CGFloat currentScreenWidth = currentScreenBounds.size.width;
    CGFloat currentScreenHeight = currentScreenBounds.size.height;
    
    // get the height of the application status bar
    CGFloat statusBarHeight = [currentApp statusBarFrame].size.height;
    
    // subtract the status bar height from the current screen height to get a height for our webview
    CGFloat webViewHeight = currentScreenHeight - statusBarHeight;
    
    // make the frame for our webview
    // we have to tell CGRectMake to start drawing below the status bar
    CGRect frame = CGRectMake(0, statusBarHeight, currentScreenWidth, webViewHeight);
    
    // create the webview
    self.squaretagOAuthView = [[UIWebView alloc] initWithFrame:frame];
    // store the container view controller
    self.containerViewController = viewController;
    
    // YES! We have set the viewport meta tag on squaretag.com but it doesn't
    // appear to always solve our problem, so I tell the webview to scale the pages
    // it displays to conform to the space avaliable.
    self.squaretagOAuthView.scalesPageToFit = YES;
    self.squaretagOAuthView.delegate = self;
    
    // hide the views navigation bar while OAuth takes place
    [self.containerViewController.navigationController setNavigationBarHidden:YES animated:YES];
    // add the webview to the passed in view
    [self.containerViewController.view addSubview:self.squaretagOAuthView];
    
    // start loading the oauth request in the webview
    // I could preload this through use of preLoad and a delegate method
    // but it doesn't affect the UX too much if the user sees a white screen for
    // about 2 seconds. One improvement would be to add an activity indicator
    // to indicate that stuff is loading.
    [self.squaretagOAuthView loadRequest:oauthRequest];
}

- (BOOL) authorized {
    return self.masterECI != nil;
}

- (void) callSkyCloudWithModule:(NSString *)module andFunction:(NSString*)func withParamaters:(id)params andECI:(id)eci andSuccess:(void (^)(id))success {
    NSMutableString* skyCloudCommand = [NSMutableString stringWithFormat:@"sky/cloud/%@/%@", module, func];
    NSURL* urlForSkyCloudConnection;
    
    if (params == nil) {
        urlForSkyCloudConnection = [NSURL URLWithString:skyCloudCommand relativeToURL:self.evalHost];
    } else {
        __block NSInteger enumerationCount = 0;
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
            if (enumerationCount == 0) {
                [skyCloudCommand appendFormat:@"?%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            } else {
                [skyCloudCommand appendFormat:@"&%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            
            enumerationCount++;
        }];
        
        urlForSkyCloudConnection = [NSURL URLWithString:skyCloudCommand relativeToURL:self.evalHost];
    }
    
    NSMutableURLRequest* skyCloudRequest = [NSMutableURLRequest requestWithURL:urlForSkyCloudConnection];
    if (eci != nil) {
        [skyCloudRequest setValue:eci forHTTPHeaderField:@"Kobj-Session"];
    } else {
        [skyCloudRequest setValue:self.masterECI forHTTPHeaderField:@"Kobj-Session"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* skyCloudData = [NSURLConnection sendSynchronousRequest:skyCloudRequest returningResponse:nil error:nil];
        id skyCloudResponse = [NSJSONSerialization JSONObjectWithData:skyCloudData options:0 error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(skyCloudResponse);
        });
    });
    
}

- (void) getMyThings:(void (^)(NSDictionary *))success {
    // just call sky cloud
    [self callSkyCloudWithModule:@"mythings" andFunction:@"getThings" withParamaters:nil andECI:nil andSuccess:^(NSDictionary* things) {
        success(things);
    }];
}

#pragma mark -
#pragma mark private methods
- (NSURL*) constructOAuthHandshakeDoorbellURL:(NSString *)applicationKey withCallback:(NSURL*)callback {
    
    // once we've made it to this private method, we can safely set
    // our appKey and callbackURL for the current instance of KXInteraction
    self.appkey = applicationKey;
    self.callbackURL = callback;
    
    // this random number is passed to the client_state paramater that CloudOS OAuth requires
    // honestly Im not really sure why we need client_state anyway....but oh well. :)
    NSInteger state = arc4random_uniform(10000);
    
    // since this is a mobile app and not a website, I dont really care about a callback (redirect_url),
    // but CloudOS OAuth will throw a tantrum if we dont use the callback url that we used when we registered
    // our client app through the Kynetx Developer Kit.
    NSString* oauthURLFragment = [NSString stringWithFormat:@"oauth/authorize?response_type=code&redirect_uri=%@&client_id=%@&state=%i", self.callbackURL, self.appkey, state];
    
    // combine our oauth url with our evaluation host
    return [NSURL URLWithString:oauthURLFragment relativeToURL:self.evalHost];
}

- (void) exchangeCodeForECI {
    // construct a request for our final act in the CloudOS OAuth Dance
    // we've danced hard and we deserve our reward...the authenticated
    // personal cloud's ECI. Woot!
    NSString* oauthLastDanceFragment = @"oauth/access_token";
    NSURL* oauthLastDanceURL = [NSURL URLWithString:oauthLastDanceFragment relativeToURL:self.evalHost];
    // this is really WHERE THE MAGIC HAPPENS. We set up a POST Body string that will tell CloudOS who we are,
    // flash our credentials, and then hopefully CloudOS gives us the good stuff (the ECI)
    NSString* postDataString = [NSString stringWithFormat:@"grant_type=authorization_code&redirect_url=%@&client_id=%@&code=%@", self.callbackURL, self.appkey, self.oauthCode];
    // setup the request. We POST in order to recieve our long-awaited ECI
    NSMutableURLRequest* oauthLastDanceRequest = [NSMutableURLRequest requestWithURL:oauthLastDanceURL];
    [oauthLastDanceRequest setHTTPMethod:@"POST"];
    [oauthLastDanceRequest setHTTPBody:[postDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // oh boy...here we go...rev up the engines
    NSURLConnection* oauthLastDanceConnection = [NSURLConnection connectionWithRequest:oauthLastDanceRequest delegate:self];
    
    // add this connection to our connection-data mapping
    CFDictionaryAddValue(self.connectionInfoMap, (__bridge const void *)(oauthLastDanceConnection), (__bridge const void *)([NSMutableDictionary dictionaryWithObject:[NSMutableData data] forKey:@"recievedData"]));
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // houston, we have a connection
    // set our data length to 0
    NSMutableDictionary* connectionInfo = CFDictionaryGetValue(self.connectionInfoMap, (__bridge const void *)(connection));
    NSMutableData* connectionData = [connectionInfo objectForKey:@"recievedData"];
    [connectionData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // got some data! woot!
    NSMutableDictionary* connectionInfo = CFDictionaryGetValue(self.connectionInfoMap, (__bridge const void *)(connection));
    [[connectionInfo objectForKey:@"recievedData"] appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    // we're almost there...hide the network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // pull out our current connection info from our map
    NSMutableDictionary* connectionInfo = CFDictionaryGetValue(self.connectionInfoMap, (__bridge const void *)(connection));
    
    // initialize an error object to hold any JSON-parsing errors
    NSError* jsonParseError = nil;
    
    // get the requested url of the finishing request as a lowercased string
    NSString* connectionURLString = connection.currentRequest.URL.absoluteString.lowercaseString;
    
    // determine what action to take depending on the connection that is finishing up
    if ([connectionURLString rangeOfString:@"oauth/access_token"].location != NSNotFound) {
        // this is an OAuth request...pass the ECI to the appropriate delegate method
        NSDictionary* oauthLastActResponseJSON = [NSJSONSerialization JSONObjectWithData:[connectionInfo objectForKey:@"recievedData"] options:0 error:&jsonParseError];
        
        // save the eci to nsuserdefaults so that we have it for later, and send a message to the delegate
        // to let them know that they can now perform privileged operations.
        NSString* eci = [oauthLastActResponseJSON objectForKey:@"OAUTH_ECI"];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:eci forKey:@"com.kxinteraction.masterECI"];
        self.masterECI = eci;
        [self.delegate oauthHandshakeDidSucced];
    }
    
    // last thing we do is remove this connection from our connection map
    CFDictionaryRemoveValue(self.connectionInfoMap, (__bridge const void *)(connection));
}
    
    

#pragma mark -
#pragma mark UIWebView Delegate Methods

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // get the URL that should load as a string
    NSString* urlString = request.URL.absoluteString;
    
    if ([urlString.lowercaseString rangeOfString:@"code="].location == NSNotFound) {
        // we dont have the code yet....
        // continue with the load
        return YES;
    } else {
        // we have gotten an OAuth Code...now we just need to extract it
        // I like regex's for this sort of stuff
        // define a pattern string
        NSString* codeRegexPattern = @"code=(.*?)(?:&|$)";
        // make the regex case insensitive
        NSRegularExpressionOptions codeRegexOpts = NSRegularExpressionCaseInsensitive;
        // define an NSError object to hold any possible errors
        NSError* codeRegexError = nil;
        // construct the regex object
        NSRegularExpression* codeRegex = [NSRegularExpression regularExpressionWithPattern:codeRegexPattern options:codeRegexOpts error:&codeRegexError];
        // if an error occured, just log it for now
        if (codeRegexError != nil) {
            NSLog(@"%@", [codeRegexError description]);
        }
        
        // test the string against the regex and get results of the capture group
        // matchesInString returns an array of ranges. Where the range property will give the
        // overall match, and specific capture groups can be retrieved by using objectAtIndex
        NSArray* codeResults = [codeRegex matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
        // woot! set our oauth code to the extracted string
        self.oauthCode = [urlString substringWithRange:[[codeResults objectAtIndex:0] rangeAtIndex:1]];
        
        // NSLog(@"%@", self.oauthCode);
        
        [UIView animateWithDuration:0.5 animations:^{
            self.squaretagOAuthView.alpha = 0;
        } completion:^(BOOL done) {
            [self.squaretagOAuthView removeFromSuperview];
        }];
        
        // show the navigation bar again.
        [self.containerViewController.navigationController setNavigationBarHidden:NO animated:YES];
        
        // we dont need the container view controller anymore
        self.containerViewController = nil;
        
        [self exchangeCodeForECI];
        return NO;
    }
}

#pragma mark -
#pragma mark class utility methods

+ (NSDate*) insertSeperatorsIntoUTCTimestamp:(NSString *)UTCTimestamp {
    // convert to seperated UTC timestamp
    NSDateFormatter* datePrettyPrinter = [[NSDateFormatter alloc] init];
    [datePrettyPrinter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [datePrettyPrinter setDateFormat:@"yyyyMMdd'T'HHmmss'+'ssss"];
    return [datePrettyPrinter dateFromString:UTCTimestamp];
    
}

+ (NSString*) evaluateHumanFriendlyTimeFromUTCTimestamp:(NSString *)unfriendlyUTCTimestamp {
    
    NSDate* seperatedUTCTimestamp = [self insertSeperatorsIntoUTCTimestamp:unfriendlyUTCTimestamp];
    // date suffixs for more human friendlyness
    // Also, YAY FOR NEW OBJECTIVE-C LITERALS!!!! :)
    NSArray* dateSuffixs = @[@"th", @"st", @"nd", @"rd", @"th", @"th", @"th", @"th", @"th", @"th"];
    
    // convert to local human-friendly datetime string
    NSDateFormatter* datePrettyPrinter = [[NSDateFormatter alloc] init];
    [datePrettyPrinter setTimeZone:[NSTimeZone defaultTimeZone]];
    [datePrettyPrinter setDateFormat:@"MMMM d. 'at' h:mm a"];
    NSString* dateString = [datePrettyPrinter stringFromDate:seperatedUTCTimestamp];
    
    // now we extract the day from the seperated UTC timestamp so we can add a suffix to it.
    [datePrettyPrinter setDateFormat:@"d"];
    int dateDay = [[datePrettyPrinter stringFromDate:seperatedUTCTimestamp] intValue];
    
    // determine what suffix to add to the date day.
    NSString* humanFriendlyTime;
    
    // if the date is...
    if (dateDay  >= 11 && dateDay <= 19) { // ...between 11 - 19, it has a 'th' suffix, because the gregorian calendar is weird like that.
        humanFriendlyTime = [dateString stringByReplacingOccurrencesOfString:@"." withString:dateSuffixs[0]];
    } else { // ...anything else, modulo it by 10 and return matching index in dateSuffixs array. This will return the correct suffix. Because math is cool. Stay in school kids.
        humanFriendlyTime = [dateString stringByReplacingOccurrencesOfString:@"." withString:dateSuffixs[dateDay % 10]];
    }
    
    return humanFriendlyTime;
}


#pragma mark -
#pragma mark destructor

- (void) dealloc {
    // GRR!!! Die delegate DIE!!!!
    self.squaretagOAuthView.delegate = nil;
}

@end
