//
//  AppDelegate.h
//  iTwitLine
//
//  Created by Rigo on 25.02.17.
//  Copyright © 2017 Rigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end
