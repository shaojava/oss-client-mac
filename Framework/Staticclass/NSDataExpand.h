#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (NSDataExpand)
-(NSData*)      md5HexDigest;
-(NSString*)    sha1HexDigest;
-(NSString*)    md5Data2String;
-(uint32_t)     crc32;
+(NSData*)      base64Decoded:(NSString*)string;
-(NSString*)    base64Encoded;

@end
