//
//  DetailViewController.h
//  KXInteraction
//
//  Created by Alex Olson on 8/2/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end