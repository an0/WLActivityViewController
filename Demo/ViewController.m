//
//  ViewController.m
//  WLActivityViewController
//
//  Created by Ling Wang on 3/17/15.
//  Copyright (c) 2015 Moke. All rights reserved.
//

#import "ViewController.h"
#import "WLActivityViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)]];
    self.navigationController.toolbarHidden = NO;
}

- (void)action:(id)sender {
    WLActivityViewController *activityViewController = [[WLActivityViewController alloc] initWithActivityItems:@[@"Title"] applicationActivities:nil];
    activityViewController.popoverPresentationController.barButtonItem = sender;
    activityViewController.title = @"Title";
    [self presentViewController:activityViewController animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        activityViewController.title = @"http://wangling.me/2015/04/unify-type-properties-and-methods.html";
    });
}

@end
