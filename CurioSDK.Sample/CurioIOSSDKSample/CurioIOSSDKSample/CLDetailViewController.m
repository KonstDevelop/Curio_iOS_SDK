//
//  CLDetailViewController.m
//  CurioIOSSDKSample
//
//  Changed by Can Ciloglu on 20/02/15.
//  Created by Harun Esur on 24/09/14.
//  Copyright (c) 2014 Turkcell. All rights reserved.
//

#import "CLDetailViewController.h"
#import "CurioSDK.h"

@interface CLDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation CLDetailViewController

- (void) viewDidAppear:(BOOL)animated {
    [[CurioSDK shared] startScreen:[self class] title:@"Detail view" path:@"Detail-view"];
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [[CurioSDK shared] endScreen:[self class]];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (IBAction)sendEvent:(id)sender {
    [[CurioSDK shared] sendEvent:@"Clicked button" eventValue:NSStringFromClass([self class])];
}

- (IBAction)endEvent:(id)sender {
    [[CurioSDK shared] endEvent:@"Clicked button" eventValue:NSStringFromClass([self class]) eventDuration:52780];
}

- (IBAction)getNotificationHistory:(id)sender {
    [[CurioSDK shared] getNotificationHistoryWithPageStart:0 rows:5 success:^(NSDictionary *responseObject) {
        NSLog(@"%@", responseObject.description);
    } failure:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}

- (IBAction)sendLocation:(id)sender {
    [[CurioSDK shared] sendLocation];
}

- (IBAction)unregister:(id)sender {
    [[CurioSDK shared] unregisterFromNotificationServer];
}

- (IBAction)sendCustomId:(id)sender {
    [[CurioSDK shared] sendCustomId: @"sample custom id"];
}

@end
