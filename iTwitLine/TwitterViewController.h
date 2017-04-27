//
//  TwitterViewController.h
//  iTwitLine
//
//  Created by Rigo on 25.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STTwitter.h>

@interface TwitterViewController : UITableViewController <UITableViewDataSource>

@property (nonatomic, weak) STTwitterAPI *twitter;

@end
