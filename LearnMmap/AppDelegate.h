//
//  AppDelegate.h
//  LearnMmap
//
//  Created by loyinglin on 2019/7/8.
//  Copyright © 2019 Loying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

