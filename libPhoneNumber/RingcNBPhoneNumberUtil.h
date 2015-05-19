//
//  NBPhoneNumberUtil.h
//  libPhoneNumber
//
//  Created by tabby on 2015. 2. 8..
//  Copyright (c) 2015년 ohtalk.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RingcNBPhoneNumberDefines.h"


@class RingcNBPhoneMetaData, RingcNBPhoneNumber;

@interface RingcNBPhoneNumberUtil : NSObject

// regular expressions
- (NSArray*)matchesByRegex:(NSString*)sourceString regex:(NSString*)pattern;
- (NSArray*)matchedStringByRegex:(NSString*)sourceString regex:(NSString*)pattern;
- (NSString*)replaceStringByRegex:(NSString*)sourceString regex:(NSString*)pattern withTemplate:(NSString*)templateString;
- (int)stringPositionByRegex:(NSString*)sourceString regex:(NSString*)pattern;

// libPhoneNumber Util functions
- (NSString*)convertAlphaCharactersInNumber:(NSString*)number;

- (NSString*)normalizePhoneNumber:(NSString*)phoneNumber;
- (NSString*)normalizeDigitsOnly:(NSString*)number;

- (BOOL)isNumberGeographical:(RingcNBPhoneNumber*)phoneNumber;

- (NSString*)extractPossibleNumber:(NSString*)phoneNumber;
- (NSNumber*)extractCountryCode:(NSString*)fullNumber nationalNumber:(NSString**)nationalNumber;
#if TARGET_OS_IPHONE
- (NSString *)countryCodeByCarrier;
#endif

- (NSString*)getNddPrefixForRegion:(NSString*)regionCode stripNonDigits:(BOOL)stripNonDigits;
- (NSString*)getNationalSignificantNumber:(RingcNBPhoneNumber*)phoneNumber;

- (NBEPhoneNumberType)getNumberType:(RingcNBPhoneNumber*)phoneNumber;

- (NSNumber*)getCountryCodeForRegion:(NSString*)regionCode;

- (NSString*)getRegionCodeForCountryCode:(NSNumber*)countryCallingCode;
- (NSArray*)getRegionCodesForCountryCode:(NSNumber*)countryCallingCode;
- (NSString*)getRegionCodeForNumber:(RingcNBPhoneNumber*)phoneNumber;

- (RingcNBPhoneNumber*)getExampleNumber:(NSString*)regionCode error:(NSError**)error;
- (RingcNBPhoneNumber*)getExampleNumberForType:(NSString*)regionCode type:(NBEPhoneNumberType)type error:(NSError**)error;
- (RingcNBPhoneNumber*)getExampleNumberForNonGeoEntity:(NSNumber*)countryCallingCode error:(NSError**)error;

- (BOOL)canBeInternationallyDialled:(RingcNBPhoneNumber*)number error:(NSError**)error;

- (BOOL)truncateTooLongNumber:(RingcNBPhoneNumber*)number;

- (BOOL)isValidNumber:(RingcNBPhoneNumber*)number;
- (BOOL)isViablePhoneNumber:(NSString*)phoneNumber;
- (BOOL)isAlphaNumber:(NSString*)number;
- (BOOL)isValidNumberForRegion:(RingcNBPhoneNumber*)number regionCode:(NSString*)regionCode;
- (BOOL)isNANPACountry:(NSString*)regionCode;
- (BOOL)isLeadingZeroPossible:(NSNumber*)countryCallingCode;

- (NBEValidationResult)isPossibleNumberWithReason:(RingcNBPhoneNumber*)number error:(NSError**)error;

- (BOOL)isPossibleNumber:(RingcNBPhoneNumber*)number error:(NSError**)error;
- (BOOL)isPossibleNumberString:(NSString*)number regionDialingFrom:(NSString*)regionDialingFrom error:(NSError**)error;

- (NBEMatchType)isNumberMatch:(id)firstNumberIn second:(id)secondNumberIn error:(NSError**)error;

- (int)getLengthOfGeographicalAreaCode:(RingcNBPhoneNumber*)phoneNumber error:(NSError**)error;
- (int)getLengthOfNationalDestinationCode:(RingcNBPhoneNumber*)phoneNumber error:(NSError**)error;

- (BOOL)maybeStripNationalPrefixAndCarrierCode:(NSString**)numberStr metadata:(RingcNBPhoneMetaData*)metadata carrierCode:(NSString**)carrierCode;
- (NBECountryCodeSource)maybeStripInternationalPrefixAndNormalize:(NSString**)numberStr possibleIddPrefix:(NSString*)possibleIddPrefix;

- (NSNumber*)maybeExtractCountryCode:(NSString*)number metadata:(RingcNBPhoneMetaData*)defaultRegionMetadata
                      nationalNumber:(NSString**)nationalNumber keepRawInput:(BOOL)keepRawInput
                         phoneNumber:(RingcNBPhoneNumber**)phoneNumber error:(NSError**)error;

- (RingcNBPhoneNumber*)parse:(NSString*)numberToParse defaultRegion:(NSString*)defaultRegion error:(NSError**)error;
- (RingcNBPhoneNumber*)parseAndKeepRawInput:(NSString*)numberToParse defaultRegion:(NSString*)defaultRegion error:(NSError**)error;
- (RingcNBPhoneNumber*)parseWithPhoneCarrierRegion:(NSString*)numberToParse error:(NSError**)error;

- (NSString*)format:(RingcNBPhoneNumber*)phoneNumber numberFormat:(NBEPhoneNumberFormat)numberFormat error:(NSError**)error;
- (NSString*)formatByPattern:(RingcNBPhoneNumber*)number numberFormat:(NBEPhoneNumberFormat)numberFormat userDefinedFormats:(NSArray*)userDefinedFormats error:(NSError**)error;
- (NSString*)formatNumberForMobileDialing:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom withFormatting:(BOOL)withFormatting error:(NSError**)error;
- (NSString*)formatOutOfCountryCallingNumber:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom error:(NSError**)error;
- (NSString*)formatOutOfCountryKeepingAlphaChars:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom error:(NSError**)error;
- (NSString*)formatNationalNumberWithCarrierCode:(RingcNBPhoneNumber*)number carrierCode:(NSString*)carrierCode error:(NSError**)error;
- (NSString*)formatInOriginalFormat:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom error:(NSError**)error;
- (NSString*)formatNationalNumberWithPreferredCarrierCode:(RingcNBPhoneNumber*)number fallbackCarrierCode:(NSString*)fallbackCarrierCode error:(NSError**)error;

- (BOOL)formattingRuleHasFirstGroupOnly:(NSString*)nationalPrefixFormattingRule;

@property (nonatomic, strong, readonly) NSDictionary *DIGIT_MAPPINGS;
@property (nonatomic, strong, readonly) NSBundle *libPhoneBundle;

@end
