//
//  M2PhoneMetaData.h
//  libPhoneNumber
//
//

#import <Foundation/Foundation.h>


@class RingcNBPhoneNumberDesc, RingcNBNumberFormat;

@interface RingcNBPhoneMetaData : NSObject

// from phonemetadata.pb.js
/*  1 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *generalDesc;
/*  2 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *fixedLine;
/*  3 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *mobile;
/*  4 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *tollFree;
/*  5 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *premiumRate;
/*  6 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *sharedCost;
/*  7 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *personalNumber;
/*  8 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *voip;
/* 21 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *pager;
/* 25 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *uan;
/* 27 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *emergency;
/* 28 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *voicemail;
/* 24 */ @property (nonatomic, strong) RingcNBPhoneNumberDesc *noInternationalDialling;
/*  9 */ @property (nonatomic, strong) NSString *codeID;
/* 10 */ @property (nonatomic, strong) NSNumber *countryCode;
/* 11 */ @property (nonatomic, strong) NSString *internationalPrefix;
/* 17 */ @property (nonatomic, strong) NSString *preferredInternationalPrefix;
/* 12 */ @property (nonatomic, strong) NSString *nationalPrefix;
/* 13 */ @property (nonatomic, strong) NSString *preferredExtnPrefix;
/* 15 */ @property (nonatomic, strong) NSString *nationalPrefixForParsing;
/* 16 */ @property (nonatomic, strong) NSString *nationalPrefixTransformRule;
/* 18 */ @property (nonatomic, assign) BOOL sameMobileAndFixedLinePattern;
/* 19 */ @property (nonatomic, strong) NSMutableArray *numberFormats;
/* 20 */ @property (nonatomic, strong) NSMutableArray *intlNumberFormats;
/* 22 */ @property (nonatomic, assign) BOOL mainCountryForCode;
/* 23 */ @property (nonatomic, strong) NSString *leadingDigits;
/* 26 */ @property (nonatomic, assign) BOOL leadingZeroPossible;

@end
