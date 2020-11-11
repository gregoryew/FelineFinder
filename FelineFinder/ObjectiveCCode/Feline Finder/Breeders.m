//
//  Breeders.m
//  Purrfect4U
//
//  Created by Gregory Williams on 6/18/15.
//  Copyright (c) 2015 Gregory Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "Breeders.h"

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

@implementation Breeder : NSObject

@synthesize breederID;
@synthesize breedName;
@synthesize name;
@synthesize webSite;
@synthesize phone;
@synthesize email;
@synthesize streetAddress;
@synthesize city;
@synthesize state;
@synthesize zipCode;
@synthesize cattery;
@synthesize longitude;
@synthesize latitude;

@end

@implementation BreedersList

- (NSInteger) count {
    return [breeders count];
}

- (Breeder *) getBreedersAtIndex:(NSInteger)Index {
    return breeders[Index];
}

- (void) getBreedersFromZipCode:(NSString *) ZipCode MaxDistance: (NSInteger) Distance Latitude: (double) latitude Longitude: (double) longitude ForBreedID: (NSInteger) BreedID {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    NSString *DBPath = @"";
    
    DBPath = [documentPath stringByAppendingString:@"/CatFinder.db"];
    
    FMDatabase *contactDB = [FMDatabase databaseWithPath:DBPath];
    
    breeders = [[NSMutableArray alloc] init];
    
    if ([contactDB open]) {
        sqlite3_create_function([contactDB sqliteHandle], "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
        
        NSLog(@"%@", [contactDB lastErrorMessage]);
        
        NSString *querySQL = @"select BreederID, BreedName, BreederName, WebSite, Phone, StreetAddress, City, State, ZipCode, Email, Catter, cast(distance(?, ?, z.longitude, z.latitude) as integer) dist, z.latitude, z.longitude from Breeders b1, Breed b2, ZipCodes z where b1.BreedID = b2.BreedID and b1.ZipCode = z.PostalCode and distance(?, ?, z.longitude, z.latitude) < ? and b2.BreedID = ? order by distance(?, ?, z.longitude, z.latitude)";
        
        NSMutableArray *args;
        
        args = [[NSMutableArray alloc] init];
        
        [args addObject:[NSNumber numberWithDouble:longitude]];
        [args addObject:[NSNumber numberWithDouble:latitude]];
        [args addObject:[NSNumber numberWithDouble:longitude]];
        [args addObject:[NSNumber numberWithDouble:latitude]];
        [args addObject:[NSNumber numberWithInteger:Distance]];
        [args addObject:[NSNumber numberWithInteger:BreedID]];
        [args addObject:[NSNumber numberWithDouble:longitude]];
        [args addObject:[NSNumber numberWithDouble:latitude]];
        
        FMResultSet *results  = [contactDB executeQuery:querySQL withArgumentsInArray: args];
        
        NSLog(@"%@", [contactDB lastErrorMessage]);
        
        while ([results next] == true) {
            Breeder *b;
            b = [[Breeder alloc] init];
            b.breederID = [results intForColumn:@"BreederID"];
            b.breedName = [results stringForColumn:@"BreedName"];
            b.state = [results stringForColumn:@"State"];
            b.name = [results stringForColumn:@"BreederName"];
            b.webSite = [results stringForColumn:@"WebSite"];
            b.phone = [results stringForColumn:@"Phone"];
            b.email = [results stringForColumn:@"Email"];
            b.streetAddress = [results stringForColumn:@"streetAddress"];
            b.city = [results stringForColumn:@"City"];
            b.zipCode = [results stringForColumn:@"ZipCode"];
            b.cattery = [results stringForColumn:@"Catter"];
            b.distance = [NSString stringWithFormat:@"%i", [results intForColumn:@"dist"]];
            b.latitude = [results doubleForColumn:@"latitude"];
            b.longitude = [results doubleForColumn:@"longitude"];
            
            if (b.breedName == nil) {b.breedName = @"";};
            if (b.state == nil) {b.state = @"";};
            if (b.name == nil) {b.name = @"";};
            if (b.webSite == nil) {b.webSite = @"";};
            if (b.phone == nil) {b.phone = @"";};
            if (b.email == nil) {b.email = @"";};
            if (b.streetAddress == nil) {b.streetAddress = @"";};
            if (b.city == nil) {b.city = @"";};
            if (b.zipCode == nil) {b.zipCode = @"";};
            if (b.cattery == nil) {b.cattery = @"";};
            
            [breeders addObject:b];
        }
        [contactDB close];

        if (breeders.count == 0) {
            Breeder *b;
            b = [[Breeder alloc] init];
            b.name = @"Sorry no breeders.";
            if (b.breedName == nil) {b.breedName = @"";};
            if (b.state == nil) {b.state = @"";};
            if (b.name == nil) {b.name = @"";};
            if (b.webSite == nil) {b.webSite = @"";};
            if (b.phone == nil) {b.phone = @"";};
            if (b.email == nil) {b.email = @"";};
            if (b.zipCode == nil) {b.zipCode = @"";};
            if (b.cattery == nil) {b.cattery = @"";};
            [breeders addObject: b];
        }

    } else {
        NSLog(@"%@", [contactDB lastErrorMessage]);
    }
}

static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    // check that we have four arguments (lat1, lon1, lat2, lon2)
    assert(argc == 4);
    // check that all four arguments are non-null
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    // get the four argument values
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    // convert lat1 and lat2 into radians now, to avoid doing it twice below
    double lat1rad = DEG2RAD(lat1);
    double lat2rad = DEG2RAD(lat2);
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1 * 0.621371);
}
@end