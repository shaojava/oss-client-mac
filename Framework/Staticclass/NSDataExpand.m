
#import "NSDataExpand.h"

#define DEFAULT_POLYNOMIAL 0xEDB88320L
#define DEFAULT_SEED       0xFFFFFFFFL

@implementation NSData (NSDataExpand)

-(NSData *)md5HexDigest
{
    const char *original_str = [self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (int)[self length], result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

-(NSString*)sha1HexDigest
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes],(CC_LONG)[self length], digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i<CC_SHA1_DIGEST_LENGTH;i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

//- (NSString*)md5Data2String
//{
//    unsigned char result[16];
//    CC_MD5( self.bytes, self.length, result ); // This is the md5 call
//    return [NSString stringWithFormat:
//            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//            result[0], result[1], result[2], result[3],
//            result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11],
//            result[12], result[13], result[14], result[15]
//            ];  
//}
-(NSString*)  md5Data2String
{
    NSData * data=[self md5HexDigest];
    NSMutableString *hash = [NSMutableString string];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    memcpy(result, [data bytes], CC_MD5_DIGEST_LENGTH);
    for (int i = 0; i < data.length; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}
static void generateCRC32Table(uint32_t *pTable, uint32_t poly)
{
    for (uint32_t i = 0; i <= 255; i++)
    {
        uint32_t crc = i;
        
        for (uint32_t j = 8; j > 0; j--)
        {
            if ((crc & 1) == 1)
                crc = (crc >> 1) ^ poly;
            else
                crc >>= 1;
        }
        pTable[i] = crc;
    }
}

-(uint32_t)crc32WithSeed:(uint32_t)seed usingPolynomial:(uint32_t)poly
{
    uint32_t *pTable = (uint32_t *)malloc(sizeof(uint32_t) * 256);
    generateCRC32Table(pTable, poly);
    
    uint32_t crc    = seed;  
    uint8_t *pBytes = (uint8_t *)[self bytes];
    uint32_t length = (uint32_t)[self length];
    
    while (length--)
    {
        crc = (crc>>8) ^ pTable[(crc & 0xFF) ^ *pBytes++];
    }
    
    free(pTable);
    return crc ^ 0xFFFFFFFFL;
}

-(uint32_t)crc32
{
    return [self crc32WithSeed:DEFAULT_SEED usingPolynomial:DEFAULT_POLYNOMIAL];
}

+(NSData *)base64Decoded:(NSString *)string
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63, 
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99, 
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99, 
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);  
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);  
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    outputData.length = outputLength;
    return outputLength? outputData: nil;
}

- (NSString *)base64Encoded
{
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    long long inputLength = [self length];
    const unsigned char *inputBytes = [self bytes];
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    unsigned char *outputBytes = (unsigned char *)malloc(maxOutputLength);
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
    }
    if (i == inputLength - 2)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    outputBytes = realloc(outputBytes, outputLength);
    NSString *result = [[NSString alloc] initWithBytesNoCopy:outputBytes length:outputLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
#if !__has_feature(objc_arc)
    [result autorelease];
#endif
    return (outputLength >= 4)? result: nil;
}

@end
