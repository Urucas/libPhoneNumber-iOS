//
//  NBPhoneNumberUtilTests.m
//  NBPhoneNumberUtilTests
//
//

#import "NBPhoneNumberUtilTests.h"

#import "RingcNBMetadataHelper.h"
#import "RingcNBPhoneMetaData.h"
#import "RingcNBPhoneNumber.h"
#import "RingcNBPhoneNumberDesc.h"
#import "RingcNBPhoneNumberUtil.h"
#import "RingcNBNumberFormat.h"


@interface RingcNBPhoneNumberUtil (FOR_UNIT_TEST)

- (BOOL)canBeInternationallyDialled:(RingcNBPhoneNumber*)number;
- (BOOL)truncateTooLongNumber:(RingcNBPhoneNumber*)number;
- (NBEValidationResult)isPossibleNumberWithReason:(RingcNBPhoneNumber*)number;
- (BOOL)isPossibleNumber:(RingcNBPhoneNumber*)number;
- (NBEMatchType)isNumberMatch:(id)firstNumberIn second:(id)secondNumberIn;
- (int)getLengthOfGeographicalAreaCode:(RingcNBPhoneNumber*)phoneNumber;
- (int)getLengthOfNationalDestinationCode:(RingcNBPhoneNumber*)phoneNumber;
- (BOOL)maybeStripNationalPrefixAndCarrierCode:(NSString**)numberStr metadata:(RingcNBPhoneMetaData*)metadata carrierCode:(NSString**)carrierCode;
- (NBECountryCodeSource)maybeStripInternationalPrefixAndNormalize:(NSString**)numberStr possibleIddPrefix:(NSString*)possibleIddPrefix;
- (NSString*)format:(RingcNBPhoneNumber*)phoneNumber numberFormat:(NBEPhoneNumberFormat)numberFormat;
- (NSString*)formatByPattern:(RingcNBPhoneNumber*)number numberFormat:(NBEPhoneNumberFormat)numberFormat userDefinedFormats:(NSArray*)userDefinedFormats;
- (NSString*)formatNumberForMobileDialing:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom withFormatting:(BOOL)withFormatting;
- (NSString*)formatOutOfCountryCallingNumber:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom;
- (NSString*)formatOutOfCountryKeepingAlphaChars:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom;
- (NSString*)formatNationalNumberWithCarrierCode:(RingcNBPhoneNumber*)number carrierCode:(NSString*)carrierCode;
- (NSString*)formatInOriginalFormat:(RingcNBPhoneNumber*)number regionCallingFrom:(NSString*)regionCallingFrom;
- (NSString*)formatNationalNumberWithPreferredCarrierCode:(RingcNBPhoneNumber*)number fallbackCarrierCode:(NSString*)fallbackCarrierCode;

@end


@interface NBPhoneNumberUtilTests ()

@property (nonatomic, strong) RingcNBPhoneNumberUtil *aUtil;

@end


@implementation NBPhoneNumberUtilTests

- (void)setUp
{
    [super setUp];
    
    [RingcNBMetadataHelper setTestMode:YES];
    
    _aUtil = [[RingcNBPhoneNumberUtil alloc] init];
}

- (void)tearDown
{
    // ...
    
    [super tearDown];
}

- (NSString*)stringForNumberType:(NBEPhoneNumberType)type
{
    NSString *stringType = @"UNKNOWN";
    
    switch (type) {
        case 0: return @"FIXED_LINE";
        case 1: return @"MOBILE";
        case 2: return @"FIXED_LINE_OR_MOBILE";
        case 3: return @"TOLL_FREE";
        case 4: return @"PREMIUM_RATE";
        case 5: return @"SHARED_COST";
        case 6: return @"VOIP";
        case 7: return @"PERSONAL_NUMBER";
        case 8: return @"PAGER";
        case 9: return @"UAN";
        case 10: return @"VOICEMAIL";
        default:
            break;
    }
    
    return stringType;
}

- (NSString *)getPhoneNumberFormatted:(NSString *)phoneNumber
{
    NSString *retValue;
    RingcNBPhoneNumber *phoneNumberFormatted = [_aUtil parseWithPhoneCarrierRegion:phoneNumber error:nil];
    retValue = [_aUtil format:phoneNumberFormatted numberFormat:NBEPhoneNumberFormatRFC3966 error:nil];
    return retValue;
}

- (void)testForExtraDatas
{
    [RingcNBMetadataHelper setTestMode:NO];
    
    NSArray *arrayData = [RingcNBMetadataHelper getAllMetadata];
    if (arrayData && arrayData.count > 0) {
        NSLog(@"Log sample metadata [%@]", [arrayData firstObject]);
    } else {
        XCTFail(@"Fail to extract meta data");
    }
    
    [RingcNBMetadataHelper setTestMode:YES];
}

- (void)testCarrierRegion
{
    NSLog(@"testCarrierRegion %@", [self getPhoneNumberFormatted:@"1234567890"]);
}

// FIXME: This unit test ALWAYS FAIL ... until google libPhoneNumber fix this issue
- (void)testAustriaNationalNumberParsing
{
    [RingcNBMetadataHelper setTestMode:NO];
    
    NSError *anError = nil;
    
    NSString *internationalNumberForInput = @"436606545646";
    NSString *nationalNumberForExpect = @"6606545646";
    NSString *defaultRegion = @"AT";
    
    RingcNBPhoneNumber *phoneNumber = [_aUtil parse:internationalNumberForInput defaultRegion:defaultRegion error:&anError];
    NSString *nationalNumberForActual = [NSString stringWithFormat:@"%@", phoneNumber.nationalNumber];
    
    // ALWAYS FAIL need fix "google libPhoneNumber"
    XCTAssertEqualObjects(nationalNumberForExpect, nationalNumberForActual);
    
    [RingcNBMetadataHelper setTestMode:YES];
}

- (void)testForiOS7
{
    [RingcNBMetadataHelper setTestMode:NO];
    
    NSError *anError = nil;
    RingcNBPhoneNumber *myNumber = [_aUtil parse:@"0174 2340XXX" defaultRegion:@"DE" error:&anError];
    if (anError == nil) {
        NSLog(@"isValidPhoneNumber ? [%@]", [_aUtil isValidNumber:myNumber] ? @"YES":@"NO");
        NSLog(@"E164          : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&anError]);
        NSLog(@"INTERNATIONAL : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&anError]);
        NSLog(@"NATIONAL      : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatNATIONAL error:&anError]);
        NSLog(@"RFC3966       : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatRFC3966 error:&anError]);
    } else {
        NSLog(@"Error : %@", [anError localizedDescription]);
    }
    
    [RingcNBMetadataHelper setTestMode:YES];
}

- (void)testForGetMetadataForRegionTwice
{
    [RingcNBMetadataHelper getMetadataForRegion:@"US"];
    [RingcNBMetadataHelper getMetadataForRegion:@"KR"];
    [RingcNBMetadataHelper getMetadataForRegion:nil];
    [RingcNBMetadataHelper getMetadataForRegion:NULL];
    [RingcNBMetadataHelper getMetadataForRegion:@""];
    [RingcNBMetadataHelper getMetadataForRegion:0];
    [RingcNBMetadataHelper getMetadataForRegion:@" AU"];
    [RingcNBMetadataHelper getMetadataForRegion:@" JP        "];
}

- (void)testNSDictionaryalbeKey
{
    NSError *anError = nil;

    RingcNBPhoneNumber *myNumber1 = [_aUtil parse:@"971600123456" defaultRegion:@"AE" error:&anError];
    RingcNBPhoneNumber *myNumber2 = [_aUtil parse:@"5491187654321" defaultRegion:@"AR" error:&anError];
    RingcNBPhoneNumber *myNumber3 = [_aUtil parse:@"12423570000" defaultRegion:@"BS" error:&anError];
    RingcNBPhoneNumber *myNumber4 = [_aUtil parse:@"39236618300" defaultRegion:@"IT" error:&anError];
    RingcNBPhoneNumber *myNumber5 = [_aUtil parse:@"16502530000" defaultRegion:@"US" error:&anError];
    
    NSMutableDictionary *dicTest = [[NSMutableDictionary alloc] init];
    [dicTest setObject:@"AE" forKey:myNumber1];
    [dicTest setObject:@"AR" forKey:myNumber2];
    [dicTest setObject:@"BS" forKey:myNumber3];
    [dicTest setObject:@"IT" forKey:myNumber4];
    [dicTest setObject:@"US" forKey:myNumber5];
    
    NSLog(@"%@", [dicTest objectForKey:myNumber1]);
    NSLog(@"%@", [dicTest objectForKey:myNumber2]);
    NSLog(@"%@", [dicTest objectForKey:myNumber3]);
    NSLog(@"%@", [dicTest objectForKey:myNumber4]);
    NSLog(@"%@", [dicTest objectForKey:myNumber5]);
}


- (void)testWithRealData
{
#pragma mark - customTest
    NSLog(@"-------------- customTest");
    
    NSError *anError = nil;

    [RingcNBMetadataHelper setTestMode:NO];
    RingcNBPhoneNumber *myNumber = [_aUtil parse:@"6766077303" defaultRegion:@"AT" error:&anError];
    if (anError == nil)
    {
        NSLog(@"isValidPhoneNumber ? [%@]", [_aUtil isValidNumber:myNumber] ? @"YES":@"NO");
        NSLog(@"E164          : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&anError]);
        NSLog(@"INTERNATIONAL : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:&anError]);
        NSLog(@"NATIONAL      : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatNATIONAL error:&anError]);
        NSLog(@"RFC3966       : %@", [_aUtil format:myNumber numberFormat:NBEPhoneNumberFormatRFC3966 error:&anError]);
    }
    else
    {
        NSLog(@"Error : %@", [anError localizedDescription]);
    }
    
    NSLog (@"extractCountryCode [%ld]", (unsigned long)[_aUtil extractCountryCode:@"823213123123" nationalNumber:nil]);
    NSString *res = nil;
    NSNumber *dRes = [_aUtil extractCountryCode:@"823213123123" nationalNumber:&res];
    NSLog (@"extractCountryCode [%@] [%@]", dRes, res);
    
    [RingcNBMetadataHelper setTestMode:YES];
}


- (void)testWithTestData
{
    // NSError *anError = nil;
    
    // Set up some test numbers to re-use.
    // TODO: Rewrite this as static functions that return new numbers each time to
    // avoid any risk of accidental changes to mutable static state affecting many
    // tests.
    RingcNBPhoneNumber *ALPHA_NUMERIC_NUMBER = [[RingcNBPhoneNumber alloc] init];
    ALPHA_NUMERIC_NUMBER.countryCode = @1;
    ALPHA_NUMERIC_NUMBER.nationalNumber = @80074935247;
    
    RingcNBPhoneNumber *AE_UAN = [[RingcNBPhoneNumber alloc] init];
    AE_UAN.countryCode = @971;
    AE_UAN.nationalNumber = @600123456;
    
    RingcNBPhoneNumber *AR_MOBILE = [[RingcNBPhoneNumber alloc] init];
    AR_MOBILE.countryCode = @54;
    AR_MOBILE.nationalNumber = @91187654321;
    
    RingcNBPhoneNumber *AR_NUMBER = [[RingcNBPhoneNumber alloc] init];
    AR_NUMBER.countryCode = @54;
    AR_NUMBER.nationalNumber = @1187654321;
    
    RingcNBPhoneNumber *AU_NUMBER = [[RingcNBPhoneNumber alloc] init];
    AU_NUMBER.countryCode = @61;
    AU_NUMBER.nationalNumber = @236618300;
    
    RingcNBPhoneNumber *BS_MOBILE = [[RingcNBPhoneNumber alloc] init];
    BS_MOBILE.countryCode = @1;
    BS_MOBILE.nationalNumber = @2423570000;
    
    RingcNBPhoneNumber *BS_NUMBER = [[RingcNBPhoneNumber alloc] init];
    BS_NUMBER.countryCode = @1;
    BS_NUMBER.nationalNumber = @2423651234;
    
    // Note that this is the same as the example number for DE in the metadata.
    RingcNBPhoneNumber *DE_NUMBER = [[RingcNBPhoneNumber alloc] init];
    DE_NUMBER.countryCode = @49;
    DE_NUMBER.nationalNumber = @30123456;
    
    RingcNBPhoneNumber *DE_SHORT_NUMBER = [[RingcNBPhoneNumber alloc] init];
    DE_SHORT_NUMBER.countryCode = @49;
    DE_SHORT_NUMBER.nationalNumber = @1234;
    
    RingcNBPhoneNumber *GB_MOBILE = [[RingcNBPhoneNumber alloc] init];
    GB_MOBILE.countryCode = @44;
    GB_MOBILE.nationalNumber = @7912345678;
    
    RingcNBPhoneNumber *GB_NUMBER = [[RingcNBPhoneNumber alloc] init];
    GB_NUMBER.countryCode = @44;
    GB_NUMBER.nationalNumber = @2070313000;
    
    RingcNBPhoneNumber *IT_MOBILE = [[RingcNBPhoneNumber alloc] init];
    IT_MOBILE.countryCode = @39;
    IT_MOBILE.nationalNumber = @345678901;
    
    RingcNBPhoneNumber *IT_NUMBER = [[RingcNBPhoneNumber alloc] init];
    IT_NUMBER.countryCode = @39;
    IT_NUMBER.nationalNumber = @236618300;
    IT_NUMBER.italianLeadingZero = YES;
    
    RingcNBPhoneNumber *JP_STAR_NUMBER = [[RingcNBPhoneNumber alloc] init];
    JP_STAR_NUMBER.countryCode = @81;
    JP_STAR_NUMBER.nationalNumber = @2345;
    
    // Numbers to test the formatting rules from Mexico.
    RingcNBPhoneNumber *MX_MOBILE1 = [[RingcNBPhoneNumber alloc] init];
    MX_MOBILE1.countryCode = @52;
    MX_MOBILE1.nationalNumber = @12345678900;
    
    RingcNBPhoneNumber *MX_MOBILE2 = [[RingcNBPhoneNumber alloc] init];
    MX_MOBILE2.countryCode = @52;
    MX_MOBILE2.nationalNumber = @15512345678;
    
    RingcNBPhoneNumber *MX_NUMBER1 = [[RingcNBPhoneNumber alloc] init];
    MX_NUMBER1.countryCode = @52;
    MX_NUMBER1.nationalNumber = @3312345678;
    
    RingcNBPhoneNumber *MX_NUMBER2 = [[RingcNBPhoneNumber alloc] init];
    MX_NUMBER2.countryCode = @52;
    MX_NUMBER2.nationalNumber = @8211234567;
    
    RingcNBPhoneNumber *NZ_NUMBER = [[RingcNBPhoneNumber alloc] init];
    NZ_NUMBER.countryCode = @64;
    NZ_NUMBER.nationalNumber = @33316005;
    
    RingcNBPhoneNumber *SG_NUMBER = [[RingcNBPhoneNumber alloc] init];
    SG_NUMBER.countryCode = @65;
    SG_NUMBER.nationalNumber = @65218000;
    
    // A too-long and hence invalid US number.
    RingcNBPhoneNumber *US_LONG_NUMBER = [[RingcNBPhoneNumber alloc] init];
    US_LONG_NUMBER.countryCode = @1;
    US_LONG_NUMBER.nationalNumber = @65025300001;
    
    RingcNBPhoneNumber *US_NUMBER = [[RingcNBPhoneNumber alloc] init];
    US_NUMBER.countryCode = @1;
    US_NUMBER.nationalNumber = @6502530000;
    
    RingcNBPhoneNumber *US_PREMIUM = [[RingcNBPhoneNumber alloc] init];
    US_PREMIUM.countryCode = @1;
    US_PREMIUM.nationalNumber = @9002530000;
    
    // Too short, but still possible US numbers.
    RingcNBPhoneNumber *US_LOCAL_NUMBER = [[RingcNBPhoneNumber alloc] init];
    US_LOCAL_NUMBER.countryCode = @1;
    US_LOCAL_NUMBER.nationalNumber = @2530000;
    
    RingcNBPhoneNumber *US_SHORT_BY_ONE_NUMBER = [[RingcNBPhoneNumber alloc] init];
    US_SHORT_BY_ONE_NUMBER.countryCode = @1;
    US_SHORT_BY_ONE_NUMBER.nationalNumber = @650253000;
    
    RingcNBPhoneNumber *US_TOLLFREE = [[RingcNBPhoneNumber alloc] init];
    US_TOLLFREE.countryCode = @1;
    US_TOLLFREE.nationalNumber = @8002530000;
    
    RingcNBPhoneNumber *US_SPOOF = [[RingcNBPhoneNumber alloc] init];
    US_SPOOF.countryCode = @1;
    US_SPOOF.nationalNumber = @0;
    
    RingcNBPhoneNumber *US_SPOOF_WITH_RAW_INPUT = [[RingcNBPhoneNumber alloc] init];
    US_SPOOF_WITH_RAW_INPUT.countryCode = @1;
    US_SPOOF_WITH_RAW_INPUT.nationalNumber = @0;
    US_SPOOF_WITH_RAW_INPUT.rawInput = @"000-000-0000";
    
    RingcNBPhoneNumber *INTERNATIONAL_TOLL_FREE = [[RingcNBPhoneNumber alloc] init];
    INTERNATIONAL_TOLL_FREE.countryCode = @800;
    INTERNATIONAL_TOLL_FREE.nationalNumber = @12345678;
    
    // We set this to be the same length as numbers for the other non-geographical
    // country prefix that we have in our test metadata. However, this is not
    // considered valid because they differ in their country calling code.
    
    RingcNBPhoneNumber *INTERNATIONAL_TOLL_FREE_TOO_LONG = [[RingcNBPhoneNumber alloc] init];
    INTERNATIONAL_TOLL_FREE_TOO_LONG.countryCode = @800;
    INTERNATIONAL_TOLL_FREE_TOO_LONG.nationalNumber = @123456789;
    
    RingcNBPhoneNumber *UNIVERSAL_PREMIUM_RATE = [[RingcNBPhoneNumber alloc] init];
    UNIVERSAL_PREMIUM_RATE.countryCode = @979;
    UNIVERSAL_PREMIUM_RATE.nationalNumber = @123456789;
    
    RingcNBPhoneNumber *UNKNOWN_COUNTRY_CODE_NO_RAW_INPUT = [[RingcNBPhoneNumber alloc] init];
    UNKNOWN_COUNTRY_CODE_NO_RAW_INPUT.countryCode = @2;
    UNKNOWN_COUNTRY_CODE_NO_RAW_INPUT.nationalNumber = @12345;
    
    
    #pragma mark - testGetInstanceLoadUSMetadata
    {
        RingcNBPhoneMetaData *metadata = [RingcNBMetadataHelper getMetadataForRegion:@"US"];

        XCTAssertEqualObjects(@"US", metadata.codeID);
        XCTAssertEqualObjects(@1, metadata.countryCode);
        XCTAssertEqualObjects(@"011", metadata.internationalPrefix);
        XCTAssertTrue(metadata.nationalPrefix != nil);
        XCTAssertEqual(2, (int)[metadata.numberFormats count]);
        XCTAssertEqualObjects(@"(\\d{3})(\\d{3})(\\d{4})", ((RingcNBNumberFormat*)metadata.numberFormats[1]).pattern);
        XCTAssertEqualObjects(@"$1 $2 $3", ((RingcNBNumberFormat*)metadata.numberFormats[1]).format);
        XCTAssertEqualObjects(@"[13-689]\\d{9}|2[0-35-9]\\d{8}", metadata.generalDesc.nationalNumberPattern);
        XCTAssertEqualObjects(@"\\d{7}(?:\\d{3})?", metadata.generalDesc.possibleNumberPattern);
        XCTAssertTrue([metadata.generalDesc isEqual:metadata.fixedLine]);
        XCTAssertEqualObjects(@"\\d{10}", metadata.tollFree.possibleNumberPattern);
        XCTAssertEqualObjects(@"900\\d{7}", metadata.premiumRate.nationalNumberPattern);
        // No shared-cost data is available, so it should be initialised to 'NA'.
        XCTAssertEqualObjects(@"NA", metadata.sharedCost.nationalNumberPattern);
        XCTAssertEqualObjects(@"NA", metadata.sharedCost.possibleNumberPattern);
    }
                                           
    #pragma mark - testGetInstanceLoadDEMetadata
    {
        RingcNBPhoneMetaData *metadata = [RingcNBMetadataHelper getMetadataForRegion:@"DE"];
        XCTAssertEqualObjects(@"DE", metadata.codeID);
        XCTAssertEqualObjects(@49, metadata.countryCode);
        XCTAssertEqualObjects(@"00", metadata.internationalPrefix);
        XCTAssertEqualObjects(@"0", metadata.nationalPrefix);
        XCTAssertEqual(6, (int)[metadata.numberFormats count]);
        XCTAssertEqual(1, (int)[((RingcNBNumberFormat*)metadata.numberFormats[5]).leadingDigitsPatterns count]);
        XCTAssertEqualObjects(@"900", ((RingcNBNumberFormat*)metadata.numberFormats[5]).leadingDigitsPatterns[0]);
        XCTAssertEqualObjects(@"(\\d{3})(\\d{3,4})(\\d{4})", ((RingcNBNumberFormat*)metadata.numberFormats[5]).pattern);
        XCTAssertEqualObjects(@"$1 $2 $3", ((RingcNBNumberFormat*)metadata.numberFormats[5]).format);
        XCTAssertEqualObjects(@"(?:[24-6]\\d{2}|3[03-9]\\d|[789](?:[1-9]\\d|0[2-9]))\\d{1,8}", metadata.fixedLine.nationalNumberPattern);
        XCTAssertEqualObjects(@"\\d{2,14}", metadata.fixedLine.possibleNumberPattern);
        XCTAssertEqualObjects(@"30123456", metadata.fixedLine.exampleNumber);
        XCTAssertEqualObjects(@"\\d{10}", metadata.tollFree.possibleNumberPattern);
        XCTAssertEqualObjects(@"900([135]\\d{6}|9\\d{7})", metadata.premiumRate.nationalNumberPattern);
    }


    #pragma mark - testGetInstanceLoadARMetadata
    {
        RingcNBPhoneMetaData *metadata = [RingcNBMetadataHelper getMetadataForRegion:@"AR"];
        XCTAssertEqualObjects(@"AR", metadata.codeID);
        XCTAssertEqualObjects(@54, metadata.countryCode);
        XCTAssertEqualObjects(@"00", metadata.internationalPrefix);
        XCTAssertEqualObjects(@"0", metadata.nationalPrefix);
        XCTAssertEqualObjects(@"0(?:(11|343|3715)15)?", metadata.nationalPrefixForParsing);
        XCTAssertEqualObjects(@"9$1", metadata.nationalPrefixTransformRule);
        XCTAssertEqualObjects(@"$2 15 $3-$4", ((RingcNBNumberFormat*)metadata.numberFormats[2]).format);
        XCTAssertEqualObjects(@"(9)(\\d{4})(\\d{2})(\\d{4})", ((RingcNBNumberFormat*)metadata.numberFormats[3]).pattern);
        XCTAssertEqualObjects(@"(9)(\\d{4})(\\d{2})(\\d{4})", ((RingcNBNumberFormat*)metadata.intlNumberFormats[3]).pattern);
        XCTAssertEqualObjects(@"$1 $2 $3 $4", ((RingcNBNumberFormat*)metadata.intlNumberFormats[3]).format);
    }


    #pragma mark - testGetInstanceLoadInternationalTollFreeMetadata
    {
        RingcNBPhoneMetaData *metadata = [RingcNBMetadataHelper getMetadataForNonGeographicalRegion:@800];
        XCTAssertEqualObjects(@"001", metadata.codeID);
        XCTAssertEqualObjects(@800, metadata.countryCode);
        XCTAssertEqualObjects(@"$1 $2", ((RingcNBNumberFormat*)metadata.numberFormats[0]).format);
        XCTAssertEqualObjects(@"(\\d{4})(\\d{4})", ((RingcNBNumberFormat*)metadata.numberFormats[0]).pattern);
        XCTAssertEqualObjects(@"12345678", metadata.generalDesc.exampleNumber);
        XCTAssertEqualObjects(@"12345678", metadata.tollFree.exampleNumber);
    }
                                                                

    #pragma mark - testIsNumberGeographical
    {
        // Bahamas, mobile phone number.
        XCTAssertFalse([_aUtil isNumberGeographical:BS_MOBILE]);
        // Australian fixed line number.
        XCTAssertTrue([_aUtil isNumberGeographical:AU_NUMBER]);
        // International toll free number.
        XCTAssertFalse([_aUtil isNumberGeographical:INTERNATIONAL_TOLL_FREE]);
    }
                                                                

    #pragma mark - testIsLeadingZeroPossible
    {
        // Italy
        XCTAssertTrue([_aUtil isLeadingZeroPossible:@39]);
        // USA
        XCTAssertFalse([_aUtil isLeadingZeroPossible:@1]);
        // International toll free
        XCTAssertTrue([_aUtil isLeadingZeroPossible:@800]);
        // International premium-rate
        XCTAssertFalse([_aUtil isLeadingZeroPossible:@979]);
        // Not in metadata file, just default to false.
        XCTAssertFalse([_aUtil isLeadingZeroPossible:@888]);
    }
        

    #pragma mark - testgetLengthOfGeographicalAreaCode
    {
        // Google MTV, which has area code '650'.
        XCTAssertEqual(3, [_aUtil getLengthOfGeographicalAreaCode:US_NUMBER]);
        
        // A North America toll-free number, which has no area code.
        XCTAssertEqual(0, [_aUtil getLengthOfGeographicalAreaCode:US_TOLLFREE]);
        
        // Google London, which has area code '20'.
        XCTAssertEqual(2, [_aUtil getLengthOfGeographicalAreaCode:GB_NUMBER]);
        
        // A UK mobile phone, which has no area code.
        XCTAssertEqual(0, [_aUtil getLengthOfGeographicalAreaCode:GB_MOBILE]);
        
        // Google Buenos Aires, which has area code '11'.
        XCTAssertEqual(2, [_aUtil getLengthOfGeographicalAreaCode:AR_NUMBER]);
        
        // Google Sydney, which has area code '2'.
        XCTAssertEqual(1, [_aUtil getLengthOfGeographicalAreaCode:AU_NUMBER]);
        
        // Italian numbers - there is no national prefix, but it still has an area
        // code.
        XCTAssertEqual(2, [_aUtil getLengthOfGeographicalAreaCode:IT_NUMBER]);
        
        // Google Singapore. Singapore has no area code and no national prefix.
        XCTAssertEqual(0, [_aUtil getLengthOfGeographicalAreaCode:SG_NUMBER]);
        
        // An invalid US number (1 digit shorter), which has no area code.
        XCTAssertEqual(0, [_aUtil getLengthOfGeographicalAreaCode:US_SHORT_BY_ONE_NUMBER]);
        
        // An international toll free number, which has no area code.
        XCTAssertEqual(0, [_aUtil getLengthOfGeographicalAreaCode:INTERNATIONAL_TOLL_FREE]);
    }

    
    #pragma mark - testGetLengthOfNationalDestinationCode
    {
        // Google MTV, which has national destination code (NDC) '650'.
        XCTAssertEqual(3, [_aUtil getLengthOfNationalDestinationCode:US_NUMBER]);
        
        // A North America toll-free number, which has NDC '800'.
        XCTAssertEqual(3, [_aUtil getLengthOfNationalDestinationCode:US_TOLLFREE]);
        
        // Google London, which has NDC '20'.
        XCTAssertEqual(2, [_aUtil getLengthOfNationalDestinationCode:GB_NUMBER]);
        
        // A UK mobile phone, which has NDC '7912'.
        XCTAssertEqual(4, [_aUtil getLengthOfNationalDestinationCode:GB_MOBILE]);
        
        // Google Buenos Aires, which has NDC '11'.
        XCTAssertEqual(2, [_aUtil getLengthOfNationalDestinationCode:AR_NUMBER]);
        
        // An Argentinian mobile which has NDC '911'.
        XCTAssertEqual(3, [_aUtil getLengthOfNationalDestinationCode:AR_MOBILE]);
        
        // Google Sydney, which has NDC '2'.
        XCTAssertEqual(1, [_aUtil getLengthOfNationalDestinationCode:AU_NUMBER]);
        
        // Google Singapore, which has NDC '6521'.
        XCTAssertEqual(4, [_aUtil getLengthOfNationalDestinationCode:SG_NUMBER]);
        
        // An invalid US number (1 digit shorter), which has no NDC.
        XCTAssertEqual(0,
                     [_aUtil getLengthOfNationalDestinationCode:US_SHORT_BY_ONE_NUMBER]);
        
        // A number containing an invalid country calling code, which shouldn't have
        // any NDC.
        
        RingcNBPhoneNumber *number = [[RingcNBPhoneNumber alloc] init];
        [number setCountryCode:@123];
        [number setNationalNumber:@6502530000];
        XCTAssertEqual(0, [_aUtil getLengthOfNationalDestinationCode:number]);
        
        // An international toll free number, which has NDC '1234'.
        XCTAssertEqual(4, [_aUtil getLengthOfNationalDestinationCode:INTERNATIONAL_TOLL_FREE]);
    }
        
    #pragma mark - testGetNationalSignificantNumber
    {
        XCTAssertEqualObjects(@"6502530000", [_aUtil getNationalSignificantNumber:US_NUMBER]);
        
        // An Italian mobile number.
        XCTAssertEqualObjects(@"345678901", [_aUtil getNationalSignificantNumber:IT_MOBILE]);
        
        // An Italian fixed line number.
        XCTAssertEqualObjects(@"0236618300", [_aUtil getNationalSignificantNumber:IT_NUMBER]);
        
        XCTAssertEqualObjects(@"12345678", [_aUtil getNationalSignificantNumber:INTERNATIONAL_TOLL_FREE]);
    }

    
    #pragma mark - testGetExampleNumber
    {
        XCTAssertTrue([DE_NUMBER isEqual:[_aUtil getExampleNumber:@"DE" error:nil]]);
        
        XCTAssertTrue([DE_NUMBER isEqual:[_aUtil getExampleNumberForType:@"DE" type:NBEPhoneNumberTypeFIXED_LINE error:nil]]);
        XCTAssertNil([_aUtil getExampleNumberForType:@"DE" type:NBEPhoneNumberTypeMOBILE error:nil]);
        // For the US, the example number is placed under general description, and
        // hence should be used for both fixed line and mobile, so neither of these
        // should return nil.
        XCTAssertNotNil([_aUtil getExampleNumberForType:@"US" type:NBEPhoneNumberTypeFIXED_LINE error:nil]);
        XCTAssertNotNil([_aUtil getExampleNumberForType:@"US" type:NBEPhoneNumberTypeMOBILE error:nil]);
        // CS is an invalid region, so we have no data for it.
        XCTAssertNil([_aUtil getExampleNumberForType:@"CS" type:NBEPhoneNumberTypeMOBILE error:nil]);
        // RegionCode 001 is reserved for supporting non-geographical country calling
        // code. We don't support getting an example number for it with this method.
        XCTAssertNil([_aUtil getExampleNumber:@"001" error:nil]);
    }

    
    #pragma mark - testexampleNumberForNonGeoEntity
    {
        XCTAssertTrue([INTERNATIONAL_TOLL_FREE isEqual:[_aUtil getExampleNumberForNonGeoEntity:@800 error:nil]]);
        XCTAssertTrue([UNIVERSAL_PREMIUM_RATE isEqual:[_aUtil getExampleNumberForNonGeoEntity:@979 error:nil]]);
    }

    
    #pragma mark - testConvertAlphaCharactersInNumber
    {
        NSString *input = @"1800-ABC-DEF";
        // Alpha chars are converted to digits; everything else is left untouched.
        
        NSString *expectedOutput = @"1800-222-333";
        XCTAssertEqualObjects(expectedOutput, [_aUtil convertAlphaCharactersInNumber:input]);
    }

    
    #pragma mark - testNormaliseRemovePunctuation
    {
        NSString *inputNumber = @"034-56&+#2\u00AD34";
        NSString *expectedOutput = @"03456234";
        XCTAssertEqualObjects(expectedOutput, [_aUtil normalizePhoneNumber:inputNumber], @"Conversion did not correctly remove punctuation");
    }

    
    #pragma mark - testNormaliseReplaceAlphaCharacters
    {
        NSString *inputNumber = @"034-I-am-HUNGRY";
        NSString *expectedOutput = @"034426486479";
        XCTAssertEqualObjects(expectedOutput, [_aUtil normalizePhoneNumber:inputNumber], @"Conversion did not correctly replace alpha characters");
    }

    
    #pragma mark - testNormaliseOtherDigits
    {
        NSString *inputNumber = @"\uFF125\u0665";
        NSString *expectedOutput = @"255";
        XCTAssertEqualObjects(expectedOutput, [_aUtil normalizePhoneNumber:inputNumber], @"Conversion did not correctly replace non-latin digits");
        // Eastern-Arabic digits.
        inputNumber = @"\u06F52\u06F0";
        expectedOutput = @"520";
        XCTAssertEqualObjects(expectedOutput, [_aUtil normalizePhoneNumber:inputNumber], @"Conversion did not correctly replace non-latin digits");
    }

    
    #pragma mark - testNormaliseStripAlphaCharacters
    {
        NSString *inputNumber = @"034-56&+a#234";
        NSString *expectedOutput = @"03456234";
        XCTAssertEqualObjects(expectedOutput, [_aUtil normalizeDigitsOnly:inputNumber], @"Conversion did not correctly remove alpha character");
    }

    
    #pragma mark - testFormatUSNumber
    {
        XCTAssertEqualObjects(@"650 253 0000", [_aUtil format:US_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+1 650 253 0000", [_aUtil format:US_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"800 253 0000", [_aUtil format:US_TOLLFREE numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+1 800 253 0000", [_aUtil format:US_TOLLFREE numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"900 253 0000", [_aUtil format:US_PREMIUM numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+1 900 253 0000", [_aUtil format:US_PREMIUM numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"tel:+1-900-253-0000", [_aUtil format:US_PREMIUM numberFormat:NBEPhoneNumberFormatRFC3966]);
        // Numbers with all zeros in the national number part will be formatted by
        // using the raw_input if that is available no matter which format is
        // specified.
        XCTAssertEqualObjects(@"000-000-0000", [_aUtil format:US_SPOOF_WITH_RAW_INPUT numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"0", [_aUtil format:US_SPOOF numberFormat:NBEPhoneNumberFormatNATIONAL]);
    }

    
    #pragma mark - testFormatBSNumber
    {
        XCTAssertEqualObjects(@"242 365 1234", [_aUtil format:BS_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+1 242 365 1234", [_aUtil format:BS_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
    }
    

    #pragma mark - testFormatGBNumber
    {
        XCTAssertEqualObjects(@"(020) 7031 3000", [_aUtil format:GB_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+44 20 7031 3000", [_aUtil format:GB_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"(07912) 345 678", [_aUtil format:GB_MOBILE numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+44 7912 345 678", [_aUtil format:GB_MOBILE numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
    }
    

    #pragma mark - testFormatDENumber
    {
        id deNumber = [[RingcNBPhoneNumber alloc] init];
        [deNumber setCountryCode:@49];
        [deNumber setNationalNumber:@301234];
        XCTAssertEqualObjects(@"030/1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+49 30/1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"tel:+49-30-1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatRFC3966]);
        
        deNumber = [[RingcNBPhoneNumber alloc] init];
        [deNumber setCountryCode:@49];
        [deNumber setNationalNumber:@291123];
        XCTAssertEqualObjects(@"0291 123", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+49 291 123", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        
        deNumber = [[RingcNBPhoneNumber alloc] init];
        [deNumber setCountryCode:@49];
        [deNumber setNationalNumber:@29112345678];
        XCTAssertEqualObjects(@"0291 12345678", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+49 291 12345678", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        
        deNumber = [[RingcNBPhoneNumber alloc] init];
        [deNumber setCountryCode:@49];
        [deNumber setNationalNumber:@912312345];
        XCTAssertEqualObjects(@"09123 12345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+49 9123 12345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        
        deNumber = [[RingcNBPhoneNumber alloc] init];
        [deNumber setCountryCode:@49];
        [deNumber setNationalNumber:@80212345];
        XCTAssertEqualObjects(@"08021 2345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+49 8021 2345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        
        // Note this number is correctly formatted without national prefix. Most of
        // the numbers that are treated as invalid numbers by the library are short
        // numbers, and they are usually not dialed with national prefix.
        XCTAssertEqualObjects(@"1234", [_aUtil format:DE_SHORT_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+49 1234", [_aUtil format:DE_SHORT_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        
        deNumber = [[RingcNBPhoneNumber alloc] init];
        [deNumber setCountryCode:@49];
        [deNumber setNationalNumber:@41341234];
        XCTAssertEqualObjects(@"04134 1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
    }

    #pragma mark - testFormatITNumber
    {
        XCTAssertEqualObjects(@"02 3661 8300", [_aUtil format:IT_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+39 02 3661 8300", [_aUtil format:IT_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+390236618300", [_aUtil format:IT_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"345 678 901", [_aUtil format:IT_MOBILE numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+39 345 678 901", [_aUtil format:IT_MOBILE numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+39345678901", [_aUtil format:IT_MOBILE numberFormat:NBEPhoneNumberFormatE164]);
    }

    #pragma mark - testFormatAUNumber
    {
        XCTAssertEqualObjects(@"02 3661 8300", [_aUtil format:AU_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+61 2 3661 8300", [_aUtil format:AU_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+61236618300", [_aUtil format:AU_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
        
        id auNumber = [[RingcNBPhoneNumber alloc] init];
        [auNumber setCountryCode:@61];
        [auNumber setNationalNumber:@1800123456];
        XCTAssertEqualObjects(@"1800 123 456", [_aUtil format:auNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+61 1800 123 456", [_aUtil format:auNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+611800123456", [_aUtil format:auNumber numberFormat:NBEPhoneNumberFormatE164]);
    }

    #pragma mark - testFormatARNumber
    {
        XCTAssertEqualObjects(@"011 8765-4321", [_aUtil format:AR_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+54 11 8765-4321", [_aUtil format:AR_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+541187654321", [_aUtil format:AR_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"011 15 8765-4321", [_aUtil format:AR_MOBILE numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+54 9 11 8765 4321", [_aUtil format:AR_MOBILE numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+5491187654321", [_aUtil format:AR_MOBILE numberFormat:NBEPhoneNumberFormatE164]);
    }

    #pragma mark - testFormatMXNumber
    {
        XCTAssertEqualObjects(@"045 234 567 8900", [_aUtil format:MX_MOBILE1 numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+52 1 234 567 8900", [_aUtil format:MX_MOBILE1 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+5212345678900", [_aUtil format:MX_MOBILE1 numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"045 55 1234 5678", [_aUtil format:MX_MOBILE2 numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+52 1 55 1234 5678", [_aUtil format:MX_MOBILE2 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+5215512345678", [_aUtil format:MX_MOBILE2 numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"01 33 1234 5678", [_aUtil format:MX_NUMBER1 numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+52 33 1234 5678", [_aUtil format:MX_NUMBER1 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+523312345678", [_aUtil format:MX_NUMBER1 numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"01 821 123 4567", [_aUtil format:MX_NUMBER2 numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"+52 821 123 4567", [_aUtil format:MX_NUMBER2 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+528211234567", [_aUtil format:MX_NUMBER2 numberFormat:NBEPhoneNumberFormatE164]);
    }

    #pragma mark - testFormatOutOfCountryCallingNumber
    {
        XCTAssertEqualObjects(@"00 1 900 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_PREMIUM regionCallingFrom:@"DE"]);
        XCTAssertEqualObjects(@"1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"BS"]);
        XCTAssertEqualObjects(@"00 1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"PL"]);
        XCTAssertEqualObjects(@"011 44 7912 345 678", [_aUtil formatOutOfCountryCallingNumber:GB_MOBILE regionCallingFrom:@"US"]);
        XCTAssertEqualObjects(@"00 49 1234", [_aUtil formatOutOfCountryCallingNumber:DE_SHORT_NUMBER regionCallingFrom:@"GB"]);
        // Note this number is correctly formatted without national prefix. Most of
        // the numbers that are treated as invalid numbers by the library are short
        // numbers, and they are usually not dialed with national prefix.
        XCTAssertEqualObjects(@"1234", [_aUtil formatOutOfCountryCallingNumber:DE_SHORT_NUMBER regionCallingFrom:@"DE"]);
        XCTAssertEqualObjects(@"011 39 02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"US"]);
        XCTAssertEqualObjects(@"02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"IT"]);
        XCTAssertEqualObjects(@"+39 02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"SG"]);
        XCTAssertEqualObjects(@"6521 8000", [_aUtil formatOutOfCountryCallingNumber:SG_NUMBER regionCallingFrom:@"SG"]);
        XCTAssertEqualObjects(@"011 54 9 11 8765 4321", [_aUtil formatOutOfCountryCallingNumber:AR_MOBILE regionCallingFrom:@"US"]);
        XCTAssertEqualObjects(@"011 800 1234 5678", [_aUtil formatOutOfCountryCallingNumber:INTERNATIONAL_TOLL_FREE regionCallingFrom:@"US"]);
        
        id arNumberWithExtn = [AR_MOBILE copy];
        [arNumberWithExtn setExtension:@"1234"];
        XCTAssertEqualObjects(@"011 54 9 11 8765 4321 ext. 1234", [_aUtil formatOutOfCountryCallingNumber:arNumberWithExtn regionCallingFrom:@"US"]);
        XCTAssertEqualObjects(@"0011 54 9 11 8765 4321 ext. 1234", [_aUtil formatOutOfCountryCallingNumber:arNumberWithExtn regionCallingFrom:@"AU"]);
        XCTAssertEqualObjects(@"011 15 8765-4321 ext. 1234", [_aUtil formatOutOfCountryCallingNumber:arNumberWithExtn regionCallingFrom:@"AR"]);
    }

    
    #pragma mark - testFormatOutOfCountryWithInvalidRegion
    {
        // AQ/Antarctica isn't a valid region code for phone number formatting,
        // so this falls back to intl formatting.
        XCTAssertEqualObjects(@"+1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"AQ"]);
        // For region code 001, the out-of-country format always turns into the
        // international format.
        XCTAssertEqualObjects(@"+1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"001"]);
    }
    

    #pragma mark - testFormatOutOfCountryWithPreferredIntlPrefix
    {
        // This should use 0011, since that is the preferred international prefix
        // (both 0011 and 0012 are accepted as possible international prefixes in our
        // test metadta.)
        XCTAssertEqualObjects(@"0011 39 02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"AU"]);
    }
    

    #pragma mark - testFormatOutOfCountryKeepingAlphaChars
    {
        id alphaNumericNumber = [[RingcNBPhoneNumber alloc] init];
        [alphaNumericNumber setCountryCode:@1];
        [alphaNumericNumber setNationalNumber:@8007493524];
        [alphaNumericNumber setRawInput:@"1800 six-flag"];
        XCTAssertEqualObjects(@"0011 1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        [alphaNumericNumber setRawInput:@"1-800-SIX-flag"];
        XCTAssertEqualObjects(@"0011 1 800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        [alphaNumericNumber setRawInput:@"Call us from UK: 00 1 800 SIX-flag"];
        XCTAssertEqualObjects(@"0011 1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        [alphaNumericNumber setRawInput:@"800 SIX-flag"];
        XCTAssertEqualObjects(@"0011 1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        // Formatting from within the NANPA region.
        XCTAssertEqualObjects(@"1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"US"]);
        XCTAssertEqualObjects(@"1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"BS"]);
        
        // Testing that if the raw input doesn't exist, it is formatted using
        // formatOutOfCountryCallingNumber.
        [alphaNumericNumber setRawInput:nil];
        XCTAssertEqualObjects(@"00 1 800 749 3524", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"DE"]);
        
        // Testing AU alpha number formatted from Australia.
        [alphaNumericNumber setCountryCode:@61];
        [alphaNumericNumber setNationalNumber:@827493524];
        [alphaNumericNumber setRawInput:@"+61 82749-FLAG"];
        // This number should have the national prefix fixed.
        XCTAssertEqualObjects(@"082749-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        [alphaNumericNumber setRawInput:@"082749-FLAG"];
        XCTAssertEqualObjects(@"082749-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        [alphaNumericNumber setNationalNumber:@18007493524];
        [alphaNumericNumber setRawInput:@"1-800-SIX-flag"];
        // This number should not have the national prefix prefixed, in accordance
        // with the override for this specific formatting rule.
        XCTAssertEqualObjects(@"1-800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        // The metadata should not be permanently changed, since we copied it before
        // modifying patterns. Here we check this.
        [alphaNumericNumber setNationalNumber:@1800749352];
        XCTAssertEqualObjects(@"1800 749 352", [_aUtil formatOutOfCountryCallingNumber:alphaNumericNumber regionCallingFrom:@"AU"]);
        
        // Testing a region with multiple international prefixes.
        XCTAssertEqualObjects(@"+61 1-800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"SG"]);
        // Testing the case of calling from a non-supported region.
        XCTAssertEqualObjects(@"+61 1-800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AQ"]);
        
        // Testing the case with an invalid country calling code.
        [alphaNumericNumber setCountryCode:0];
        [alphaNumericNumber setNationalNumber:@18007493524];
        [alphaNumericNumber setRawInput:@"1-800-SIX-flag"];
        // Uses the raw input only.
        XCTAssertEqualObjects(@"1-800-SIX-flag", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"DE"]);
        
        // Testing the case of an invalid alpha number.
        [alphaNumericNumber setCountryCode:@1];
        [alphaNumericNumber setNationalNumber:@80749];
        [alphaNumericNumber setRawInput:@"180-SIX"];
        // No country-code stripping can be done.
        XCTAssertEqualObjects(@"00 1 180-SIX", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"DE"]);
        
        // Testing the case of calling from a non-supported region.
        [alphaNumericNumber setCountryCode:@1];
        [alphaNumericNumber setNationalNumber:@80749];
        [alphaNumericNumber setRawInput:@"180-SIX"];
        // No country-code stripping can be done since the number is invalid.
        XCTAssertEqualObjects(@"+1 180-SIX", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AQ"]);
    }
    

    #pragma mark - testFormatWithCarrierCode()
    {
        // We only support this for AR in our test metadata, and only for mobile
        // numbers starting with certain values.
        
        RingcNBPhoneNumber *arMobile = [[RingcNBPhoneNumber alloc] init];
        [arMobile setCountryCode:@54];
        [arMobile setNationalNumber:@92234654321];
        XCTAssertEqualObjects(@"02234 65-4321", [_aUtil format:arMobile numberFormat:NBEPhoneNumberFormatNATIONAL]);
        // Here we force 14 as the carrier code.
        XCTAssertEqualObjects(@"02234 14 65-4321", [_aUtil formatNationalNumberWithCarrierCode:arMobile carrierCode:@"14"]);
        // Here we force the number to be shown with no carrier code.
        XCTAssertEqualObjects(@"02234 65-4321", [_aUtil formatNationalNumberWithCarrierCode:arMobile carrierCode:@""]);
        // Here the international rule is used, so no carrier code should be present.
        XCTAssertEqualObjects(@"+5492234654321", [_aUtil format:arMobile numberFormat:NBEPhoneNumberFormatE164]);
        // We don't support this for the US so there should be no change.
        XCTAssertEqualObjects(@"650 253 0000", [_aUtil formatNationalNumberWithCarrierCode:US_NUMBER carrierCode:@"15"]);
        // Invalid country code should just get the NSN.
        XCTAssertEqualObjects(@"12345", [_aUtil formatNationalNumberWithCarrierCode:UNKNOWN_COUNTRY_CODE_NO_RAW_INPUT carrierCode:@"89"]);
    }
    

    #pragma mark - testFormatWithPreferredCarrierCode
    {
        // We only support this for AR in our test metadata.
        
        RingcNBPhoneNumber *arNumber = [[RingcNBPhoneNumber alloc] init];
        [arNumber setCountryCode:@54];
        [arNumber setNationalNumber:@91234125678];
        // Test formatting with no preferred carrier code stored in the number itself.
        XCTAssertEqualObjects(@"01234 15 12-5678", [_aUtil formatNationalNumberWithPreferredCarrierCode:arNumber fallbackCarrierCode:@"15"]);
        XCTAssertEqualObjects(@"01234 12-5678", [_aUtil formatNationalNumberWithPreferredCarrierCode:arNumber fallbackCarrierCode:@""]);
        // Test formatting with preferred carrier code present.
        [arNumber setPreferredDomesticCarrierCode:@"19"];
        XCTAssertEqualObjects(@"01234 12-5678", [_aUtil format:arNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"01234 19 12-5678", [_aUtil formatNationalNumberWithPreferredCarrierCode:arNumber fallbackCarrierCode:@"15"]);
        XCTAssertEqualObjects(@"01234 19 12-5678", [_aUtil formatNationalNumberWithPreferredCarrierCode:arNumber fallbackCarrierCode:@""]);
        // When the preferred_domestic_carrier_code is present (even when it contains
        // an empty string), use it instead of the default carrier code passed in.
        [arNumber setPreferredDomesticCarrierCode:@""];
        XCTAssertEqualObjects(@"01234 12-5678", [_aUtil formatNationalNumberWithPreferredCarrierCode:arNumber fallbackCarrierCode:@"15"]);
        // We don't support this for the US so there should be no change.
        
        RingcNBPhoneNumber *usNumber = [[RingcNBPhoneNumber alloc] init];
        [usNumber setCountryCode:@1];
        [usNumber setNationalNumber:@4241231234];
        [usNumber setPreferredDomesticCarrierCode:@"99"];
        XCTAssertEqualObjects(@"424 123 1234", [_aUtil format:usNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqualObjects(@"424 123 1234", [_aUtil formatNationalNumberWithPreferredCarrierCode:usNumber fallbackCarrierCode:@"15"]);
    }
    

    #pragma mark - testFormatNumberForMobileDialing
    {
        // Numbers are normally dialed in national format in-country, and
        // international format from outside the country.
        XCTAssertEqualObjects(@"030123456", [_aUtil formatNumberForMobileDialing:DE_NUMBER regionCallingFrom:@"DE" withFormatting:NO]);
        XCTAssertEqualObjects(@"+4930123456", [_aUtil formatNumberForMobileDialing:DE_NUMBER regionCallingFrom:@"CH" withFormatting:NO]);
        id deNumberWithExtn = [DE_NUMBER copy];
        [deNumberWithExtn setExtension:@"1234"];
        XCTAssertEqualObjects(@"030123456", [_aUtil formatNumberForMobileDialing:deNumberWithExtn regionCallingFrom:@"DE" withFormatting:NO]);
        XCTAssertEqualObjects(@"+4930123456", [_aUtil formatNumberForMobileDialing:deNumberWithExtn regionCallingFrom:@"CH" withFormatting:NO]);
        
        // US toll free numbers are marked as noInternationalDialling in the test
        // metadata for testing purposes.
        XCTAssertEqualObjects(@"800 253 0000", [_aUtil formatNumberForMobileDialing:US_TOLLFREE regionCallingFrom:@"US" withFormatting:YES]);
        XCTAssertEqualObjects(@"", [_aUtil formatNumberForMobileDialing:US_TOLLFREE regionCallingFrom:@"CN" withFormatting:YES]);
        XCTAssertEqualObjects(@"+1 650 253 0000", [_aUtil formatNumberForMobileDialing:US_NUMBER regionCallingFrom:@"US" withFormatting:YES]);
        
        id usNumberWithExtn = [US_NUMBER copy];
        [usNumberWithExtn setExtension:@"1234"];
        XCTAssertEqualObjects(@"+1 650 253 0000", [_aUtil formatNumberForMobileDialing:usNumberWithExtn regionCallingFrom:@"US" withFormatting:YES]);
        XCTAssertEqualObjects(@"8002530000", [_aUtil formatNumberForMobileDialing:US_TOLLFREE regionCallingFrom:@"US" withFormatting:NO]);
        XCTAssertEqualObjects(@"", [_aUtil formatNumberForMobileDialing:US_TOLLFREE regionCallingFrom:@"CN" withFormatting:NO]);
        XCTAssertEqualObjects(@"+16502530000", [_aUtil formatNumberForMobileDialing:US_NUMBER regionCallingFrom:@"US" withFormatting:NO]);
        XCTAssertEqualObjects(@"+16502530000", [_aUtil formatNumberForMobileDialing:usNumberWithExtn regionCallingFrom:@"US" withFormatting:NO]);

        // An invalid US number, which is one digit too long.
        XCTAssertEqualObjects(@"+165025300001", [_aUtil formatNumberForMobileDialing:US_LONG_NUMBER regionCallingFrom:@"US" withFormatting:NO]);
        XCTAssertEqualObjects(@"+1 65025300001", [_aUtil formatNumberForMobileDialing:US_LONG_NUMBER regionCallingFrom:@"US" withFormatting:YES]);

        // Star numbers. In real life they appear in Israel, but we have them in JP
        // in our test metadata.
        XCTAssertEqualObjects(@"*2345", [_aUtil formatNumberForMobileDialing:JP_STAR_NUMBER regionCallingFrom:@"JP" withFormatting:NO]);
        XCTAssertEqualObjects(@"*2345", [_aUtil formatNumberForMobileDialing:JP_STAR_NUMBER regionCallingFrom:@"JP" withFormatting:YES]);
        XCTAssertEqualObjects(@"+80012345678", [_aUtil formatNumberForMobileDialing:INTERNATIONAL_TOLL_FREE regionCallingFrom:@"JP" withFormatting:NO]);
        XCTAssertEqualObjects(@"+800 1234 5678", [_aUtil formatNumberForMobileDialing:INTERNATIONAL_TOLL_FREE regionCallingFrom:@"JP" withFormatting:YES]);
        
        // UAE numbers beginning with 600 (classified as UAN) need to be dialled
        // without +971 locally.
        XCTAssertEqualObjects(@"+971600123456", [_aUtil formatNumberForMobileDialing:AE_UAN regionCallingFrom:@"JP" withFormatting:NO]);
        XCTAssertEqualObjects(@"600123456", [_aUtil formatNumberForMobileDialing:AE_UAN regionCallingFrom:@"AE" withFormatting:NO]);
        XCTAssertEqualObjects(@"+523312345678",
                             [_aUtil formatNumberForMobileDialing:MX_NUMBER1 regionCallingFrom:@"MX" withFormatting:NO]);
        XCTAssertEqualObjects(@"+523312345678",
                             [_aUtil formatNumberForMobileDialing:MX_NUMBER1 regionCallingFrom:@"US" withFormatting:NO]);
        
        // Non-geographical numbers should always be dialed in international format.
        XCTAssertEqualObjects(@"+80012345678", [_aUtil formatNumberForMobileDialing:INTERNATIONAL_TOLL_FREE regionCallingFrom:@"US" withFormatting:NO]);
        XCTAssertEqualObjects(@"+80012345678", [_aUtil formatNumberForMobileDialing:INTERNATIONAL_TOLL_FREE regionCallingFrom:@"UN001" withFormatting:NO]);

    }

    
    #pragma mark - testFormatByPattern
    {
        RingcNBNumberFormat *newNumFormat = [[RingcNBNumberFormat alloc] init];
        [newNumFormat setPattern:@"(\\d{3})(\\d{3})(\\d{4})"];
        [newNumFormat setFormat:@"($1) $2-$3"];
        
        XCTAssertEqualObjects(@"(650) 253-0000", [_aUtil formatByPattern:US_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL userDefinedFormats:@[newNumFormat]]);
        
        XCTAssertEqualObjects(@"+1 (650) 253-0000", [_aUtil formatByPattern:US_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL userDefinedFormats:@[newNumFormat]]);
        XCTAssertEqualObjects(@"tel:+1-650-253-0000", [_aUtil formatByPattern:US_NUMBER numberFormat:NBEPhoneNumberFormatRFC3966 userDefinedFormats:@[newNumFormat]]);
        
        // $NP is set to '1' for the US. Here we check that for other NANPA countries
        // the US rules are followed.
        [newNumFormat setNationalPrefixFormattingRule:@"$NP ($FG)"];
        [newNumFormat setFormat:@"$1 $2-$3"];
        XCTAssertEqualObjects(@"1 (242) 365-1234", [_aUtil formatByPattern:BS_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL userDefinedFormats:@[newNumFormat]]);
        XCTAssertEqualObjects(@"+1 242 365-1234", [_aUtil formatByPattern:BS_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL userDefinedFormats:@[newNumFormat]]);
        
        [newNumFormat setPattern:@"(\\d{2})(\\d{5})(\\d{3})"];
        [newNumFormat setFormat:@"$1-$2 $3"];
        
        XCTAssertEqualObjects(@"02-36618 300", [_aUtil formatByPattern:IT_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL userDefinedFormats:@[newNumFormat]]);
        XCTAssertEqualObjects(@"+39 02-36618 300", [_aUtil formatByPattern:IT_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL userDefinedFormats:@[newNumFormat]]);
        
        [newNumFormat setNationalPrefixFormattingRule:@"$NP$FG"];
        [newNumFormat setPattern:@"(\\d{2})(\\d{4})(\\d{4})"];
        [newNumFormat setFormat:@"$1 $2 $3"];
        XCTAssertEqualObjects(@"020 7031 3000", [_aUtil formatByPattern:GB_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL userDefinedFormats:@[newNumFormat]]);
        
        [newNumFormat setNationalPrefixFormattingRule:@"($NP$FG)"];
        XCTAssertEqualObjects(@"(020) 7031 3000", [_aUtil formatByPattern:GB_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL userDefinedFormats:@[newNumFormat]]);
        
        [newNumFormat setNationalPrefixFormattingRule:@""];
        XCTAssertEqualObjects(@"20 7031 3000", [_aUtil formatByPattern:GB_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL userDefinedFormats:@[newNumFormat]]);
        XCTAssertEqualObjects(@"+44 20 7031 3000", [_aUtil formatByPattern:GB_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL userDefinedFormats:@[newNumFormat]]);
    }
    

    #pragma mark - testFormatE164Number
    {
        XCTAssertEqualObjects(@"+16502530000", [_aUtil format:US_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"+4930123456", [_aUtil format:DE_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"+80012345678", [_aUtil format:INTERNATIONAL_TOLL_FREE numberFormat:NBEPhoneNumberFormatE164]);
    }
    

    #pragma mark - testFormatNumberWithExtension
    {
        id nzNumber = [NZ_NUMBER copy];
        [nzNumber setExtension:@"1234"];
        // Uses default extension prefix:
        XCTAssertEqualObjects(@"03-331 6005 ext. 1234", [_aUtil format:nzNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        // Uses RFC 3966 syntax.
        XCTAssertEqualObjects(@"tel:+64-3-331-6005;ext=1234", [_aUtil format:nzNumber numberFormat:NBEPhoneNumberFormatRFC3966]);
        // Extension prefix overridden in the territory information for the US:
        
        id usNumberWithExtension = [US_NUMBER copy];
        [usNumberWithExtension setExtension:@"4567"];
        XCTAssertEqualObjects(@"650 253 0000 extn. 4567", [_aUtil format:usNumberWithExtension numberFormat:NBEPhoneNumberFormatNATIONAL]);
    }


    #pragma mark - testFormatInOriginalFormat
    {
        NSError *anError = nil;
        RingcNBPhoneNumber *number1 = [_aUtil parseAndKeepRawInput:@"+442087654321" defaultRegion:@"GB" error:&anError];
        XCTAssertEqualObjects(@"+44 20 8765 4321", [_aUtil formatInOriginalFormat:number1 regionCallingFrom:@"GB"]);
        
        RingcNBPhoneNumber *number2 = [_aUtil parseAndKeepRawInput:@"02087654321" defaultRegion:@"GB" error:&anError];
        XCTAssertEqualObjects(@"(020) 8765 4321", [_aUtil formatInOriginalFormat:number2 regionCallingFrom:@"GB"]);
        
        RingcNBPhoneNumber *number3 = [_aUtil parseAndKeepRawInput:@"011442087654321" defaultRegion:@"US" error:&anError];
        XCTAssertEqualObjects(@"011 44 20 8765 4321", [_aUtil formatInOriginalFormat:number3 regionCallingFrom:@"US"]);
        
        RingcNBPhoneNumber *number4 = [_aUtil parseAndKeepRawInput:@"442087654321" defaultRegion:@"GB" error:&anError];
        XCTAssertEqualObjects(@"44 20 8765 4321", [_aUtil formatInOriginalFormat:number4 regionCallingFrom:@"GB"]);
        
        RingcNBPhoneNumber *number5 = [_aUtil parse:@"+442087654321" defaultRegion:@"GB" error:&anError];
        XCTAssertEqualObjects(@"(020) 8765 4321", [_aUtil formatInOriginalFormat:number5 regionCallingFrom:@"GB"]);
        
        // Invalid numbers that we have a formatting pattern for should be formatted
        // properly. Note area codes starting with 7 are intentionally excluded in
        // the test metadata for testing purposes.
        RingcNBPhoneNumber *number6 = [_aUtil parseAndKeepRawInput:@"7345678901" defaultRegion:@"US" error:&anError];
        XCTAssertEqualObjects(@"734 567 8901", [_aUtil formatInOriginalFormat:number6 regionCallingFrom:@"US"]);
        
        // US is not a leading zero country, and the presence of the leading zero
        // leads us to format the number using raw_input.
        RingcNBPhoneNumber *number7 = [_aUtil parseAndKeepRawInput:@"0734567 8901" defaultRegion:@"US" error:&anError];
        XCTAssertEqualObjects(@"0734567 8901", [_aUtil formatInOriginalFormat:number7 regionCallingFrom:@"US"]);
        
        // This number is valid, but we don't have a formatting pattern for it.
        // Fall back to the raw input.
        RingcNBPhoneNumber *number8 = [_aUtil parseAndKeepRawInput:@"02-4567-8900" defaultRegion:@"KR" error:&anError];
        XCTAssertEqualObjects(@"02-4567-8900", [_aUtil formatInOriginalFormat:number8 regionCallingFrom:@"KR"]);
        
        RingcNBPhoneNumber *number9 = [_aUtil parseAndKeepRawInput:@"01180012345678" defaultRegion:@"US" error:&anError];
        XCTAssertEqualObjects(@"011 800 1234 5678", [_aUtil formatInOriginalFormat:number9 regionCallingFrom:@"US"]);
        
        RingcNBPhoneNumber *number10 = [_aUtil parseAndKeepRawInput:@"+80012345678" defaultRegion:@"KR" error:&anError];
        XCTAssertEqualObjects(@"+800 1234 5678", [_aUtil formatInOriginalFormat:number10 regionCallingFrom:@"KR"]);
        
        // US local numbers are formatted correctly, as we have formatting patterns
        // for them.
        RingcNBPhoneNumber *localNumberUS = [_aUtil parseAndKeepRawInput:@"2530000" defaultRegion:@"US" error:&anError];
        XCTAssertEqualObjects(@"253 0000", [_aUtil formatInOriginalFormat:localNumberUS regionCallingFrom:@"US"]);
        
        RingcNBPhoneNumber *numberWithNationalPrefixUS = [_aUtil parseAndKeepRawInput:@"18003456789" defaultRegion:@"US" error:&anError];
        XCTAssertEqualObjects(@"1 800 345 6789", [_aUtil formatInOriginalFormat:numberWithNationalPrefixUS regionCallingFrom:@"US"]);
        
        RingcNBPhoneNumber *numberWithoutNationalPrefixGB = [_aUtil parseAndKeepRawInput:@"2087654321" defaultRegion:@"GB" error:&anError];
        XCTAssertEqualObjects(@"20 8765 4321", [_aUtil formatInOriginalFormat:numberWithoutNationalPrefixGB regionCallingFrom:@"GB"]);
        
        // Make sure no metadata is modified as a result of the previous function
        // call.
        XCTAssertEqualObjects(@"(020) 8765 4321", [_aUtil formatInOriginalFormat:number5 regionCallingFrom:@"GB" error:&anError]);
        
        RingcNBPhoneNumber *numberWithNationalPrefixMX = [_aUtil parseAndKeepRawInput:@"013312345678" defaultRegion:@"MX" error:&anError];
        XCTAssertEqualObjects(@"01 33 1234 5678", [_aUtil formatInOriginalFormat:numberWithNationalPrefixMX regionCallingFrom:@"MX"]);
        
        RingcNBPhoneNumber *numberWithoutNationalPrefixMX = [_aUtil parseAndKeepRawInput:@"3312345678" defaultRegion:@"MX" error:&anError];
        XCTAssertEqualObjects(@"33 1234 5678", [_aUtil formatInOriginalFormat:numberWithoutNationalPrefixMX regionCallingFrom:@"MX"]);
        
        RingcNBPhoneNumber *italianFixedLineNumber = [_aUtil parseAndKeepRawInput:@"0212345678" defaultRegion:@"IT" error:&anError];
        XCTAssertEqualObjects(@"02 1234 5678", [_aUtil formatInOriginalFormat:italianFixedLineNumber regionCallingFrom:@"IT"]);
        
        RingcNBPhoneNumber *numberWithNationalPrefixJP = [_aUtil parseAndKeepRawInput:@"00777012" defaultRegion:@"JP" error:&anError];
        XCTAssertEqualObjects(@"0077-7012", [_aUtil formatInOriginalFormat:numberWithNationalPrefixJP regionCallingFrom:@"JP"]);
        
        RingcNBPhoneNumber *numberWithoutNationalPrefixJP = [_aUtil parseAndKeepRawInput:@"0777012" defaultRegion:@"JP" error:&anError];
        XCTAssertEqualObjects(@"0777012", [_aUtil formatInOriginalFormat:numberWithoutNationalPrefixJP regionCallingFrom:@"JP"]);
        
        RingcNBPhoneNumber *numberWithCarrierCodeBR = [_aUtil parseAndKeepRawInput:@"012 3121286979" defaultRegion:@"BR" error:&anError];
        XCTAssertEqualObjects(@"012 3121286979", [_aUtil formatInOriginalFormat:numberWithCarrierCodeBR regionCallingFrom:@"BR"]);
        
        // The default national prefix used in this case is 045. When a number with
        // national prefix 044 is entered, we return the raw input as we don't want to
        // change the number entered.
        RingcNBPhoneNumber *numberWithNationalPrefixMX1 = [_aUtil parseAndKeepRawInput:@"044(33)1234-5678" defaultRegion:@"MX" error:&anError];
        XCTAssertEqualObjects(@"044(33)1234-5678", [_aUtil formatInOriginalFormat:numberWithNationalPrefixMX1 regionCallingFrom:@"MX"]);
        
        RingcNBPhoneNumber *numberWithNationalPrefixMX2 = [_aUtil parseAndKeepRawInput:@"045(33)1234-5678" defaultRegion:@"MX" error:&anError];
        XCTAssertEqualObjects(@"045 33 1234 5678", [_aUtil formatInOriginalFormat:numberWithNationalPrefixMX2 regionCallingFrom:@"MX"]);
        
        // The default international prefix used in this case is 0011. When a number
        // with international prefix 0012 is entered, we return the raw input as we
        // don't want to change the number entered.
        id outOfCountryNumberFromAU1 = [_aUtil parseAndKeepRawInput:@"0012 16502530000" defaultRegion:@"AU" error:&anError];
        XCTAssertEqualObjects(@"0012 16502530000", [_aUtil formatInOriginalFormat:outOfCountryNumberFromAU1 regionCallingFrom:@"AU"]);
        
        id outOfCountryNumberFromAU2 = [_aUtil parseAndKeepRawInput:@"0011 16502530000" defaultRegion:@"AU" error:&anError];
        XCTAssertEqualObjects(@"0011 1 650 253 0000", [_aUtil formatInOriginalFormat:outOfCountryNumberFromAU2 regionCallingFrom:@"AU"]);
        
        // Test the star sign is not removed from or added to the original input by
        // this method.
        id starNumber = [_aUtil parseAndKeepRawInput:@"*1234" defaultRegion:@"JP" error:&anError];
        XCTAssertEqualObjects(@"*1234", [_aUtil formatInOriginalFormat:starNumber regionCallingFrom:@"JP"]);
        
        RingcNBPhoneNumber *numberWithoutStar = [_aUtil parseAndKeepRawInput:@"1234" defaultRegion:@"JP" error:&anError];
        XCTAssertEqualObjects(@"1234", [_aUtil formatInOriginalFormat:numberWithoutStar regionCallingFrom:@"JP"]);
        
        // Test an invalid national number without raw input is just formatted as the
        // national number.
        XCTAssertEqualObjects(@"650253000", [_aUtil formatInOriginalFormat:US_SHORT_BY_ONE_NUMBER regionCallingFrom:@"US"]);
    }

    #pragma mark - testIsPremiumRate
    {
        XCTAssertEqual(NBEPhoneNumberTypePREMIUM_RATE, [_aUtil getNumberType:US_PREMIUM]);
        
        RingcNBPhoneNumber *premiumRateNumber = [[RingcNBPhoneNumber alloc] init];
        premiumRateNumber = [[RingcNBPhoneNumber alloc] init];
        [premiumRateNumber setCountryCode:@39];
        [premiumRateNumber setNationalNumber:@892123];
        XCTAssertEqual(NBEPhoneNumberTypePREMIUM_RATE, [_aUtil getNumberType:premiumRateNumber]);
        
        premiumRateNumber = [[RingcNBPhoneNumber alloc] init];
        [premiumRateNumber setCountryCode:@44];
        [premiumRateNumber setNationalNumber:@9187654321];
        XCTAssertEqual(NBEPhoneNumberTypePREMIUM_RATE, [_aUtil getNumberType:premiumRateNumber]);
        
        premiumRateNumber = [[RingcNBPhoneNumber alloc] init];
        [premiumRateNumber setCountryCode:@49];
        [premiumRateNumber setNationalNumber:@9001654321];
        XCTAssertEqual(NBEPhoneNumberTypePREMIUM_RATE, [_aUtil getNumberType:premiumRateNumber]);
        
        premiumRateNumber = [[RingcNBPhoneNumber alloc] init];
        [premiumRateNumber setCountryCode:@49];
        [premiumRateNumber setNationalNumber:@90091234567];
        XCTAssertEqual(NBEPhoneNumberTypePREMIUM_RATE, [_aUtil getNumberType:premiumRateNumber]);
        XCTAssertEqual(NBEPhoneNumberTypePREMIUM_RATE, [_aUtil getNumberType:UNIVERSAL_PREMIUM_RATE]);
    }
    

    #pragma mark - testIsTollFree
    {
        RingcNBPhoneNumber *tollFreeNumber = [[RingcNBPhoneNumber alloc] init];
        
        [tollFreeNumber setCountryCode:@1];
        [tollFreeNumber setNationalNumber:@8881234567];
        XCTAssertEqual(NBEPhoneNumberTypeTOLL_FREE, [_aUtil getNumberType:tollFreeNumber]);
        
        tollFreeNumber = [[RingcNBPhoneNumber alloc] init];
        [tollFreeNumber setCountryCode:@39];
        [tollFreeNumber setNationalNumber:@803123];
        XCTAssertEqual(NBEPhoneNumberTypeTOLL_FREE, [_aUtil getNumberType:tollFreeNumber]);
        
        tollFreeNumber = [[RingcNBPhoneNumber alloc] init];
        [tollFreeNumber setCountryCode:@44];
        [tollFreeNumber setNationalNumber:@8012345678];
        XCTAssertEqual(NBEPhoneNumberTypeTOLL_FREE, [_aUtil getNumberType:tollFreeNumber]);
        
        tollFreeNumber = [[RingcNBPhoneNumber alloc] init];
        [tollFreeNumber setCountryCode:@49];
        [tollFreeNumber setNationalNumber:@8001234567];
        XCTAssertEqual(NBEPhoneNumberTypeTOLL_FREE, [_aUtil getNumberType:tollFreeNumber]);
        
        XCTAssertEqual(NBEPhoneNumberTypeTOLL_FREE, [_aUtil getNumberType:INTERNATIONAL_TOLL_FREE]);
    }
    

    #pragma mark - testIsMobile
    {
        XCTAssertEqual(NBEPhoneNumberTypeMOBILE, [_aUtil getNumberType:BS_MOBILE]);
        XCTAssertEqual(NBEPhoneNumberTypeMOBILE, [_aUtil getNumberType:GB_MOBILE]);
        XCTAssertEqual(NBEPhoneNumberTypeMOBILE, [_aUtil getNumberType:IT_MOBILE]);
        XCTAssertEqual(NBEPhoneNumberTypeMOBILE, [_aUtil getNumberType:AR_MOBILE]);
        
        RingcNBPhoneNumber *mobileNumber = [[RingcNBPhoneNumber alloc] init];
        [mobileNumber setCountryCode:@49];
        [mobileNumber setNationalNumber:@15123456789];
        XCTAssertEqual(NBEPhoneNumberTypeMOBILE, [_aUtil getNumberType:mobileNumber]);
    }

    
    #pragma mark - testIsFixedLine
    {
        XCTAssertEqual(NBEPhoneNumberTypeFIXED_LINE, [_aUtil getNumberType:BS_NUMBER]);
        XCTAssertEqual(NBEPhoneNumberTypeFIXED_LINE, [_aUtil getNumberType:IT_NUMBER]);
        XCTAssertEqual(NBEPhoneNumberTypeFIXED_LINE, [_aUtil getNumberType:GB_NUMBER]);
        XCTAssertEqual(NBEPhoneNumberTypeFIXED_LINE, [_aUtil getNumberType:DE_NUMBER]);
    }

    
    #pragma mark - testIsFixedLineAndMobile
    {
        XCTAssertEqual(NBEPhoneNumberTypeFIXED_LINE_OR_MOBILE, [_aUtil getNumberType:US_NUMBER]);
        
        RingcNBPhoneNumber *fixedLineAndMobileNumber = [[RingcNBPhoneNumber alloc] init];
        [fixedLineAndMobileNumber setCountryCode:@54];
        [fixedLineAndMobileNumber setNationalNumber:@1987654321];
        XCTAssertEqual(NBEPhoneNumberTypeFIXED_LINE_OR_MOBILE, [_aUtil getNumberType:fixedLineAndMobileNumber]);
    }

    
    #pragma mark - testIsSharedCost
    {
        RingcNBPhoneNumber *gbNumber = [[RingcNBPhoneNumber alloc] init];
        [gbNumber setCountryCode:@44];
        [gbNumber setNationalNumber:@8431231234];
        XCTAssertEqual(NBEPhoneNumberTypeSHARED_COST, [_aUtil getNumberType:gbNumber]);
    }

    
    #pragma mark - testIsVoip
    {
        RingcNBPhoneNumber *gbNumber = [[RingcNBPhoneNumber alloc] init];
        [gbNumber setCountryCode:@44];
        [gbNumber setNationalNumber:@5631231234];
        XCTAssertEqual(NBEPhoneNumberTypeVOIP, [_aUtil getNumberType:gbNumber]);
    }

    
    #pragma mark - testIsPersonalNumber
    {
        RingcNBPhoneNumber *gbNumber = [[RingcNBPhoneNumber alloc] init];
        [gbNumber setCountryCode:@44];
        [gbNumber setNationalNumber:@7031231234];
        XCTAssertEqual(NBEPhoneNumberTypePERSONAL_NUMBER, [_aUtil getNumberType:gbNumber]);
    }
    

    #pragma mark - testIsUnknown
    {
        // Invalid numbers should be of type UNKNOWN.
        XCTAssertEqual(NBEPhoneNumberTypeUNKNOWN, [_aUtil getNumberType:US_LOCAL_NUMBER]);
    }
    

    #pragma mark - testisValidNumber
    {
        XCTAssertTrue([_aUtil isValidNumber:US_NUMBER]);
        XCTAssertTrue([_aUtil isValidNumber:IT_NUMBER]);
        XCTAssertTrue([_aUtil isValidNumber:GB_MOBILE]);
        XCTAssertTrue([_aUtil isValidNumber:INTERNATIONAL_TOLL_FREE]);
        XCTAssertTrue([_aUtil isValidNumber:UNIVERSAL_PREMIUM_RATE]);
        
        RingcNBPhoneNumber *nzNumber = [[RingcNBPhoneNumber alloc] init];
        [nzNumber setCountryCode:@64];
        [nzNumber setNationalNumber:@21387835];
        XCTAssertTrue([_aUtil isValidNumber:nzNumber]);
    }

    
    #pragma mark - testIsValidForRegion
    {
        // This number is valid for the Bahamas, but is not a valid US number.
        XCTAssertTrue([_aUtil isValidNumber:BS_NUMBER]);
        XCTAssertTrue([_aUtil isValidNumberForRegion:BS_NUMBER regionCode:@"BS"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:BS_NUMBER regionCode:@"US"]);
        
        RingcNBPhoneNumber *bsInvalidNumber = [[RingcNBPhoneNumber alloc] init];
        [bsInvalidNumber setCountryCode:@1];
        [bsInvalidNumber setNationalNumber:@2421232345];
        // This number is no longer valid.
        XCTAssertFalse([_aUtil isValidNumber:bsInvalidNumber]);
        
        // La Mayotte and Reunion use 'leadingDigits' to differentiate them.
        
        RingcNBPhoneNumber *reNumber = [[RingcNBPhoneNumber alloc] init];
        [reNumber setCountryCode:@262];
        [reNumber setNationalNumber:@262123456];
        XCTAssertTrue([_aUtil isValidNumber:reNumber]);
        XCTAssertTrue([_aUtil isValidNumberForRegion:reNumber regionCode:@"RE"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:reNumber regionCode:@"YT"]);
        
        // Now change the number to be a number for La Mayotte.
        [reNumber setNationalNumber:@269601234];
        XCTAssertTrue([_aUtil isValidNumberForRegion:reNumber regionCode:@"YT"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:reNumber regionCode:@"RE"]);
        
        // This number is no longer valid for La Reunion.
        [reNumber setNationalNumber:@269123456];
        XCTAssertFalse([_aUtil isValidNumberForRegion:reNumber regionCode:@"YT"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:reNumber regionCode:@"RE"]);
        XCTAssertFalse([_aUtil isValidNumber:reNumber]);
        
        // However, it should be recognised as from La Mayotte, since it is valid for
        // this region.
        XCTAssertEqualObjects(@"YT", [_aUtil getRegionCodeForNumber:reNumber]);
        
        // This number is valid in both places.
        [reNumber setNationalNumber:@800123456];
        XCTAssertTrue([_aUtil isValidNumberForRegion:reNumber regionCode:@"YT"]);
        XCTAssertTrue([_aUtil isValidNumberForRegion:reNumber regionCode:@"RE"]);
        XCTAssertTrue([_aUtil isValidNumberForRegion:INTERNATIONAL_TOLL_FREE regionCode:@"001"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:INTERNATIONAL_TOLL_FREE regionCode:@"US"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:INTERNATIONAL_TOLL_FREE regionCode:@"ZZ"]);
        
        RingcNBPhoneNumber *invalidNumber = [[RingcNBPhoneNumber alloc] init];
        // Invalid country calling codes.
        [invalidNumber setCountryCode:@3923];
        [invalidNumber setNationalNumber:@2366];
        XCTAssertFalse([_aUtil isValidNumberForRegion:invalidNumber regionCode:@"ZZ"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:invalidNumber regionCode:@"001"]);
        [invalidNumber setCountryCode:0];
        XCTAssertFalse([_aUtil isValidNumberForRegion:invalidNumber regionCode:@"001"]);
        XCTAssertFalse([_aUtil isValidNumberForRegion:invalidNumber regionCode:@"ZZ"]);
    }

    
    #pragma mark - testIsNotValidNumber
    {
        XCTAssertFalse([_aUtil isValidNumber:US_LOCAL_NUMBER]);
        
        RingcNBPhoneNumber *invalidNumber = [[RingcNBPhoneNumber alloc] init];
        [invalidNumber setCountryCode:@39];
        [invalidNumber setNationalNumber:@23661830000];
        [invalidNumber setItalianLeadingZero:YES];
        XCTAssertFalse([_aUtil isValidNumber:invalidNumber]);
        
        invalidNumber = [[RingcNBPhoneNumber alloc] init];
        [invalidNumber setCountryCode:@44];
        [invalidNumber setNationalNumber:@791234567];
        XCTAssertFalse([_aUtil isValidNumber:invalidNumber]);
        
        invalidNumber = [[RingcNBPhoneNumber alloc] init];
        [invalidNumber setCountryCode:@0];
        [invalidNumber setNationalNumber:@1234];
        XCTAssertFalse([_aUtil isValidNumber:invalidNumber]);
        
        invalidNumber = [[RingcNBPhoneNumber alloc] init];
        [invalidNumber setCountryCode:@64];
        [invalidNumber setNationalNumber:@3316005];
        XCTAssertFalse([_aUtil isValidNumber:invalidNumber]);
        
        invalidNumber = [[RingcNBPhoneNumber alloc] init];
        // Invalid country calling codes.
        [invalidNumber setCountryCode:@3923];
        [invalidNumber setNationalNumber:@2366];
        XCTAssertFalse([_aUtil isValidNumber:invalidNumber]);
        [invalidNumber setCountryCode:@0];
        XCTAssertFalse([_aUtil isValidNumber:invalidNumber]);
        
        XCTAssertFalse([_aUtil isValidNumber:INTERNATIONAL_TOLL_FREE_TOO_LONG]);
    }
    

    #pragma mark - testgetRegionCodeForCountryCode
    {
        XCTAssertEqualObjects(@"US", [_aUtil getRegionCodeForCountryCode:@1]);
        XCTAssertEqualObjects(@"GB", [_aUtil getRegionCodeForCountryCode:@44]);
        XCTAssertEqualObjects(@"DE", [_aUtil getRegionCodeForCountryCode:@49]);
        XCTAssertEqualObjects(@"001", [_aUtil getRegionCodeForCountryCode:@800]);
        XCTAssertEqualObjects(@"001", [_aUtil getRegionCodeForCountryCode:@979]);
    }
    

    #pragma mark - testgetRegionCodeForNumber
    {
        XCTAssertEqualObjects(@"BS", [_aUtil getRegionCodeForNumber:BS_NUMBER]);
        XCTAssertEqualObjects(@"US", [_aUtil getRegionCodeForNumber:US_NUMBER]);
        XCTAssertEqualObjects(@"GB", [_aUtil getRegionCodeForNumber:GB_MOBILE]);
        XCTAssertEqualObjects(@"001", [_aUtil getRegionCodeForNumber:INTERNATIONAL_TOLL_FREE]);
        XCTAssertEqualObjects(@"001", [_aUtil getRegionCodeForNumber:UNIVERSAL_PREMIUM_RATE]);
    }
    

    #pragma mark - testGetRegionCodesForCountryCode
    {
        NSArray *regionCodesForNANPA = [_aUtil getRegionCodesForCountryCode:@1];
        XCTAssertTrue([regionCodesForNANPA containsObject:@"US"]);
        XCTAssertTrue([regionCodesForNANPA containsObject:@"BS"]);
        XCTAssertTrue([[_aUtil getRegionCodesForCountryCode:@44] containsObject:@"GB"]);
        XCTAssertTrue([[_aUtil getRegionCodesForCountryCode:@49] containsObject:@"DE"]);
        XCTAssertTrue([[_aUtil getRegionCodesForCountryCode:@800] containsObject:@"001"]);
        // Test with invalid country calling code.
        XCTAssertTrue([[_aUtil getRegionCodesForCountryCode:@-1] count] == 0);
    }
    

    #pragma mark - testGetCountryCodeForRegion
    {
        XCTAssertEqualObjects(@1, [_aUtil getCountryCodeForRegion:@"US"]);
        XCTAssertEqualObjects(@64, [_aUtil getCountryCodeForRegion:@"NZ"]);
        XCTAssertEqualObjects(@0, [_aUtil getCountryCodeForRegion:nil]);
        XCTAssertEqualObjects(@0, [_aUtil getCountryCodeForRegion:@"ZZ"]);
        XCTAssertEqualObjects(@0, [_aUtil getCountryCodeForRegion:@"001"]);
        // CS is already deprecated so the library doesn't support it.
        XCTAssertEqualObjects(@0, [_aUtil getCountryCodeForRegion:@"CS"]);
    }
    

    #pragma mark - testGetNationalDiallingPrefixForRegion
    {
        XCTAssertEqualObjects(@"1", [_aUtil getNddPrefixForRegion:@"US" stripNonDigits:NO]);

        // Test non-main country to see it gets the national dialling prefix for the
        // main country with that country calling code.
        XCTAssertEqualObjects(@"1", [_aUtil getNddPrefixForRegion:@"BS" stripNonDigits:NO]);
        XCTAssertEqualObjects(@"0", [_aUtil getNddPrefixForRegion:@"NZ" stripNonDigits:NO]);

        // Test case with non digit in the national prefix.
        XCTAssertEqualObjects(@"0~0", [_aUtil getNddPrefixForRegion:@"AO" stripNonDigits:NO]);
        XCTAssertEqualObjects(@"00", [_aUtil getNddPrefixForRegion:@"AO" stripNonDigits:YES]);

        // Test cases with invalid regions.
        XCTAssertNil([_aUtil getNddPrefixForRegion:nil stripNonDigits:NO]);
        XCTAssertNil([_aUtil getNddPrefixForRegion:@"ZZ" stripNonDigits:NO]);
        XCTAssertNil([_aUtil getNddPrefixForRegion:@"001" stripNonDigits:NO]);

        // CS is already deprecated so the library doesn't support it.
        XCTAssertNil([_aUtil getNddPrefixForRegion:@"CS" stripNonDigits:NO]);
    }


    #pragma mark - testIsNANPACountry
    {
        XCTAssertTrue([_aUtil isNANPACountry:@"US"]);
        XCTAssertTrue([_aUtil isNANPACountry:@"BS"]);
        XCTAssertFalse([_aUtil isNANPACountry:@"DE"]);
        XCTAssertFalse([_aUtil isNANPACountry:@"ZZ"]);
        XCTAssertFalse([_aUtil isNANPACountry:@"001"]);
        XCTAssertFalse([_aUtil isNANPACountry:nil]);
    }

    
    #pragma mark - testIsPossibleNumber
    {
        XCTAssertTrue([_aUtil isPossibleNumber:US_NUMBER]);
        XCTAssertTrue([_aUtil isPossibleNumber:US_LOCAL_NUMBER]);
        XCTAssertTrue([_aUtil isPossibleNumber:GB_NUMBER]);
        XCTAssertTrue([_aUtil isPossibleNumber:INTERNATIONAL_TOLL_FREE]);
        
        XCTAssertTrue([_aUtil isPossibleNumberString:@"+1 650 253 0000" regionDialingFrom:@"US" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"+1 650 GOO OGLE" regionDialingFrom:@"US" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"(650) 253-0000" regionDialingFrom:@"US" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"253-0000" regionDialingFrom:@"US" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"+1 650 253 0000" regionDialingFrom:@"GB" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"+44 20 7031 3000" regionDialingFrom:@"GB" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"(020) 7031 3000" regionDialingFrom:@"GB" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"7031 3000" regionDialingFrom:@"GB" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"3331 6005" regionDialingFrom:@"NZ" error:nil]);
        XCTAssertTrue([_aUtil isPossibleNumberString:@"+800 1234 5678" regionDialingFrom:@"001" error:nil]);
    }
    

    #pragma mark - testIsPossibleNumberWithReason
    {
        // National numbers for country calling code +1 that are within 7 to 10 digits
        // are possible.
        XCTAssertEqual(NBEValidationResultIS_POSSIBLE, [_aUtil isPossibleNumberWithReason:US_NUMBER]);
        XCTAssertEqual(NBEValidationResultIS_POSSIBLE, [_aUtil isPossibleNumberWithReason:US_LOCAL_NUMBER]);
        XCTAssertEqual(NBEValidationResultTOO_LONG, [_aUtil isPossibleNumberWithReason:US_LONG_NUMBER]);
        
        RingcNBPhoneNumber *number = [[RingcNBPhoneNumber alloc] init];
        [number setCountryCode:@0];
        [number setNationalNumber:@2530000];
        XCTAssertEqual(NBEValidationResultINVALID_COUNTRY_CODE, [_aUtil isPossibleNumberWithReason:number]);
        
        number = [[RingcNBPhoneNumber alloc] init];
        [number setCountryCode:@1];
        [number setNationalNumber:@253000];
        XCTAssertEqual(NBEValidationResultTOO_SHORT, [_aUtil isPossibleNumberWithReason:number]);
        
        number = [[RingcNBPhoneNumber alloc] init];
        [number setCountryCode:@65];
        [number setNationalNumber:@1234567890];
        XCTAssertEqual(NBEValidationResultIS_POSSIBLE, [_aUtil isPossibleNumberWithReason:number]);
        XCTAssertEqual(NBEValidationResultTOO_LONG, [_aUtil isPossibleNumberWithReason:INTERNATIONAL_TOLL_FREE_TOO_LONG]);
        
        // Try with number that we don't have metadata for.
        
        RingcNBPhoneNumber *adNumber = [[RingcNBPhoneNumber alloc] init];
        [adNumber setCountryCode:@376];
        [adNumber setNationalNumber:@12345];
        XCTAssertEqual(NBEValidationResultIS_POSSIBLE, [_aUtil isPossibleNumberWithReason:adNumber]);
        
        [adNumber setCountryCode:@376];
        [adNumber setNationalNumber:@1];
        XCTAssertEqual(NBEValidationResultTOO_SHORT, [_aUtil isPossibleNumberWithReason:adNumber]);
        
        [adNumber setCountryCode:@376];
        [adNumber setNationalNumber:@12345678901234567];
        XCTAssertEqual(NBEValidationResultTOO_LONG, [_aUtil isPossibleNumberWithReason:adNumber]);
    }


    #pragma mark - testIsNotPossibleNumber
    {
        XCTAssertFalse([_aUtil isPossibleNumber:US_LONG_NUMBER]);
        XCTAssertFalse([_aUtil isPossibleNumber:INTERNATIONAL_TOLL_FREE_TOO_LONG]);
        
        RingcNBPhoneNumber *number = [[RingcNBPhoneNumber alloc] init];
        [number setCountryCode:@1];
        [number setNationalNumber:@253000];
        XCTAssertFalse([_aUtil isPossibleNumber:number]);
        
        number = [[RingcNBPhoneNumber alloc] init];
        [number setCountryCode:@44];
        [number setNationalNumber:@300];
        XCTAssertFalse([_aUtil isPossibleNumber:number]);
        XCTAssertFalse([_aUtil isPossibleNumberString:@"+1 650 253 00000" regionDialingFrom:@"US" error:nil]);
        XCTAssertFalse([_aUtil isPossibleNumberString:@"(650) 253-00000" regionDialingFrom:@"US" error:nil]);
        XCTAssertFalse([_aUtil isPossibleNumberString:@"I want a Pizza" regionDialingFrom:@"US" error:nil]);
        XCTAssertFalse([_aUtil isPossibleNumberString:@"253-000" regionDialingFrom:@"US" error:nil]);
        XCTAssertFalse([_aUtil isPossibleNumberString:@"1 3000" regionDialingFrom:@"GB" error:nil]);
        XCTAssertFalse([_aUtil isPossibleNumberString:@"+44 300" regionDialingFrom:@"GB" error:nil]);
        XCTAssertFalse([_aUtil isPossibleNumberString:@"+800 1234 5678 9" regionDialingFrom:@"001" error:nil]);
    }


    #pragma mark - testTruncateTooLongNumber
    {
        // GB number 080 1234 5678, but entered with 4 extra digits at the end.
        RingcNBPhoneNumber *tooLongNumber = [[RingcNBPhoneNumber alloc] init];
        [tooLongNumber setCountryCode:@44];
        [tooLongNumber setNationalNumber:@80123456780123];
        
        RingcNBPhoneNumber *validNumber = [[RingcNBPhoneNumber alloc] init];
        [validNumber setCountryCode:@44];
        [validNumber setNationalNumber:@8012345678];
        XCTAssertTrue([_aUtil truncateTooLongNumber:tooLongNumber]);
        XCTAssertTrue([validNumber isEqual:tooLongNumber]);
        
        // IT number 022 3456 7890, but entered with 3 extra digits at the end.
        tooLongNumber = [[RingcNBPhoneNumber alloc] init];
        [tooLongNumber setCountryCode:@39];
        [tooLongNumber setNationalNumber:@2234567890123];
        [tooLongNumber setItalianLeadingZero:YES];
                                             
        validNumber = [[RingcNBPhoneNumber alloc] init];
        [validNumber setCountryCode:@39];
        [validNumber setNationalNumber:@2234567890];
        [validNumber setItalianLeadingZero:YES];
        XCTAssertTrue([_aUtil truncateTooLongNumber:tooLongNumber]);
        XCTAssertTrue([validNumber isEqual:tooLongNumber]);
        
        // US number 650-253-0000, but entered with one additional digit at the end.
        tooLongNumber = [US_LONG_NUMBER copy];
        XCTAssertTrue([_aUtil truncateTooLongNumber:tooLongNumber]);
        XCTAssertTrue([US_NUMBER isEqual:tooLongNumber]);
        
        tooLongNumber = [INTERNATIONAL_TOLL_FREE_TOO_LONG copy];
        XCTAssertTrue([_aUtil truncateTooLongNumber:tooLongNumber]);
        XCTAssertTrue([INTERNATIONAL_TOLL_FREE isEqual:tooLongNumber]);
        
        // Tests what happens when a valid number is passed in.
        
        RingcNBPhoneNumber *validNumberCopy = [validNumber copy];
        XCTAssertTrue([_aUtil truncateTooLongNumber:validNumber]);
        // Tests the number is not modified.
        XCTAssertTrue([validNumber isEqual:validNumberCopy]);
        
        // Tests what happens when a number with invalid prefix is passed in.
        
        RingcNBPhoneNumber *numberWithInvalidPrefix = [[RingcNBPhoneNumber alloc] init];
        // The test metadata says US numbers cannot have prefix 240.
        [numberWithInvalidPrefix setCountryCode:@1];
        [numberWithInvalidPrefix setNationalNumber:@2401234567];
        
        RingcNBPhoneNumber *invalidNumberCopy = [numberWithInvalidPrefix copy];
        XCTAssertFalse([_aUtil truncateTooLongNumber:numberWithInvalidPrefix]);
        // Tests the number is not modified.
        XCTAssertTrue([numberWithInvalidPrefix isEqual:invalidNumberCopy]);
        
        // Tests what happens when a too short number is passed in.
        
        RingcNBPhoneNumber *tooShortNumber = [[RingcNBPhoneNumber alloc] init];
        [tooShortNumber setCountryCode:@1];
        [tooShortNumber setNationalNumber:@1234];
        
        RingcNBPhoneNumber *tooShortNumberCopy = [tooShortNumber copy];
        XCTAssertFalse([_aUtil truncateTooLongNumber:tooShortNumber]);
        // Tests the number is not modified.
        XCTAssertTrue([tooShortNumber isEqual:tooShortNumberCopy]);
    }
    

    #pragma mark - testIsViablePhoneNumber
    {
        NSLog(@"-------------- testIsViablePhoneNumber");
        XCTAssertFalse([_aUtil isViablePhoneNumber:@"1"]);
        // Only one or two digits before strange non-possible punctuation.
        XCTAssertFalse([_aUtil isViablePhoneNumber:@"1+1+1"]);
        XCTAssertFalse([_aUtil isViablePhoneNumber:@"80+0"]);
        // Two digits is viable.
        XCTAssertTrue([_aUtil isViablePhoneNumber:@"00"]);
        XCTAssertTrue([_aUtil isViablePhoneNumber:@"111"]);
        // Alpha numbers.
        XCTAssertTrue([_aUtil isViablePhoneNumber:@"0800-4-pizza"]);
        XCTAssertTrue([_aUtil isViablePhoneNumber:@"0800-4-PIZZA"]);
        // We need at least three digits before any alpha characters.
        XCTAssertFalse([_aUtil isViablePhoneNumber:@"08-PIZZA"]);
        XCTAssertFalse([_aUtil isViablePhoneNumber:@"8-PIZZA"]);
        XCTAssertFalse([_aUtil isViablePhoneNumber:@"12. March"]);
    }


    #pragma mark - testIsViablePhoneNumberNonAscii
    {
        NSLog(@"-------------- testIsViablePhoneNumberNonAscii");
        // Only one or two digits before possible punctuation followed by more digits.
        XCTAssertTrue([_aUtil isViablePhoneNumber:@"1\u300034"]);
        XCTAssertFalse([_aUtil isViablePhoneNumber:@"1\u30003+4"]);
        // Unicode variants of possible starting character and other allowed
        // punctuation/digits.
        XCTAssertTrue([_aUtil isViablePhoneNumber:@"\uFF081\uFF09\u30003456789"]);
        // Testing a leading + is okay.
        XCTAssertTrue([_aUtil isViablePhoneNumber:@"+1\uFF09\u30003456789"]);
    }


    #pragma mark - testExtractPossibleNumber
    {
        NSLog(@"-------------- testExtractPossibleNumber");
        // Removes preceding funky punctuation and letters but leaves the rest
        // untouched.
        XCTAssertEqualObjects(@"0800-345-600", [_aUtil extractPossibleNumber:@"Tel:0800-345-600"]);
        XCTAssertEqualObjects(@"0800 FOR PIZZA", [_aUtil extractPossibleNumber:@"Tel:0800 FOR PIZZA"]);
        // Should not remove plus sign
        XCTAssertEqualObjects(@"+800-345-600", [_aUtil extractPossibleNumber:@"Tel:+800-345-600"]);
        // Should recognise wide digits as possible start values.
        XCTAssertEqualObjects(@"\uFF10\uFF12\uFF13", [_aUtil extractPossibleNumber:@"\uFF10\uFF12\uFF13"]);
        // Dashes are not possible start values and should be removed.
        XCTAssertEqualObjects(@"\uFF11\uFF12\uFF13", [_aUtil extractPossibleNumber:@"Num-\uFF11\uFF12\uFF13"]);
        // If not possible number present, return empty string.
        XCTAssertEqualObjects(@"", [_aUtil extractPossibleNumber:@"Num-...."]);
        // Leading brackets are stripped - these are not used when parsing.
        XCTAssertEqualObjects(@"650) 253-0000", [_aUtil extractPossibleNumber:@"(650) 253-0000"]);
        
        // Trailing non-alpha-numeric characters should be removed.
        XCTAssertEqualObjects(@"650) 253-0000", [_aUtil extractPossibleNumber:@"(650) 253-0000..- .."]);
        XCTAssertEqualObjects(@"650) 253-0000", [_aUtil extractPossibleNumber:@"(650) 253-0000."]);
        // This case has a trailing RTL char.
        XCTAssertEqualObjects(@"650) 253-0000", [_aUtil extractPossibleNumber:@"(650) 253-0000\u200F"]);
    }

    
    #pragma mark - testMaybeStripNationalPrefix
    {
        NSLog(@"-------------- testMaybeStripNationalPrefix");
        RingcNBPhoneMetaData *metadata = [[RingcNBPhoneMetaData alloc] init];
        [metadata setNationalPrefixForParsing:@"34"];
        
        RingcNBPhoneNumberDesc *generalDesc = [[RingcNBPhoneNumberDesc alloc] init];
        [generalDesc setNationalNumberPattern:@"\\d{4,8}"];
        [metadata setGeneralDesc:generalDesc];
        
        RingcNBPhoneNumber *numberToStrip = [[RingcNBPhoneNumber alloc] init];
        [numberToStrip setRawInput:@"34356778"];
        
        NSString *strippedNumber = @"356778";
        NSString *rawInput = numberToStrip.rawInput;
        XCTAssertTrue([_aUtil maybeStripNationalPrefixAndCarrierCode:&rawInput metadata:metadata carrierCode:nil]);
        XCTAssertEqualObjects(strippedNumber, rawInput, @"Should have had national prefix stripped.");
        
        // Retry stripping - now the number should not start with the national prefix,
        // so no more stripping should occur.
        XCTAssertFalse([_aUtil maybeStripNationalPrefixAndCarrierCode:&rawInput metadata:metadata carrierCode:nil]);
        XCTAssertEqualObjects(strippedNumber, rawInput, @"Should have had no change - no national prefix present.");
                             
        // Some countries have no national prefix. Repeat test with none specified.
        [metadata setNationalPrefixForParsing:@""];
        XCTAssertFalse([_aUtil maybeStripNationalPrefixAndCarrierCode:&rawInput metadata:metadata carrierCode:nil]);
        XCTAssertEqualObjects(strippedNumber, rawInput, @"Should not strip anything with empty national prefix.");

        // If the resultant number doesn't match the national rule, it shouldn't be
        // stripped.
        [metadata setNationalPrefixForParsing:@"3"];
        numberToStrip.rawInput = @"3123";
        rawInput = numberToStrip.rawInput;
        strippedNumber = @"3123";
        XCTAssertFalse([_aUtil maybeStripNationalPrefixAndCarrierCode:&rawInput metadata:metadata carrierCode:nil]);
        XCTAssertEqualObjects(strippedNumber, rawInput, @"Should have had no change - after stripping, it would not have matched the national rule.");
        
        // Test extracting carrier selection code.
        [metadata setNationalPrefixForParsing:@"0(81)?"];
        numberToStrip.rawInput = @"08122123456";
        strippedNumber = @"22123456";
        rawInput = numberToStrip.rawInput;
        NSString *carrierCode = @"";
        XCTAssertTrue([_aUtil maybeStripNationalPrefixAndCarrierCode:&rawInput metadata:metadata carrierCode:&carrierCode]);
        XCTAssertEqualObjects(@"81", carrierCode);
        XCTAssertEqualObjects(strippedNumber, rawInput, @"Should have had national prefix and carrier code stripped.");
        
        // If there was a transform rule, check it was applied.
        [metadata setNationalPrefixTransformRule:@"5$15"];
        // Note that a capturing group is present here.
        [metadata setNationalPrefixForParsing:@"0(\\d{2})"];
        numberToStrip.rawInput = @"031123";
        rawInput = numberToStrip.rawInput;
        NSString *transformedNumber = @"5315123";
        XCTAssertTrue([_aUtil maybeStripNationalPrefixAndCarrierCode:&rawInput metadata:metadata carrierCode:nil]);
        XCTAssertEqualObjects(transformedNumber, rawInput, @"Should transform the 031 to a 5315.");
    }


    #pragma mark - testMaybeStripInternationalPrefix
    {
        NSLog(@"-------------- testMaybeStripInternationalPrefix");
        NSString *internationalPrefix = @"00[39]";
        
        NSString *numberToStripPrefix = @"0034567700-3898003";
        
        // Note the dash is removed as part of the normalization.
        NSString *strippedNumberString = @"45677003898003";
        XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_IDD, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                possibleIddPrefix:internationalPrefix]);
        XCTAssertEqualObjects(strippedNumberString, numberToStripPrefix, @"The number supplied was not stripped of its international prefix.");
        // Now the number no longer starts with an IDD prefix, so it should now report
        // FROM_DEFAULT_COUNTRY.
        XCTAssertEqual(NBECountryCodeSourceFROM_DEFAULT_COUNTRY, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                      possibleIddPrefix:internationalPrefix]);
        
        numberToStripPrefix = @"00945677003898003";
        XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_IDD, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                possibleIddPrefix:internationalPrefix]);
        XCTAssertEqualObjects(strippedNumberString, numberToStripPrefix, @"The number supplied was not stripped of its international prefix.");
        // Test it works when the international prefix is broken up by spaces.
        numberToStripPrefix = @"00 9 45677003898003";
        XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_IDD, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                possibleIddPrefix:internationalPrefix]);
        XCTAssertEqualObjects(strippedNumberString, numberToStripPrefix, @"The number supplied was not stripped of its international prefix.");
        // Now the number no longer starts with an IDD prefix, so it should now report
        // FROM_DEFAULT_COUNTRY.
        XCTAssertEqual(NBECountryCodeSourceFROM_DEFAULT_COUNTRY, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                possibleIddPrefix:internationalPrefix]);
        
        // Test the + symbol is also recognised and stripped.
        numberToStripPrefix = @"+45677003898003";
        strippedNumberString = @"45677003898003";
        XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_PLUS_SIGN, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                      possibleIddPrefix:internationalPrefix]);
        XCTAssertEqualObjects(strippedNumberString, numberToStripPrefix, @"The number supplied was not stripped of the plus symbol.");
        
        // If the number afterwards is a zero, we should not strip this - no country
        // calling code begins with 0.
        numberToStripPrefix = @"0090112-3123";
        strippedNumberString = @"00901123123";
        XCTAssertEqual(NBECountryCodeSourceFROM_DEFAULT_COUNTRY, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                possibleIddPrefix:internationalPrefix]);
        XCTAssertEqualObjects(strippedNumberString, numberToStripPrefix, @"The number supplied had a 0 after the match so should not be stripped.");
        // Here the 0 is separated by a space from the IDD.
        numberToStripPrefix = @"009 0-112-3123";
        XCTAssertEqual(NBECountryCodeSourceFROM_DEFAULT_COUNTRY, [_aUtil maybeStripInternationalPrefixAndNormalize:&numberToStripPrefix
                                                                                possibleIddPrefix:internationalPrefix]);
    }

    #pragma mark - testMaybeExtractCountryCode
    {
        NSLog(@"-------------- testMaybeExtractCountryCode");
        RingcNBPhoneNumber *number = [[RingcNBPhoneNumber alloc] init];
        RingcNBPhoneMetaData *metadata = [RingcNBMetadataHelper getMetadataForRegion:@"US"];
        
        // Note that for the US, the IDD is 011.
        NSString *phoneNumber = @"011112-3456789";
        NSString *strippedNumber = @"123456789";
        NSNumber *countryCallingCode = @1;
        
        NSString *numberToFill = @"";

        {
            NSError *anError = nil;
            XCTAssertEqualObjects(countryCallingCode, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                                                   nationalNumber:&numberToFill keepRawInput:YES phoneNumber:&number error:&anError]);
            XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_IDD, [number.countryCodeSource intValue]);
            // Should strip and normalize national significant number.
            XCTAssertEqualObjects(strippedNumber, numberToFill);
            if (anError)
                XCTFail(@"Should not have thrown an exception: %@", anError.description);
        }
        XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_IDD, [number.countryCodeSource intValue], @"Did not figure out CountryCodeSource correctly");
        // Should strip and normalize national significant number.
        XCTAssertEqualObjects(strippedNumber, numberToFill, @"Did not strip off the country calling code correctly.");
        
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"+6423456789";
        countryCallingCode = @64;
        numberToFill = @"";
        XCTAssertEqualObjects(countryCallingCode, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                                                     nationalNumber:&numberToFill keepRawInput:YES phoneNumber:&number error:nil]);
        XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_PLUS_SIGN, [number.countryCodeSource intValue], @"Did not figure out CountryCodeSource correctly");
        
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"+80012345678";
        countryCallingCode = @800;
        numberToFill = @"";
        XCTAssertEqualObjects(countryCallingCode, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                                 nationalNumber:&numberToFill keepRawInput:YES phoneNumber:&number error:nil]);
        XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITH_PLUS_SIGN, [number.countryCodeSource intValue], @"Did not figure out CountryCodeSource correctly");
        
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"2345-6789";
        numberToFill = @"";
        XCTAssertEqual(@0, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                               nationalNumber:&numberToFill keepRawInput:YES phoneNumber:&number error:nil]);
        XCTAssertEqual(NBECountryCodeSourceFROM_DEFAULT_COUNTRY, [number.countryCodeSource intValue], @"Did not figure out CountryCodeSource correctly");

                                 
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"0119991123456789";
        numberToFill = @"";
        {
            NSError *anError = nil;
            [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                nationalNumber:&numberToFill keepRawInput:YES phoneNumber:&number error:&anError];
            if (anError == nil)
                XCTFail(@"Should have thrown an exception, no valid country calling code present.");
            else // Expected.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain);
        }
        
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"(1 610) 619 4466";
        countryCallingCode = @1;
        numberToFill = @"";
        {
            NSError *anError = nil;
            XCTAssertEqualObjects(countryCallingCode, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                                                   nationalNumber:&numberToFill keepRawInput:YES phoneNumber:&number error:&anError],
                                 @"Should have extracted the country calling code of the region passed in");
            XCTAssertEqual(NBECountryCodeSourceFROM_NUMBER_WITHOUT_PLUS_SIGN, [number.countryCodeSource intValue], @"Did not figure out CountryCodeSource correctly");
        }
        
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"(1 610) 619 4466";
        countryCallingCode = @1;
        numberToFill = @"";
        {
            NSError *anError = nil;
            XCTAssertEqualObjects(countryCallingCode, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                                                   nationalNumber:&numberToFill keepRawInput:NO phoneNumber:&number error:&anError]);
        }
                
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"(1 610) 619 446";
        numberToFill = @"";
        {
            NSError *anError = nil;
            XCTAssertEqualObjects(@0, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                                          nationalNumber:&numberToFill keepRawInput:NO phoneNumber:&number error:&anError]);
            XCTAssertFalse(number.countryCodeSource != nil, @"Should not contain CountryCodeSource.");
        }
        
        number = [[RingcNBPhoneNumber alloc] init];
        phoneNumber = @"(1 610) 619";
        numberToFill = @"";
        {
            NSError *anError = nil;
            XCTAssertEqual(@0, [_aUtil maybeExtractCountryCode:phoneNumber metadata:metadata
                                                          nationalNumber:&numberToFill keepRawInput:YES phoneNumber:&number error:&anError]);
            XCTAssertEqual(NBECountryCodeSourceFROM_DEFAULT_COUNTRY, [number.countryCodeSource intValue]);
        }
    }


    #pragma mark - testParseNationalNumber
    {
        NSError *anError;
        NSLog(@"-------------- testParseNationalNumber");
        // National prefix attached.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"033316005" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"33316005" defaultRegion:@"NZ" error:&anError]]);
        
        // National prefix attached and some formatting present.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"03-331 6005" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"03 331 6005" defaultRegion:@"NZ" error:&anError]]);
        
        // Test parsing RFC3966 format with a phone context.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:03-331-6005;phone-context=+64" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:331-6005;phone-context=+64-3" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:331-6005;phone-context=+64-3" defaultRegion:@"US" error:&anError]]);
                      
        // Test parsing RFC3966 format with optional user-defined parameters. The
        // parameters will appear after the context if present.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:03-331-6005;phone-context=+64;a=%A1" defaultRegion:@"NZ" error:&anError]]);
        
        // Test parsing RFC3966 with an ISDN subaddress.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:03-331-6005;isub=12345;phone-context=+64" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:+64-3-331-6005;isub=12345" defaultRegion:@"NZ" error:&anError]]);

        // Testing international prefixes.
        // Should strip country calling code.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"0064 3 331 6005" defaultRegion:@"NZ" error:&anError]]);

        // Try again, but this time we have an international number with Region Code
        // US. It should recognise the country calling code and parse accordingly.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"01164 3 331 6005" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"+64 3 331 6005" defaultRegion:@"US" error:&anError]]);
        // We should ignore the leading plus here, since it is not followed by a valid
        // country code but instead is followed by the IDD for the US.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"+01164 3 331 6005" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"+0064 3 331 6005" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"+ 00 64 3 331 6005" defaultRegion:@"NZ" error:&anError]]);
        
        XCTAssertTrue([US_LOCAL_NUMBER isEqual:[_aUtil parse:@"tel:253-0000;phone-context=www.google.com" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([US_LOCAL_NUMBER isEqual:[_aUtil parse:@"tel:253-0000;isub=12345;phone-context=www.google.com" defaultRegion:@"US" error:&anError]]);
        // This is invalid because no "+" sign is present as part of phone-context.
        // The phone context is simply ignored in this case just as if it contains a
        // domain.
        XCTAssertTrue([US_LOCAL_NUMBER isEqual:[_aUtil parse:@"tel:2530000;isub=12345;phone-context=1-650" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([US_LOCAL_NUMBER isEqual:[_aUtil parse:@"tel:2530000;isub=12345;phone-context=1234.com" defaultRegion:@"US" error:&anError]]);
        
        RingcNBPhoneNumber *nzNumber = [[RingcNBPhoneNumber alloc] init];
        [nzNumber setCountryCode:@64];
        [nzNumber setNationalNumber:@64123456];
        XCTAssertTrue([nzNumber isEqual:[_aUtil parse:@"64(0)64123456" defaultRegion:@"NZ" error:&anError]]);
        // Check that using a '/' is fine in a phone number.
        XCTAssertTrue([DE_NUMBER isEqual:[_aUtil parse:@"301/23456" defaultRegion:@"DE" error:&anError]]);
        
        RingcNBPhoneNumber *usNumber = [[RingcNBPhoneNumber alloc] init];
        // Check it doesn't use the '1' as a country calling code when parsing if the
        // phone number was already possible.
        [usNumber setCountryCode:@1];
        [usNumber setNationalNumber:@1234567890];
        XCTAssertTrue([usNumber isEqual:[_aUtil parse:@"123-456-7890" defaultRegion:@"US" error:&anError]]);
        
        // Test star numbers. Although this is not strictly valid, we would like to
        // make sure we can parse the output we produce when formatting the number.
        XCTAssertTrue([JP_STAR_NUMBER isEqual:[_aUtil parse:@"+81 *2345" defaultRegion:@"JP" error:&anError]]);
        
        RingcNBPhoneNumber *shortNumber = [[RingcNBPhoneNumber alloc] init];
        [shortNumber setCountryCode:@64];
        [shortNumber setNationalNumber:@12];
        XCTAssertTrue([shortNumber isEqual:[_aUtil parse:@"12" defaultRegion:@"NZ" error:&anError]]);
    }


    #pragma mark - testParseNumberWithAlphaCharacters
    {
        NSError *anError;
        NSLog(@"-------------- testParseNumberWithAlphaCharacters");
        // Test case with alpha characters.
        RingcNBPhoneNumber *tollfreeNumber = [[RingcNBPhoneNumber alloc] init];
        [tollfreeNumber setCountryCode:@64];
        [tollfreeNumber setNationalNumber:@800332005];
        XCTAssertTrue([tollfreeNumber isEqual:[_aUtil parse:@"0800 DDA 005" defaultRegion:@"NZ" error:&anError]]);
        
        RingcNBPhoneNumber *premiumNumber = [[RingcNBPhoneNumber alloc] init];
        [premiumNumber setCountryCode:@64];
        [premiumNumber setNationalNumber:@9003326005];
        XCTAssertTrue([premiumNumber isEqual:[_aUtil parse:@"0900 DDA 6005" defaultRegion:@"NZ" error:&anError]]);
        // Not enough alpha characters for them to be considered intentional, so they
        // are stripped.
        XCTAssertTrue([premiumNumber isEqual:[_aUtil parse:@"0900 332 6005a" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([premiumNumber isEqual:[_aUtil parse:@"0900 332 600a5" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([premiumNumber isEqual:[_aUtil parse:@"0900 332 600A5" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([premiumNumber isEqual:[_aUtil parse:@"0900 a332 600A5" defaultRegion:@"NZ" error:&anError]]);
    }
    
        
    #pragma mark - testParseMaliciousInput
    {
        NSLog(@"-------------- testParseMaliciousInput");
        // Lots of leading + signs before the possible number.
        
        NSString *maliciousNumber = @"";
        for (int i=0; i<6000; i++)
        {
            maliciousNumber = [maliciousNumber stringByAppendingString:@"+"];
        }
        
        maliciousNumber = [maliciousNumber stringByAppendingString:@"12222-33-244 extensioB 343+"];
        {
            NSError *anError = nil;
            [_aUtil parse:maliciousNumber defaultRegion:@"US" error:&anError];
            if (anError == nil) {
                XCTFail(@"This should not parse without throwing an exception %@", maliciousNumber);
            } else {
                XCTAssertEqualObjects(@"TOO_LONG", anError.domain, @"Wrong error type stored in exception.");
            }
        }

        NSString *maliciousNumberWithAlmostExt = @"";
        for (int i=0; i<350; i++)
        {
            maliciousNumberWithAlmostExt = [maliciousNumberWithAlmostExt stringByAppendingString:@"200"];
        }

        [maliciousNumberWithAlmostExt stringByAppendingString:@" extensiOB 345"];
        
        {
            NSError *anError = nil;
            [_aUtil parse:maliciousNumberWithAlmostExt defaultRegion:@"US" error:&anError];
            if (anError == nil) {
                XCTFail(@"This should not parse without throwing an exception %@", maliciousNumberWithAlmostExt);
            } else {
                XCTAssertEqualObjects(@"TOO_LONG", anError.domain, @"Wrong error type stored in exception.");
            }
        }
    }


    #pragma mark - testParseWithInternationalPrefixes
    {
        NSError *anError = nil;
        NSLog(@"-------------- testParseWithInternationalPrefixes");
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"+1 (650) 253-0000" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([INTERNATIONAL_TOLL_FREE isEqual:[_aUtil parse:@"011 800 1234 5678" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"1-650-253-0000" defaultRegion:@"US" error:&anError]]);
        // Calling the US number from Singapore by using different service providers
        // 1st test: calling using SingTel IDD service (IDD is 001)
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"0011-650-253-0000" defaultRegion:@"SG" error:&anError]]);
        // 2nd test: calling using StarHub IDD service (IDD is 008)
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"0081-650-253-0000" defaultRegion:@"SG" error:&anError]]);
        // 3rd test: calling using SingTel V019 service (IDD is 019)
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"0191-650-253-0000" defaultRegion:@"SG" error:&anError]]);
        // Calling the US number from Poland
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"0~01-650-253-0000" defaultRegion:@"PL" error:&anError]]);
        // Using '++' at the start.
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"++1 (650) 253-0000" defaultRegion:@"PL" error:&anError]]);
    }

    
    #pragma mark - testParseNonAscii
    {
        NSError *anError = nil;
        NSLog(@"-------------- testParseNonAscii");
        // Using a full-width plus sign.
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"\uFF0B1 (650) 253-0000" defaultRegion:@"SG" error:&anError]]);
        // Using a soft hyphen U+00AD.
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"1 (650) 253\u00AD-0000" defaultRegion:@"US" error:&anError]]);
        // The whole number, including punctuation, is here represented in full-width
        // form.
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"\uFF0B\uFF11\u3000\uFF08\uFF16\uFF15\uFF10\uFF09\u3000\uFF12\uFF15\uFF13\uFF0D\uFF10\uFF10\uFF10\uFF10" defaultRegion:@"SG" error:&anError]]);
        // Using U+30FC dash instead.
        XCTAssertTrue([US_NUMBER isEqual:[_aUtil parse:@"\uFF0B\uFF11\u3000\uFF08\uFF16\uFF15\uFF10\uFF09\u3000\uFF12\uFF15\uFF13\u30FC\uFF10\uFF10\uFF10\uFF10" defaultRegion:@"SG" error:&anError]]);
        
        // Using a very strange decimal digit range (Mongolian digits).
        // TODO(user): Support Mongolian digits
        // STAssertTrue(US_NUMBER isEqual:
        //     [_aUtil parse:@"\u1811 \u1816\u1815\u1810 " +
        //                     '\u1812\u1815\u1813 \u1810\u1810\u1810\u1810" defaultRegion:@"US"], nil);
    }

    
    #pragma mark - testParseWithLeadingZero
    {
        NSError *anError = nil;
        NSLog(@"-------------- testParseWithLeadingZero");
        XCTAssertTrue([IT_NUMBER isEqual:[_aUtil parse:@"+39 02-36618 300" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([IT_NUMBER isEqual:[_aUtil parse:@"02-36618 300" defaultRegion:@"IT" error:&anError]]);
        XCTAssertTrue([IT_MOBILE isEqual:[_aUtil parse:@"345 678 901" defaultRegion:@"IT" error:&anError]]);
    }

    
    #pragma mark - testParseNationalNumberArgentina
    {
        NSError *anError = nil;
        NSLog(@"-------------- testParseNationalNumberArgentina");
        // Test parsing mobile numbers of Argentina.
        RingcNBPhoneNumber *arNumber = [[RingcNBPhoneNumber alloc] init];
        [arNumber setCountryCode:@54];
        [arNumber setNationalNumber:@93435551212];
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"+54 9 343 555 1212" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"0343 15 555 1212" defaultRegion:@"AR" error:&anError]]);
        
        arNumber = [[RingcNBPhoneNumber alloc] init];
        [arNumber setCountryCode:@54];
        [arNumber setNationalNumber:@93715654320];
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"+54 9 3715 65 4320" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"03715 15 65 4320" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([AR_MOBILE isEqual:[_aUtil parse:@"911 876 54321" defaultRegion:@"AR" error:&anError]]);
        
        // Test parsing fixed-line numbers of Argentina.
        XCTAssertTrue([AR_NUMBER isEqual:[_aUtil parse:@"+54 11 8765 4321" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([AR_NUMBER isEqual:[_aUtil parse:@"011 8765 4321" defaultRegion:@"AR" error:&anError]]);
        
        arNumber = [[RingcNBPhoneNumber alloc] init];
        [arNumber setCountryCode:@54];
        [arNumber setNationalNumber:@3715654321];
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"+54 3715 65 4321" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"03715 65 4321" defaultRegion:@"AR" error:&anError]]);
        
        arNumber = [[RingcNBPhoneNumber alloc] init];
        [arNumber setCountryCode:@54];
        [arNumber setNationalNumber:@2312340000];
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"+54 23 1234 0000" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([arNumber isEqual:[_aUtil parse:@"023 1234 0000" defaultRegion:@"AR" error:&anError]]);
    }

    
    #pragma mark - testParseWithXInNumber
    {
        NSError *anError = nil;
        NSLog(@"-------------- testParseWithXInNumber");
        // Test that having an 'x' in the phone number at the start is ok and that it
        // just gets removed.
        XCTAssertTrue([AR_NUMBER isEqual:[_aUtil parse:@"01187654321" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([AR_NUMBER isEqual:[_aUtil parse:@"(0) 1187654321" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([AR_NUMBER isEqual:[_aUtil parse:@"0 1187654321" defaultRegion:@"AR" error:&anError]]);
        XCTAssertTrue([AR_NUMBER isEqual:[_aUtil parse:@"(0xx) 1187654321" defaultRegion:@"AR" error:&anError]]);
        
        id arFromUs = [[RingcNBPhoneNumber alloc] init];
        [arFromUs setCountryCode:@54];
        [arFromUs setNationalNumber:@81429712];
        // This test is intentionally constructed such that the number of digit after
        // xx is larger than 7, so that the number won't be mistakenly treated as an
        // extension, as we allow extensions up to 7 digits. This assumption is okay
        // for now as all the countries where a carrier selection code is written in
        // the form of xx have a national significant number of length larger than 7.
        XCTAssertTrue([arFromUs isEqual:[_aUtil parse:@"011xx5481429712" defaultRegion:@"US" error:&anError]]);
    }

    
    #pragma mark - testParseNumbersMexico
    {
        NSError *anError = nil;
        NSLog(@"-------------- testParseNumbersMexico");
        // Test parsing fixed-line numbers of Mexico.
        
        id mxNumber = [[RingcNBPhoneNumber alloc] init];
        [mxNumber setCountryCode:@52];
        [mxNumber setNationalNumber:@4499780001];
        XCTAssertTrue([mxNumber isEqual:[_aUtil parse:@"+52 (449)978-0001" defaultRegion:@"MX" error:&anError]]);
        XCTAssertTrue([mxNumber isEqual:[_aUtil parse:@"01 (449)978-0001" defaultRegion:@"MX" error:&anError]]);
        XCTAssertTrue([mxNumber isEqual:[_aUtil parse:@"(449)978-0001" defaultRegion:@"MX" error:&anError]]);
        
        // Test parsing mobile numbers of Mexico.
        mxNumber = [[RingcNBPhoneNumber alloc] init];
        [mxNumber setCountryCode:@52];
        [mxNumber setNationalNumber:@13312345678];
        XCTAssertTrue([mxNumber isEqual:[_aUtil parse:@"+52 1 33 1234-5678" defaultRegion:@"MX" error:&anError]]);
        XCTAssertTrue([mxNumber isEqual:[_aUtil parse:@"044 (33) 1234-5678" defaultRegion:@"MX" error:&anError]]);
        XCTAssertTrue([mxNumber isEqual:[_aUtil parse:@"045 33 1234-5678" defaultRegion:@"MX" error:&anError]]);
    }

    
    #pragma mark - testFailedParseOnInvalidNumbers
    {
        NSLog(@"-------------- testFailedParseOnInvalidNumbers");
        {
            NSError *anError = nil;
            NSString *sentencePhoneNumber = @"This is not a phone number";
            [_aUtil parse:sentencePhoneNumber defaultRegion:@"NZ" error:&anError];
            
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", sentencePhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain ,@"Wrong error type stored in exception.");
        }
        {
            NSError *anError = nil;
            NSString *sentencePhoneNumber = @"1 Still not a number";
            [_aUtil parse:sentencePhoneNumber defaultRegion:@"NZ" error:&anError];
            
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", sentencePhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *sentencePhoneNumber = @"1 MICROSOFT";
            [_aUtil parse:sentencePhoneNumber defaultRegion:@"NZ" error:&anError];
            
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", sentencePhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
                   
        {
            NSError *anError = nil;
            NSString *sentencePhoneNumber = @"12 MICROSOFT";
            [_aUtil parse:sentencePhoneNumber defaultRegion:@"NZ" error:&anError];
            
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", sentencePhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
                   
        {
            NSError *anError = nil;
            NSString *tooLongPhoneNumber = @"01495 72553301873 810104";
            [_aUtil parse:tooLongPhoneNumber defaultRegion:@"GB" error:&anError];
            
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", tooLongPhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"TOO_LONG", anError.domain, @"Wrong error type stored in exception.");
        }
                   
        {
            NSError *anError = nil;
            NSString *plusMinusPhoneNumber = @"+---";
            [_aUtil parse:plusMinusPhoneNumber defaultRegion:@"DE" error:&anError];
            
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", plusMinusPhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
                   
        {
            NSError *anError = nil;
            NSString *plusStar = @"+***";
            [_aUtil parse:plusStar defaultRegion:@"DE" error:&anError];
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", plusStar);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *plusStarPhoneNumber = @"+*******91";
            [_aUtil parse:plusStarPhoneNumber defaultRegion:@"DE" error:&anError];
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", plusStarPhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *tooShortPhoneNumber = @"+49 0";
            [_aUtil parse:tooShortPhoneNumber defaultRegion:@"DE" error:&anError];
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception %@", tooShortPhoneNumber);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"TOO_SHORT_NSN", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *invalidcountryCode = @"+210 3456 56789";
            [_aUtil parse:invalidcountryCode defaultRegion:@"NZ" error:&anError];
            if (anError == nil)
                XCTFail(@"This is not a recognised region code: should fail: %@", invalidcountryCode);
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *plusAndIddAndInvalidcountryCode = @"+ 00 210 3 331 6005";
            [_aUtil parse:plusAndIddAndInvalidcountryCode defaultRegion:@"NZ" error:&anError];
            if (anError == nil)
                XCTFail(@"This should not parse without throwing an exception.");
            else {
                // Expected this exception. 00 is a correct IDD, but 210 is not a valid
                // country code.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
            }
        }
                   
        {
            NSError *anError = nil;
            NSString *someNumber = @"123 456 7890";
            [_aUtil parse:someNumber defaultRegion:@"ZZ" error:&anError];
            if (anError == nil)
                XCTFail(@"Unknown region code not allowed: should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *someNumber = @"123 456 7890";
            [_aUtil parse:someNumber defaultRegion:@"CS" error:&anError];
            if (anError == nil)
                XCTFail(@"Deprecated region code not allowed: should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *someNumber = @"123 456 7890";
            [_aUtil parse:someNumber defaultRegion:nil error:&anError];
            if (anError == nil)
                XCTFail(@"nil region code not allowed: should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
        }
        
        
        {
            NSError *anError = nil;
            NSString *someNumber = @"0044------";
            [_aUtil parse:someNumber defaultRegion:@"GB" error:&anError];
            if (anError == nil)
                XCTFail(@"No number provided, only region code: should fail");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"TOO_SHORT_AFTER_IDD", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *someNumber = @"0044";
            [_aUtil parse:someNumber defaultRegion:@"GB" error:&anError];
            if (anError == nil)
                XCTFail(@"No number provided, only region code: should fail");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"TOO_SHORT_AFTER_IDD", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *someNumber = @"011";
            [_aUtil parse:someNumber defaultRegion:@"US" error:&anError];
            if (anError == nil)
                XCTFail(@"Only IDD provided - should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"TOO_SHORT_AFTER_IDD", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *someNumber = @"0119";
            [_aUtil parse:someNumber defaultRegion:@"US" error:&anError];
            if (anError == nil)
                XCTFail(@"Only IDD provided and then 9 - should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"TOO_SHORT_AFTER_IDD", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *emptyNumber = @"";
            // Invalid region.
            [_aUtil parse:emptyNumber defaultRegion:@"ZZ" error:&anError];
            if (anError == nil)
                XCTFail(@"Empty string - should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            // Invalid region.
            [_aUtil parse:nil defaultRegion:@"ZZ" error:&anError];
            if (anError == nil)
                XCTFail(@"nil string - should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            [_aUtil parse:nil defaultRegion:@"US" error:&anError];
            if (anError == nil)
                XCTFail(@"nil string - should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"NOT_A_NUMBER", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            NSString *domainRfcPhoneContext = @"tel:555-1234;phone-context=www.google.com";
            [_aUtil parse:domainRfcPhoneContext defaultRegion:@"ZZ" error:&anError];
            if (anError == nil)
                XCTFail(@"Unknown region code not allowed: should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
        }
        
        {
            NSError *anError = nil;
            // This is invalid because no '+' sign is present as part of phone-context.
            // This should not succeed in being parsed.
            
            NSString *invalidRfcPhoneContext = @"tel:555-1234;phone-context=1-331";
            [_aUtil parse:invalidRfcPhoneContext defaultRegion:@"ZZ" error:&anError];
            if (anError == nil)
                XCTFail(@"Unknown region code not allowed: should fail.");
            else
                // Expected this exception.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
        }
    }
    

    #pragma mark - testParseNumbersWithPlusWithNoRegion
    {
        NSLog(@"-------------- testParseNumbersWithPlusWithNoRegion");
        NSError *anError;
        // @"ZZ is allowed only if the number starts with a '+' - then the
        // country calling code can be calculated.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"+64 3 331 6005" defaultRegion:@"ZZ" error:&anError]]);
        // Test with full-width plus.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"\uFF0B64 3 331 6005" defaultRegion:@"ZZ" error:&anError]]);
        // Test with normal plus but leading characters that need to be stripped.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"Tel: +64 3 331 6005" defaultRegion:@"ZZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"+64 3 331 6005" defaultRegion:nil error:&anError]]);
        XCTAssertTrue([INTERNATIONAL_TOLL_FREE isEqual:[_aUtil parse:@"+800 1234 5678" defaultRegion:nil error:&anError]]);
        XCTAssertTrue([UNIVERSAL_PREMIUM_RATE isEqual:[_aUtil parse:@"+979 123 456 789" defaultRegion:nil error:&anError]]);
        
        // Test parsing RFC3966 format with a phone context.
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:03-331-6005;phone-context=+64" defaultRegion:@"ZZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"  tel:03-331-6005;phone-context=+64" defaultRegion:@"ZZ" error:&anError]]);
        XCTAssertTrue([NZ_NUMBER isEqual:[_aUtil parse:@"tel:03-331-6005;isub=12345;phone-context=+64" defaultRegion:@"ZZ" error:&anError]]);
        
        // It is important that we set the carrier code to an empty string, since we
        // used ParseAndKeepRawInput and no carrier code was found.
        
        id nzNumberWithRawInput = [NZ_NUMBER copy];
        [nzNumberWithRawInput setRawInput:@"+64 3 331 6005"];
        [nzNumberWithRawInput setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_NUMBER_WITH_PLUS_SIGN]];
        [nzNumberWithRawInput setPreferredDomesticCarrierCode:@""];
        XCTAssertTrue([nzNumberWithRawInput isEqual:[_aUtil parseAndKeepRawInput:@"+64 3 331 6005" defaultRegion:@"ZZ" error:&anError]]);
        // nil is also allowed for the region code in these cases.
        XCTAssertTrue([nzNumberWithRawInput isEqual:[_aUtil parseAndKeepRawInput:@"+64 3 331 6005" defaultRegion:nil error:&anError]]);
    }


    #pragma mark - testParseExtensions
    {
        NSError *anError = nil;
        NSLog(@"-------------- testParseExtensions");
        RingcNBPhoneNumber *nzNumber = [[RingcNBPhoneNumber alloc] init];
        [nzNumber setCountryCode:@64];
        [nzNumber setNationalNumber:@33316005];
        [nzNumber setExtension:@"3456"];
        XCTAssertTrue([nzNumber isEqual:[_aUtil parse:@"03 331 6005 ext 3456" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([nzNumber isEqual:[_aUtil parse:@"03-3316005x3456" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([nzNumber isEqual:[_aUtil parse:@"03-3316005 int.3456" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([nzNumber isEqual:[_aUtil parse:@"03 3316005 #3456" defaultRegion:@"NZ" error:&anError]]);
        
        // Test the following do not extract extensions:
        XCTAssertTrue([ALPHA_NUMERIC_NUMBER isEqual:[_aUtil parse:@"1800 six-flags" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([ALPHA_NUMERIC_NUMBER isEqual:[_aUtil parse:@"1800 SIX FLAGS" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([ALPHA_NUMERIC_NUMBER isEqual:[_aUtil parse:@"0~0 1800 7493 5247" defaultRegion:@"PL" error:&anError]]);
        XCTAssertTrue([ALPHA_NUMERIC_NUMBER isEqual:[_aUtil parse:@"(1800) 7493.5247" defaultRegion:@"US" error:&anError]]);
        
        // Check that the last instance of an extension token is matched.
        
        id extnNumber = [ALPHA_NUMERIC_NUMBER copy];
        [extnNumber setExtension:@"1234"];
        XCTAssertTrue([extnNumber isEqual:[_aUtil parse:@"0~0 1800 7493 5247 ~1234" defaultRegion:@"PL" error:&anError]]);
        
        // Verifying bug-fix where the last digit of a number was previously omitted
        // if it was a 0 when extracting the extension. Also verifying a few different
        // cases of extensions.
        
        id ukNumber = [[RingcNBPhoneNumber alloc] init];
        [ukNumber setCountryCode:@44];
        [ukNumber setNationalNumber:@2034567890];
        [ukNumber setExtension:@"456"];
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890x456" defaultRegion:@"NZ" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890x456" defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890 x456" defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890 X456" defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890 X 456" defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890 X  456" defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890 x 456  " defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44 2034567890  X 456" defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+44-2034567890;ext=456" defaultRegion:@"GB" error:&anError]]);
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"tel:2034567890;ext=456;phone-context=+44" defaultRegion:@"ZZ" error:&anError]]);
        // Full-width extension, @"extn' only.
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+442034567890\uFF45\uFF58\uFF54\uFF4E456" defaultRegion:@"GB" error:&anError]]);
        // 'xtn' only.
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+442034567890\uFF58\uFF54\uFF4E456" defaultRegion:@"GB" error:&anError]]);
        // 'xt' only.
        XCTAssertTrue([ukNumber isEqual:[_aUtil parse:@"+442034567890\uFF58\uFF54456" defaultRegion:@"GB" error:&anError]]);
        
        id usWithExtension = [[RingcNBPhoneNumber alloc] init];
        [usWithExtension setCountryCode:@1];
        [usWithExtension setNationalNumber:@8009013355];
        [usWithExtension setExtension:@"7246433"];
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"(800) 901-3355 x 7246433" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"(800) 901-3355 , ext 7246433" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"(800) 901-3355 ,extension 7246433" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"(800) 901-3355 ,extensi\u00F3n 7246433" defaultRegion:@"US" error:&anError]]);
        
        // Repeat with the small letter o with acute accent created by combining
        // characters.
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"(800) 901-3355 ,extensio\u0301n 7246433" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"(800) 901-3355 , 7246433" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"(800) 901-3355 ext: 7246433" defaultRegion:@"US" error:&anError]]);
        
        // Test that if a number has two extensions specified, we ignore the second.
        id usWithTwoExtensionsNumber = [[RingcNBPhoneNumber alloc] init];
        [usWithTwoExtensionsNumber setCountryCode:@1];
        [usWithTwoExtensionsNumber setNationalNumber:@2121231234];
        [usWithTwoExtensionsNumber setExtension:@"508"];
        XCTAssertTrue([usWithTwoExtensionsNumber isEqual:[_aUtil parse:@"(212)123-1234 x508/x1234" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([usWithTwoExtensionsNumber isEqual:[_aUtil parse:@"(212)123-1234 x508/ x1234" defaultRegion:@"US" error:&anError]]);
        XCTAssertTrue([usWithTwoExtensionsNumber isEqual:[_aUtil parse:@"(212)123-1234 x508\\x1234" defaultRegion:@"US" error:&anError]]);
        
        // Test parsing numbers in the form (645) 123-1234-910# works, where the last
        // 3 digits before the # are an extension.
        usWithExtension = [[RingcNBPhoneNumber alloc] init];
        [usWithExtension setCountryCode:@1];
        [usWithExtension setNationalNumber:@6451231234];
        [usWithExtension setExtension:@"910"];
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"+1 (645) 123 1234-910#" defaultRegion:@"US" error:&anError]]);
        // Retry with the same number in a slightly different format.
        XCTAssertTrue([usWithExtension isEqual:[_aUtil parse:@"+1 (645) 123 1234 ext. 910#" defaultRegion:@"US" error:&anError]]);
    }
    
        
    #pragma mark - testParseAndKeepRaw
    {
        NSError *anError;
        NSLog(@"-------------- testParseAndKeepRaw");
        RingcNBPhoneNumber *alphaNumericNumber = [ALPHA_NUMERIC_NUMBER copy];
        [alphaNumericNumber setRawInput:@"800 six-flags"];
        [alphaNumericNumber setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_DEFAULT_COUNTRY]];
        [alphaNumericNumber setPreferredDomesticCarrierCode:@""];
        XCTAssertTrue([alphaNumericNumber isEqual:[_aUtil parseAndKeepRawInput:@"800 six-flags" defaultRegion:@"US" error:&anError]]);
        
        id shorterAlphaNumber = [[RingcNBPhoneNumber alloc] init];
        [shorterAlphaNumber setCountryCode:@1];
        [shorterAlphaNumber setNationalNumber:@8007493524];
        [shorterAlphaNumber setRawInput:@"1800 six-flag"];
        [shorterAlphaNumber setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_NUMBER_WITHOUT_PLUS_SIGN]];
        [shorterAlphaNumber setPreferredDomesticCarrierCode:@""];
        XCTAssertTrue([shorterAlphaNumber isEqual:[_aUtil parseAndKeepRawInput:@"1800 six-flag" defaultRegion:@"US" error:&anError]]);
        
        [shorterAlphaNumber setRawInput:@"+1800 six-flag"];
        [shorterAlphaNumber setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_NUMBER_WITH_PLUS_SIGN]];
        XCTAssertTrue([shorterAlphaNumber isEqual:[_aUtil parseAndKeepRawInput:@"+1800 six-flag" defaultRegion:@"NZ" error:&anError]]);
        
        [alphaNumericNumber setCountryCode:@1];
        [alphaNumericNumber setNationalNumber:@8007493524];
        [alphaNumericNumber setRawInput:@"001800 six-flag"];
        [alphaNumericNumber setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_NUMBER_WITH_IDD]];
        XCTAssertTrue([alphaNumericNumber isEqual:[_aUtil parseAndKeepRawInput:@"001800 six-flag" defaultRegion:@"NZ" error:&anError]]);
        
        // Invalid region code supplied.
        {
            [_aUtil parseAndKeepRawInput:@"123 456 7890" defaultRegion:@"CS" error:&anError];
            if (anError == nil)
                XCTFail(@"Deprecated region code not allowed: should fail.");
            else {
                // Expected this exception.
                XCTAssertEqualObjects(@"INVALID_COUNTRY_CODE", anError.domain, @"Wrong error type stored in exception.");
            }
        }
        
        id koreanNumber = [[RingcNBPhoneNumber alloc] init];
        [koreanNumber setCountryCode:@82];
        [koreanNumber setNationalNumber:@22123456];
        [koreanNumber setRawInput:@"08122123456"];
        [koreanNumber setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_DEFAULT_COUNTRY]];
        [koreanNumber setPreferredDomesticCarrierCode:@"81"];
        XCTAssertTrue([koreanNumber isEqual:[_aUtil parseAndKeepRawInput:@"08122123456" defaultRegion:@"KR" error:&anError]]);
    }
    
        
    #pragma mark - testCountryWithNoNumberDesc
    {
        NSLog(@"-------------- testCountryWithNoNumberDesc");
        // Andorra is a country where we don't have PhoneNumberDesc info in the
        // metadata.
        RingcNBPhoneNumber *adNumber = [[RingcNBPhoneNumber alloc] init];
        [adNumber setCountryCode:@376];
        [adNumber setNationalNumber:@12345];
        XCTAssertEqualObjects(@"+376 12345", [_aUtil format:adNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
        XCTAssertEqualObjects(@"+37612345", [_aUtil format:adNumber numberFormat:NBEPhoneNumberFormatE164]);
        XCTAssertEqualObjects(@"12345", [_aUtil format:adNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
        XCTAssertEqual(NBEPhoneNumberTypeUNKNOWN, [_aUtil getNumberType:adNumber]);
        XCTAssertTrue([_aUtil isValidNumber:adNumber]);
        
        // Test dialing a US number from within Andorra.
        XCTAssertEqualObjects(@"00 1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"AD"]);
    }

    
    #pragma mark - testUnknownCountryCallingCode
    {
        NSLog(@"-------------- testUnknownCountryCallingCode");
        XCTAssertFalse([_aUtil isValidNumber:UNKNOWN_COUNTRY_CODE_NO_RAW_INPUT]);
        // It's not very well defined as to what the E164 representation for a number
        // with an invalid country calling code is, but just prefixing the country
        // code and national number is about the best we can do.
        XCTAssertEqualObjects(@"+212345", [_aUtil format:UNKNOWN_COUNTRY_CODE_NO_RAW_INPUT numberFormat:NBEPhoneNumberFormatE164]);
    }

    
    #pragma mark - testIsNumberMatchMatches
    {
        NSLog(@"-------------- testIsNumberMatchMatches");
        // Test simple matches where formatting is different, or leading zeroes,
        // or country calling code has been specified.
        
        NSError *anError = nil;
        
        RingcNBPhoneNumber *num1 = [_aUtil parse:@"+64 3 331 6005" defaultRegion:@"NZ" error:&anError];
        RingcNBPhoneNumber *num2 = [_aUtil parse:@"+64 03 331 6005" defaultRegion:@"NZ" error:&anError];
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:num1 second:num2]);
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+64 3 331 6005" second:@"+64 03 331 6005"]);
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+800 1234 5678" second:@"+80012345678"]);
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+64 03 331-6005" second:@"+64 03331 6005"]);
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+643 331-6005" second:@"+64033316005"]);
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+643 331-6005" second:@"+6433316005"]);
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"+6433316005"]);
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"tel:+64-3-331-6005;isub=123"]);
        // Test alpha numbers.
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+1800 siX-Flags" second:@"+1 800 7493 5247"]);
        // Test numbers with extensions.
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005 extn 1234" second:@"+6433316005#1234"]);
        // Test proto buffers.
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:NZ_NUMBER second:@"+6403 331 6005"]);
        
        RingcNBPhoneNumber *nzNumber = [NZ_NUMBER copy];
        [nzNumber setExtension:@"3456"];
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:nzNumber second:@"+643 331 6005 ext 3456"]);
        // Check empty extensions are ignored.
        [nzNumber setExtension:@""];
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:nzNumber second:@"+6403 331 6005"]);
        // Check variant with two proto buffers.
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:nzNumber second:NZ_NUMBER], @"Numbers did not match");
        
        // Check raw_input, country_code_source and preferred_domestic_carrier_code
        // are ignored.
        
        RingcNBPhoneNumber *brNumberOne = [[RingcNBPhoneNumber alloc] init];
        
        RingcNBPhoneNumber *brNumberTwo = [[RingcNBPhoneNumber alloc] init];
        [brNumberOne setCountryCode:@55];
        [brNumberOne setNationalNumber:@3121286979];
        [brNumberOne setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_NUMBER_WITH_PLUS_SIGN]];
        [brNumberOne setPreferredDomesticCarrierCode:@"12"];
        [brNumberOne setRawInput:@"012 3121286979"];
        [brNumberTwo setCountryCode:@55];
        [brNumberTwo setNationalNumber:@3121286979];
        [brNumberTwo setCountryCodeSource:[NSNumber numberWithInt:NBECountryCodeSourceFROM_DEFAULT_COUNTRY]];
        [brNumberTwo setPreferredDomesticCarrierCode:@"14"];
        [brNumberTwo setRawInput:@"143121286979"];
        XCTAssertEqual(NBEMatchTypeEXACT_MATCH, [_aUtil isNumberMatch:brNumberOne second:brNumberTwo]);
    }

    #pragma mark - testIsNumberMatchNonMatches
    {
        NSLog(@"-------------- testIsNumberMatchNonMatches");
        // Non-matches.
        XCTAssertEqual(NBEMatchTypeNO_MATCH, [_aUtil isNumberMatch:@"03 331 6005" second:@"03 331 6006"]);
        XCTAssertEqual(NBEMatchTypeNO_MATCH, [_aUtil isNumberMatch:@"+800 1234 5678" second:@"+1 800 1234 5678"]);
        // Different country calling code, partial number match.
        XCTAssertEqual(NBEMatchTypeNO_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"+16433316005"]);
        // Different country calling code, same number.
        XCTAssertEqual(NBEMatchTypeNO_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"+6133316005"]);
        // Extension different, all else the same.
        XCTAssertEqual(NBEMatchTypeNO_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005 extn 1234" second:@"0116433316005#1235"]);
        XCTAssertEqual(NBEMatchTypeNO_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005 extn 1234" second:@"tel:+64-3-331-6005;ext=1235"]);
        // NSN matches, but extension is different - not the same number.
        XCTAssertEqual(NBEMatchTypeNO_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005 ext.1235" second:@"3 331 6005#1234"]);
        
        // Invalid numbers that can't be parsed.
        XCTAssertEqual(NBEMatchTypeNOT_A_NUMBER, [_aUtil isNumberMatch:@"4" second:@"3 331 6043"]);
        XCTAssertEqual(NBEMatchTypeNOT_A_NUMBER, [_aUtil isNumberMatch:@"+43" second:@"+64 3 331 6005"]);
        XCTAssertEqual(NBEMatchTypeNOT_A_NUMBER, [_aUtil isNumberMatch:@"+43" second:@"64 3 331 6005"]);
        XCTAssertEqual(NBEMatchTypeNOT_A_NUMBER, [_aUtil isNumberMatch:@"Dog" second:@"64 3 331 6005"]);
    }

    
    #pragma mark - testIsNumberMatchNsnMatches
    {
        NSLog(@"-------------- testIsNumberMatchNsnMatches");
        // NSN matches.
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"03 331 6005"]);
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"tel:03-331-6005;isub=1234;phone-context=abc.nz"]);
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:NZ_NUMBER second:@"03 331 6005"]);
        // Here the second number possibly starts with the country calling code for
        // New Zealand, although we are unsure.
        
        RingcNBPhoneNumber *unchangedNzNumber = [NZ_NUMBER copy];
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:unchangedNzNumber second:@"(64-3) 331 6005"]);
        // Check the phone number proto was not edited during the method call.
        XCTAssertTrue([NZ_NUMBER isEqual:unchangedNzNumber]);
        
        // Here, the 1 might be a national prefix, if we compare it to the US number,
        // so the resultant match is an NSN match.
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:US_NUMBER second:@"1-650-253-0000"]);
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:US_NUMBER second:@"6502530000"]);
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:@"+1 650-253 0000" second:@"1 650 253 0000"]);
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:@"1 650-253 0000" second:@"1 650 253 0000"]);
        XCTAssertEqual(NBEMatchTypeNSN_MATCH, [_aUtil isNumberMatch:@"1 650-253 0000" second:@"+1 650 253 0000"]);
        // For this case, the match will be a short NSN match, because we cannot
        // assume that the 1 might be a national prefix, so don't remove it when
        // parsing.
        
        RingcNBPhoneNumber *randomNumber = [[RingcNBPhoneNumber alloc] init];
        [randomNumber setCountryCode:@41];
        [randomNumber setNationalNumber:@6502530000];
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:randomNumber second:@"1-650-253-0000"]);
    }

    
    #pragma mark - testIsNumberMatchShortNsnMatches
    {
        NSLog(@"-------------- testIsNumberMatchShortNsnMatches");
        // Short NSN matches with the country not specified for either one or both
        // numbers.
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"331 6005"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"tel:331-6005;phone-context=abc.nz"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"tel:331-6005;isub=1234;phone-context=abc.nz"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"tel:331-6005;isub=1234;phone-context=abc.nz;a=%A1"]);
        // We did not know that the '0' was a national prefix since neither number has
        // a country code, so this is considered a SHORT_NSN_MATCH.
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"3 331-6005" second:@"03 331 6005"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"3 331-6005" second:@"331 6005"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"3 331-6005" second:@"tel:331-6005;phone-context=abc.nz"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"3 331-6005" second:@"+64 331 6005"]);
        // Short NSN match with the country specified.
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"03 331-6005" second:@"331 6005"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"1 234 345 6789" second:@"345 6789"]);
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"+1 (234) 345 6789" second:@"345 6789"]);
        // NSN matches, country calling code omitted for one number, extension missing
        // for one.
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:@"+64 3 331-6005" second:@"3 331 6005#1234"]);
        // One has Italian leading zero, one does not.
        
        RingcNBPhoneNumber *italianNumberOne = [[RingcNBPhoneNumber alloc] init];
        [italianNumberOne setCountryCode:@39];
        [italianNumberOne setNationalNumber:@1234];
        [italianNumberOne setItalianLeadingZero:YES];
        
        RingcNBPhoneNumber *italianNumberTwo = [[RingcNBPhoneNumber alloc] init];
        [italianNumberTwo setCountryCode:@39];
        [italianNumberTwo setNationalNumber:@1234];
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:italianNumberOne second:italianNumberTwo]);
        // One has an extension, the other has an extension of ''.
        [italianNumberOne setExtension:@"1234"];
        italianNumberOne.italianLeadingZero = NO;
        [italianNumberTwo setExtension:@""];
        XCTAssertEqual(NBEMatchTypeSHORT_NSN_MATCH, [_aUtil isNumberMatch:italianNumberOne second:italianNumberTwo]);
    }

    
    #pragma mark - testCanBeInternationallyDialled
    {
        NSLog(@"-------------- testCanBeInternationallyDialled");
        // We have no-international-dialling rules for the US in our test metadata
        // that say that toll-free numbers cannot be dialled internationally.
        XCTAssertFalse([_aUtil canBeInternationallyDialled:US_TOLLFREE]);
        
        // Normal US numbers can be internationally dialled.
        XCTAssertTrue([_aUtil canBeInternationallyDialled:US_NUMBER]);
        
        // Invalid number.
        XCTAssertTrue([_aUtil canBeInternationallyDialled:US_LOCAL_NUMBER]);
        
        // We have no data for NZ - should return true.
        XCTAssertTrue([_aUtil canBeInternationallyDialled:NZ_NUMBER]);
        XCTAssertTrue([_aUtil canBeInternationallyDialled:INTERNATIONAL_TOLL_FREE]);
    }

    
    #pragma mark - testIsAlphaNumber
    {
        NSLog(@"-------------- testIsAlphaNumber");
        XCTAssertTrue([_aUtil isAlphaNumber:@"1800 six-flags"]);
        XCTAssertTrue([_aUtil isAlphaNumber:@"1800 six-flags ext. 1234"]);
        XCTAssertTrue([_aUtil isAlphaNumber:@"+800 six-flags"]);
        XCTAssertTrue([_aUtil isAlphaNumber:@"180 six-flags"]);
        XCTAssertFalse([_aUtil isAlphaNumber:@"1800 123-1234"]);
        XCTAssertFalse([_aUtil isAlphaNumber:@"1 six-flags"]);
        XCTAssertFalse([_aUtil isAlphaNumber:@"18 six-flags"]);
        XCTAssertFalse([_aUtil isAlphaNumber:@"1800 123-1234 extension: 1234"]);
        XCTAssertFalse([_aUtil isAlphaNumber:@"+800 1234-1234"]);
    }
}
@end
