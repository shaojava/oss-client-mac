#import "NSStringExpand.h"
#import "NSDataExpand.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (NSStringExpand)

-(NSString *)md5HexDigest
{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return hash;
}

-(NSString*)sha1HexDigest
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes],(CC_LONG)[data length], digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i<CC_SHA1_DIGEST_LENGTH;i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

-(NSData*)hmac_sha1:(NSString*)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];    
    CCHmac(kCCHmacAlgSHA1, cKey, [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cData, [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], cHMAC);
    return [NSData dataWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
}

+(NSString *)base64Decoded:(NSString *)string
{
    NSData *data = [NSData base64Decoded:string];
    if (data)
    {
        NSString *result = [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
#if !__has_feature(objc_arc)
        [result autorelease];
#endif
        return result;
    }
    return nil;
}

-(NSString*)base64Decoded
{
    return [NSString base64Decoded:self];
}

-(NSString*)base64Encoded
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64Encoded];
}

-(NSString*)toUtf8
{
    NSString* preprocessedString = (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)self,CFSTR(""), kCFStringEncodingUTF8);
    NSString*resultStr =[(NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)preprocessedString, nil, nil, kCFStringEncodingUTF8)autorelease];
    [preprocessedString release];
    return resultStr;
}

-(NSString*)urlDecoded
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

-(NSString*)urlEncoded
{
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" ,    @"$" , @"," ,
                            @"!", @"'", @"(", @")", @"*",@".", nil];
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F", @"%3F" , @"%3A" ,
                             @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" , @"%2C" ,
                             @"%21", @"%27", @"%28", @"%29", @"%2A",@"%2E", nil];
    NSInteger len = [escapeChars count];
    NSMutableString *temp = [[[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]mutableCopy] autorelease];
    int i;
    for (i = 0; i < len; i++) 
    {
        [temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    NSString *outStr = [NSString stringWithString: temp];
    return outStr;
}

-(NSString*)getParent
{
    NSRange range=[self rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location==NSNotFound) {
        return @"";
    }
    return [self substringToIndex:range.location];
}

-(NSString*)getFilename
{
    NSRange range=[self rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location==NSNotFound) {
        return self;
    }
    return [self substringFromIndex:range.location+1];
}

-(NSString*)lastaddslash
{
    if (![self hasSuffix:@"/"]) {
        return [NSString stringWithFormat:@"%@/",self];
    }
    return self;
}

-(NSString*)lastremoveslash
{
    if ([self hasSuffix:@"/"]) {
        return [self substringToIndex:self.length-1];
    }
    return self;
}

-(NSString*)replacetojson
{
    return [self stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
}

@end
