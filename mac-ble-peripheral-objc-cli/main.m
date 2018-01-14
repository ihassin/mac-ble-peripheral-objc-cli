//
//  main.m
//  mac-ble
//
//  Created by Itamar Hassin on 12/25/17.
//  Copyright © 2017 Itamar Hassin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "manager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Manager *manager = [[Manager alloc] init];
        
        NSRunLoop *runLoop = NSRunLoop.currentRunLoop;
        NSDate *distantFuture = NSDate.distantFuture;
        while([manager running] && [runLoop runMode:NSDefaultRunLoopMode beforeDate:distantFuture]) {
            [manager advertize];
        }
        
    }
    return 0;
}
