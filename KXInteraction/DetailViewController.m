//
//  DetailViewController.m
//  KXInteraction
//
//  Created by Alex Olson on 8/2/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "DetailViewController.h"

#define kOFFSET_FOR_KEYBOARD 85.0

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
// the position state of the view
@property (assign, nonatomic) BOOL viewIsUp;

// moves the view up to accomodate the presence of a keyboard.
- (void) moveViewUp;

// moves the view back to original position.
- (void) moveViewDown;

// fills the data into the UI.
- (void)configureView;

@end

@implementation DetailViewController

@synthesize trip, nameTextField, tagsTextField, startTimeLabel, endTimeLabel, durationLabel, distanceLabel, notesTextView, viewIsUp;

- (void)setTrip:(NSDictionary*)newTrip
{
    if (trip != newTrip) {
        trip = newTrip;
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    // Update the user interface for the detail item.
    self.startTimeLabel.text = [KXInteraction evaluateHumanFriendlyTimeFromUTCTimestamp:[trip objectForKey:@"startTime"]];
    self.endTimeLabel.text = [KXInteraction evaluateHumanFriendlyTimeFromUTCTimestamp:[trip objectForKey:@"endTime"]];
    
    // calculate duration
    NSDate* startTime = [KXInteraction insertSeperatorsIntoUTCTimestamp:[trip objectForKey:@"startTime"]];
    NSDate* endTime = [KXInteraction insertSeperatorsIntoUTCTimestamp:[trip objectForKey:@"endTime"]];
    
    NSTimeInterval startTimeSeconds = [startTime timeIntervalSince1970];
    NSTimeInterval endTImeSeconds = [endTime timeIntervalSince1970];
    NSLog(@"%f", startTimeSeconds);
    NSLog(@"%f", endTImeSeconds);
    
    NSTimeInterval duration = endTImeSeconds - startTimeSeconds;
    NSLog(@"%f", duration);
    
    self.durationLabel.text = @"32 minutes";
    self.costLabel.text = @"$25.23";
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ miles", [trip objectForKey:@"mileage"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // update user interface to display current trip data.
    [self configureView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    if (self.viewIsUp) {
        [self moveViewDown];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView*)textView {
    if (self.view.frame.origin.y >= 0) {
        [self moveViewUp];
    }
}

- (void) moveViewUp {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        CGRect rect = self.view.frame;
        
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
        
        self.view.frame = rect;
    }];
    
    self.viewIsUp = YES;
}

- (void) moveViewDown {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        CGRect rect = self.view.frame;
        
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        
        self.view.frame = rect;
    }];
    
    self.viewIsUp = NO;
}

@end
