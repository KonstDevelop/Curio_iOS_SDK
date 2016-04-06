//
//  CLDetailViewController.h
//  CurioIOSSDKSample
//
//  Created by Harun Esur on 24/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
