//
//  manager.m
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
    NSString *_peripheralData;
    CBUUID *_charUUID;
    CBUUID *_myUUID;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _running = true;
        _peripheralData = [NSString stringWithFormat:@"ItaBaby"];

        _charUUID = [CBUUID UUIDWithString:@"DDCA9B49-A6F5-462F-A89A-C2144083CA7F"];
        _myUUID = [CBUUID UUIDWithString:@"BD0F6577-4A38-4D71-AF1B-4E8F57708080"];
    }
    return self;
}

// Method called whenever BT state changes.
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
    
    CBMutableService *service;
    service = [[CBMutableService alloc] initWithType:_myUUID primary:YES];
    
    CBMutableCharacteristic *myCharacteristic = [[CBMutableCharacteristic alloc] initWithType:_charUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyIndicate|CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    
    service.characteristics = @[myCharacteristic];
    [_peripheralManager addService:service];

    [_peripheralManager startAdvertising:@{
                                   CBAdvertisementDataLocalNameKey: @"ITAMAR-MAC-BOOK-PRO",
                                   CBAdvertisementDataServiceUUIDsKey: @[_myUUID]
                                   }];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"peripheralManagerDidStartAdvertising: %@", peripheral.description);
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"peripheralManagerDidAddService: %@ %@", service, error);
    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    if ([request.characteristic.UUID isEqual:_charUUID]) {
        request.value = [_peripheralData dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
        NSLog(@"didReceiveReadRequest: %@ %@. Returning %@", request.central, request.characteristic.UUID, _peripheralData);
    } else
    {
        NSLog(@"didReceiveReadRequest: %@ %@. Ignoring!", request.central, request.characteristic.UUID);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    CBATTRequest *request = requests[0];
    if ([request.characteristic.UUID isEqual:_charUUID]) {
        _peripheralData =[NSString stringWithUTF8String:[request.value bytes]];
        NSLog(@"didReceiveWriteRequest: Wrote: %@", _peripheralData);
    } else
    {
        NSLog(@"didReceiveWriteRequest: %@ %@. Ignoring!", request.central, request.characteristic.UUID);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"didSubscribeToCharacteristic");
}

- (Boolean) running
{
    return(_running);
}

@end
