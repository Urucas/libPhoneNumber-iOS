//
//  NBPhoneNumber.m
//  libPhoneNumber
//
//

#import "RingcNBPhoneNumber.h"

#import "RingcNBPhoneNumberDefines.h"


@implementation RingcNBPhoneNumber

- (id)init
{
    self = [super init];
    
    if (self) {
        self.countryCodeSource = nil;
        self.italianLeadingZero = NO;
        self.nationalNumber = @-1;
        self.countryCode = @-1;
    }
    
    return self;
}


- (void)clearCountryCodeSource
{
    [self setCountryCodeSource:nil];
}


- (NBECountryCodeSource)getCountryCodeSourceOrDefault
{
    if (!self.countryCodeSource) {
        return NBECountryCodeSourceFROM_NUMBER_WITH_PLUS_SIGN;
    }
    
    return [self.countryCodeSource intValue];
}


- (BOOL)isEqualToObject:(RingcNBPhoneNumber*)otherObj
{
    return [self isEqual:otherObj];
}


- (NSUInteger)hash
{
    NSData *selfObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [selfObject hash];
}


- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[RingcNBPhoneNumber class]]) {
        return NO;
    }
    
    RingcNBPhoneNumber *other = object;
    return ([self.countryCode isEqualToNumber:other.countryCode]) && ([self.nationalNumber isEqualToNumber:other.nationalNumber]) &&
        (self.italianLeadingZero == other.italianLeadingZero) &&
        ((self.extension == nil && other.extension == nil) || [self.extension isEqualToString:other.extension]);
}


- (id)copyWithZone:(NSZone *)zone
{
	RingcNBPhoneNumber *phoneNumberCopy = [[RingcNBPhoneNumber allocWithZone:zone] init];
    
	phoneNumberCopy.countryCode = [self.countryCode copy];
    phoneNumberCopy.nationalNumber = [self.nationalNumber copy];
    phoneNumberCopy.extension = [self.extension copy];
    phoneNumberCopy.italianLeadingZero = self.italianLeadingZero;
    phoneNumberCopy.rawInput = [self.rawInput copy];
    phoneNumberCopy.countryCodeSource = [self.countryCodeSource copy];
    phoneNumberCopy.preferredDomesticCarrierCode = [self.preferredDomesticCarrierCode copy];
    
	return phoneNumberCopy;
}


- (id)initWithCoder:(NSCoder*)coder
{
    if (self = [super init]) {
        self.countryCode = [coder decodeObjectForKey:@"countryCode"];
        self.nationalNumber = [coder decodeObjectForKey:@"nationalNumber"];
        self.extension = [coder decodeObjectForKey:@"extension"];
        self.italianLeadingZero = [[coder decodeObjectForKey:@"italianLeadingZero"] boolValue];
        self.rawInput = [coder decodeObjectForKey:@"rawInput"];
        self.countryCodeSource = [coder decodeObjectForKey:@"countryCodeSource"];
        self.preferredDomesticCarrierCode = [coder decodeObjectForKey:@"preferredDomesticCarrierCode"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:self.countryCode forKey:@"countryCode"];
    [coder encodeObject:self.nationalNumber forKey:@"nationalNumber"];
    [coder encodeObject:self.extension forKey:@"extension"];
    [coder encodeObject:[NSNumber numberWithBool:self.italianLeadingZero] forKey:@"italianLeadingZero"];
    [coder encodeObject:self.rawInput forKey:@"rawInput"];
    [coder encodeObject:self.countryCodeSource forKey:@"countryCodeSource"];
    [coder encodeObject:self.preferredDomesticCarrierCode forKey:@"preferredDomesticCarrierCode"];
}



- (NSString *)description
{
    return [NSString stringWithFormat:@" - countryCode[%@], nationalNumber[%@], extension[%@], italianLeadingZero[%@], rawInput[%@] countryCodeSource[%d] preferredDomesticCarrierCode[%@]", self.countryCode, self.nationalNumber, self.extension, self.italianLeadingZero?@"Y":@"N", self.rawInput, [self.countryCodeSource intValue], self.preferredDomesticCarrierCode];
}

@end