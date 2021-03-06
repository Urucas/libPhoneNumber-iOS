//
//  NBMetadataHelper.h
//  libPhoneNumber
//
//  Created by tabby on 2015. 2. 8..
//  Copyright (c) 2015년 ohtalk.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RingcNBPhoneNumberDefines.h"


@class RingcNBPhoneMetaData;

@interface RingcNBMetadataHelper : NSObject

+ (void)setTestMode:(BOOL)isMode;

+ (NSArray *)getAllMetadata;

+ (RingcNBPhoneMetaData *)getMetadataForNonGeographicalRegion:(NSNumber *)countryCallingCode;
+ (RingcNBPhoneMetaData *)getMetadataForRegion:(NSString *)regionCode;

+ (NSArray *)regionCodeFromCountryCode:(NSNumber *)countryCodeNumber;
+ (NSString *)countryCodeFromRegionCode:(NSString *)regionCode;

+ (NSString *)stringByTrimming:(NSString *)aString;
+ (NSString *)normalizeNonBreakingSpace:(NSString *)aString;

+ (BOOL)hasValue:(NSString *)string;

@end
