# Introduction

This is a demonstration of my experimentation with running a Bluetooth LE peripheral on my Mac, as a proof of concept and part of my endeavour to learn about BLE.
Hopefully you will find it useful for the same reasons, or maybe will help kickstart your next BLE peripheral implementation.

# Protocol flow

Without going too deeply into the BLE stack's protocol, a subject for entire books, here's the flow for this command-line POC:

- Set up a run-loop that allocates CPU to our routines
- Start up Mac OS X BLE service
- Set up a service and associated characteristic of the POC
- Start advertizing the service
- Handle incoming I/O requests

# Implementation

## Set up a run-loop that allocates CPU to our routines

I did not want to be distracted by coding a UI for this POC, so I chose to implement this POC as a command-line-tool.
This means we need to give ourselves CPU time using a loop in [main.m](https://github.com/ihassin/mac-ble-peripheral-objc-cli/blob/master/mac-ble-peripheral-objc-cli/main.m):

```
while([manager running] && [runLoop runMode:NSDefaultRunLoopMode beforeDate:distantFuture]) {
[manager advertize];
}
```

Without this loop, nothing will work.

## Start up Mac OS X BLE service

By instantiating CBPeripheralManager, Mac OS loads and starts the BLE framework, allowing us to interact with it as a peripheral.

This is done in the constructor of [manager.m](https://github.com/ihassin/mac-ble-peripheral-objc-cli/blob/master/mac-ble-peripheral-objc-cli/manager.m):
```
_peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
```

## Set up a service and associated characteristic of the POC

To serve data, we need to create a service that will be advertised to potential clients.
Doing so is a matter of creating a characteristic, which will expose the peripheral's data, and adding it to a service that clients can look for.
Both these objects (service and characteristic) need a UUID to distinguish them from other vendors and their services.
I used the Mac's built-in UUID generator (uuidgen) to create both for the POC and assigned them to instance variables:

```
_charUUID = [CBUUID UUIDWithString:@"DDCA9B49-A6F5-462F-A89A-C2144083CA7F"];
_myUUID = [CBUUID UUIDWithString:@"BD0F6577-4A38-4D71-AF1B-4E8F57708080"];
```

I wanted to be able to read and write the data value of the peripheral, to test out those functions, and used the following flags when creating the characteristic:
```text
CBMutableCharacteristic *myCharacteristic = [[CBMutableCharacteristic alloc]
initWithType:_charUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyIndicate|CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
```

An important point is _not_ to set the initial value (see value:nil); if you set the initial value, it's taken as a static characteristic, and writes won't be routed to our callback.

After adding the characteristic to the service, we add the service to the list of services the peripheral supports to the manager object, putting us in a state where we can adverise:

## Start advertising the service

To have Centrals connect to our Peripheral, it needs to adverise itself:

```
[_peripheralManager startAdvertising:@{
CBAdvertisementDataLocalNameKey: @"ITAMAR-MAC-BOOK-PRO",
CBAdvertisementDataServiceUUIDsKey: @[_myUUID]
}];
```

The name 'ITAMAR-MAC-BOOK-PRO' is the one your Bluetooth scanner might display. I used [BLE Scanner](https://itunes.apple.com/us/app/ble-scanner-4-0/id1221763603?mt=8).

## Handle incoming I/O requests

At this stage, your scanner should pick up the device (your mac) and service (itamar etc).
Characteristics can be read or written only if the Central is connected to them. This is not _pairing_, but _connecting_.
Once connected, your scanner can read the value exposed by querying the specific charactersitic's UUID, which, in our case, is
```
DDCA9B49-A6F5-462F-A89A-C2144083CA7F
```

Reading, as well as writing, will trigger our callbacks to be called by CBPeripheralManager:

Read callback:

```text
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
```

Write callback:
```
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
```

In this POC, I do some basic checking and handle the request, but most of the code is to translate NSData to NSString and vice versa.

# Access the example

Please feel free to use, fork and improve this snippet, posted on [github](https://github.com/ihassin/mac-ble-peripheral-objc-cli).

I hope you find the example useful!

Happy hacking!

