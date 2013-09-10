//
//  MasterViewController.m
//  KXInteraction
//
//  Created by Alex Olson on 8/2/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray* myThings;
    KXInteraction* cloudOS;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    if (!myThings) {
        myThings = [NSMutableArray array];
        cloudOS = [[KXInteraction alloc] initWithEvalHost:@"https://cs.kobj.net/" andDelegate:self];
        if (![cloudOS authorized]) {
            [cloudOS beginOAuthHandshakeWithAppKey:@"5A09B61E-07AE-11E3-85E4-932EA03AE752" andCallbackURL:@"https://squaretag.com" andParentViewController:self];
        } else {
            [self loadMyThingsList];
        }
    }

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(notYetImplemented:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void) loadMyThingsList {
    [cloudOS getMyThings:^(NSDictionary* things) {
        [things enumerateKeysAndObjectsUsingBlock:^(id key, id thing, BOOL* stop) {
            [myThings addObject:[thing objectForKey:@"myProfileName"]];
            NSArray* paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[myThings count] - 1 inSection:0]];
            [[self tableView] insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notYetImplemented:(id)sender
{
    // show little alert to let people know this has not yet been implemented
    UIAlertView *notYetImplemenetedAlert = [[UIAlertView alloc] initWithTitle:@"No Dice!" message:@"Hey Chris, this feature hasn't been added yet. BROKEN!!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [notYetImplemenetedAlert show];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myThings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = myThings[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    //    [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // NSDate *object = _objects[indexPath.row];
        // self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        // NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        // NSDate *object = _objects[indexPath.row];
        // [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark -
#pragma mark KXInteraction Delegate Methods
- (void) oauthHandshakeDidSucced {
    [self loadMyThingsList];
}

@end
