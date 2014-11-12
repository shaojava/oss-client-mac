#import <CommonCrypto/CommonDigest.h>

@interface NSString (NSStringExpand)

-(NSString*)md5HexDigest;
-(NSString*)sha1HexDigest;
-(NSData*)hmac_sha1:(NSString*)key;
+(NSString*)base64Decoded:(NSString *)string;
-(NSString*)base64Decoded;
-(NSString*)base64Encoded;
-(NSString*)toUtf8;
-(NSString*)urlDecoded;
-(NSString*)urlEncoded;
-(NSString*)lastaddslash;
-(NSString*)lastremoveslash;
-(NSString*)replacetojson;
@end
