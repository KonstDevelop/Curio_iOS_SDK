//
//  CLMasterViewController.h
//  CurioIOSSDKSample
//
//  Created by Harun Esur on 24/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLDetailViewController;

@interface CLMasterViewController : UITableViewController

@property (strong, nonatomic) CLDetailViewController *detailViewController;

@end
