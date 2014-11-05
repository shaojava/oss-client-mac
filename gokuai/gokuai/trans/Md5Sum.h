#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface Md5Sum : NSObject
{
    NSString*   strHash;
    CC_MD5_CTX  ccmd5;
}

-(id)init;
-(void)Reset;
-(void)AddData:(NSData*)data;
-(void)Final;
-(NSString*)GetHash;

@end
