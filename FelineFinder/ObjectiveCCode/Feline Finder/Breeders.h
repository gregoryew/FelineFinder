//
//  Breeders.h
//  Purrfect4U
//
//  Created by Gregory Williams on 6/19/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

#ifndef Purrfect4U_Breeders_h
#define Purrfect4U_Breeders_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Breeder: NSObject

@property int breederID;
@property NSString *breedName;
@property NSString  *name;
@property NSString *webSite;
@property NSString *phone;
@property NSString *email;
@property NSString *streetAddress;
@property NSString *city;
@property NSString *state;
@property NSString *zipCode;
@property NSString *cattery;
@property NSString *distance;
@property double latitude;
@property double longitude;

@end

@interface BreedersList : NSObject
{
    NSMutableArray *breeders;
    NSString *databasePath;
}

- (NSInteger) count;
- (Breeder *) getBreedersAtIndex:(NSInteger)Index;
- (void) getBreedersFromZipCode:(NSString *) ZipCode MaxDistance: (NSInteger) Distance Latitude: (double) latitude Longitude: (double) longitude ForBreedID: (NSInteger) BreedID;
@end

#endif
