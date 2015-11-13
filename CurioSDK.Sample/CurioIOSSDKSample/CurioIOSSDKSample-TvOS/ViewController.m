//
//  ViewController.m
//  CurioIOSSDKSample-TvOS
//
//  Created by Cem Turker on 13/11/15.
//  Copyright © 2015 Turkcell. All rights reserved.
//

#import "ViewController.h"
#import "CurioSDK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[CurioSDK shared] startScreen:[self class] title:@"TvOSViewController" path:@"TvOSViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendEventButtonAction:(id)sender {
    
    [[CurioSDK shared] sendEvent:@"Button clicked" eventValue:@"Button clicked"];
    
}

@end
