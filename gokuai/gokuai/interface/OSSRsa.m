#import "OSSRsa.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSStringExpand.h"
#import "AESCrypt.h"

#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import "NSDataExpand.h"

@implementation OSSRsaItem

@synthesize check;
@synthesize key;
@synthesize secret;
@synthesize ret;

-(id)init
{
    if (self=[super init]) {
        self.ret=NO;
        self.key=nil;
        self.secret=nil;
        self.check=nil;
    }
    return self;
}

-(void)dealloc
{
    self.check=nil;
    self.key=nil;
    self.secret=nil;
    [super dealloc];
}

@end



@implementation OSSRsa

-(id)init
{
    if (self=[super init]) {
        
    }
    return self;
}

+(OSSRsaItem*)EncryptKey:(NSData*)key secret:(NSData*)secret
{
    NSString * device=[self getcomputerid];
    return [self EncryptKey:key secret:secret device:[device sha1HexDigest]];
}

+(OSSRsaItem*)EncryptKey:(NSData*)key secret:(NSData*)secret device:(NSString*)devicehash
{
    OSSRsaItem * ret=[[[OSSRsaItem alloc]init]autorelease];
    NSString* tempcheck=@"livedeal";
    ret.check=[self CryptEncrypt:devicehash data:[tempcheck dataUsingEncoding:NSUTF8StringEncoding]];
    if (ret.check==nil) {
        return ret;
    }
    NSString *strkey = [[[NSString alloc] initWithData:key encoding:NSUTF8StringEncoding]autorelease];
    NSString* k=[NSString stringWithFormat:@"ossclient-%@%@",devicehash,strkey];
    ret.secret=[self CryptEncrypt:k data:secret];
    if (ret.secret==nil) {
        return ret;
    }
    k=[NSString stringWithFormat:@"ossclient-%@",devicehash];
    ret.key=[self CryptEncrypt:k data:key];
    if (ret.key==nil) {
        return ret;
    }
    ret.ret=YES;
    return ret;
}

+(OSSRsaItem*)DecryptKey:(NSData*)check key:(NSData*)key secret:(NSData*)secret
{
    OSSRsaItem * ret=[[[OSSRsaItem alloc]init]autorelease];
    NSString* device=[self getcomputerid];
    NSString* devicehash=[device sha1HexDigest];
    if (check.length) {
        ret.check=[self CryptDecrypt:devicehash data:check];
        if (ret.check==nil) {
            return ret;
        }
        NSString *strcheck = [[[NSString alloc] initWithData:ret.check encoding:NSUTF8StringEncoding] autorelease];
        if (![strcheck isEqualToString:@"livedeal"]) {
            return ret;
        }
    }
    NSString * k=[NSString stringWithFormat:@"ossclient-%@",devicehash];
    ret.key=[self CryptDecrypt:k data:key];
    if (ret.key==nil) {
        return ret;
    }
    NSString *strkey = [[[NSString alloc] initWithData:ret.key encoding:NSUTF8StringEncoding] autorelease];
    k=[NSString stringWithFormat:@"ossclient-%@%@",devicehash,strkey];
    ret.secret=[self CryptDecrypt:k data:secret];
    if (ret.secret==nil) {
        return ret;
    }
    ret.ret=YES;
    return ret;
}

+(NSData*)CryptEncrypt:(NSString*)strKey data:(NSData*)data
{
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCKeySizeMinRC4;
    char *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmRC4, kCCOptionPKCS7Padding,
                                          [strKey UTF8String], [strKey length],
                                          NULL ,
                                          [data bytes],dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    NSData * ret=nil;
    if (cryptStatus == kCCSuccess) {
        ret=[NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return ret;
}

+(NSData*)CryptDecrypt:(NSString*)strKey data:(NSData*)data
{
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCKeySizeMinRC4;
    char *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmRC4, kCCOptionPKCS7Padding,
                                          [strKey UTF8String], [strKey length],
                                          NULL ,
                                          [data bytes],dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    NSData * ret=nil;
    if (cryptStatus == kCCSuccess) {
        ret=[NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return ret;
}

+(NSString*)getcomputerid
{
    io_registry_entry_t     rootEntry = IORegistryEntryFromPath( kIOMasterPortDefault, "IOService:/" );
    CFTypeRef serialAsCFString = NULL;
    
    serialAsCFString = IORegistryEntryCreateCFProperty( rootEntry,
                                                       CFSTR(kIOPlatformSerialNumberKey),
                                                       kCFAllocatorDefault,
                                                       0);
    IOObjectRelease( rootEntry );
    return [(NSString*)serialAsCFString autorelease];
}

+(NSData*)GetGuid
{
    char buffer[16]={0x27,0x3b,0x80,0xa0,0xe4,0xff,0x0b,0x4c,0x9d,0x4f,0x59,0xd2,0x85,0x87,0xb0,0x9a};
    NSData* data=[[[NSData alloc] initWithBytes:buffer length:16]autorelease];
    return data;
}

@end
