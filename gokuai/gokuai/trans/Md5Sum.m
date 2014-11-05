#import "Md5Sum.h"

@implementation Md5Sum

-(id)init
{
    if (self=[super init]) {
        CC_MD5_Init(&ccmd5);
    }
    return self;
}

-(void)Reset
{
    CC_MD5_Init(&ccmd5);
}

-(void)AddData:(NSData*)data
{
    CC_MD5_Update(&ccmd5, [data bytes], [data length]);
}

-(void)Final
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest,&ccmd5);
    strHash=[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",digest[0],digest[1],digest[2],digest[3],digest[4],digest[5],digest[6],digest[7],digest[8],digest[9],digest[10],digest[11],digest[12],digest[13],digest[14],digest[15]];
}

-(NSString*)GetHash
{
    return strHash;
}

@end
