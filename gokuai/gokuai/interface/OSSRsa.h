#import <Foundation/Foundation.h>


@interface OSSRsaItem : NSObject
{
    BOOL    ret;
    NSData* check;
    NSData* key;
    NSData* secret;
}

@property(nonatomic)BOOL ret;
@property(nonatomic,retain)NSData* check;
@property(nonatomic,retain)NSData* key;
@property(nonatomic,retain)NSData* secret;

@end



@interface OSSRsa : NSObject

+(OSSRsaItem*)EncryptKey:(NSData*)key secret:(NSData*)secret;
+(OSSRsaItem*)EncryptKey:(NSData*)key secret:(NSData*)secret device:(NSString*)devicehash;
+(OSSRsaItem*)DecryptKey:(NSData*)check key:(NSData*)key secret:(NSData*)secret;

+(NSData*)CryptEncrypt:(NSString*)strKey data:(NSData*)data;
+(NSData*)CryptDecrypt:(NSString*)strKey data:(NSData*)data;

+(NSString*)getcomputerid;
+(NSData*)GetGuid;
@end
