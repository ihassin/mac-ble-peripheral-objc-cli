//
//  Manager.m
//  mac-ble
//
//  Created by Itamar Hassin on 12/25/17.
//  Copyright © 2017 Itamar Hassin. All rights reserved.
//
#import "manager.h"

@interface Manager () <CBPeripheralManagerDelegate>
@end

@implementation Manager
{
    CBPeripheralManager *_peripheralManager;
    Boolean _running;
}

// Constructor
- (id) init
{
    self = [super init];
    if (self)
    {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _running = true;
    }
    return self;
}

// Method called whenever the BLE state changes.
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    CBManagerState state = [peripheral state];
    
    NSString *string = @"Unknown state";
    
    switch(state)
    {
        case CBManagerStatePoweredOff:
            string = @"CoreBluetooth BLE hardware is powered off.";
            break;
            
        case CBManagerStatePoweredOn:
            string = @"CoreBluetooth BLE hardware is powered on and ready.";
            break;
            
        case CBManagerStateUnauthorized:
            string = @"CoreBluetooth BLE state is unauthorized.";
            break;
            
        case CBManagerStateUnknown:
            string = @"CoreBluetooth BLE state is unknown.";
            break;
            
        case CBManagerStateUnsupported:
            string = @"CoreBluetooth BLE hardware is unsupported on this platform.";
            break;
            
        default:
            break;
    }
    NSLog(@"%@", string);
}

- (void) advertize
{
    if(_peripheralManager.isAdvertising)
    {
        return;
    }
    
    CBUUID *myUUID = [CBUUID UUIDWithString:@"BD0F6577-4A38-4D71-AF1B-4E8F57708080"];
    CBMutableService *service;
    
    [_peripheralManager setDelegate:self];
    
    service = [[CBMutableService alloc] initWithType:myUUID primary:YES];
    
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"DDCA9B49-A6F5-462F-A89A-C2144083CA7F"] properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyIndicate|CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable];
    
    service.characteristics = @[characteristic];
    
    [_peripheralManager addService:service];
    
    [_peripheralManager startAdvertising:@{
                                   CBAdvertisementDataLocalNameKey: @"ITAMAR-MAC-BOOK-PRO",
                                   CBAdvertisementDataServiceUUIDsKey: @[myUUID]
                                   }];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"peripheralManagerDidStartAdvertising: %@", peripheral.description);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"peripheralManagerDidAddService: %@ %@", service, error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"didReceiveReadRequest: %@ %@", request.central, request.characteristic);
    NSString *mainString = [NSString stringWithFormat:@"ItaBaby"];
    NSData *cmainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
    request.value = cmainData;
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"didSubscribeToCharacteristic");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
  didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    NSLog(@"didReceiveWriteRequests: %@", requests);
}

- (Boolean) running
{
    return(_running);
}

@end
