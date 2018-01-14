//
//  Manager.h
//  mac-ble
//
//  Created by Itamar Hassin on 12/25/17.
//  Copyright © 2017 Itamar Hassin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@interface Manager : NSObject

- (Boolean) running;
- (void) advertize;

@end

