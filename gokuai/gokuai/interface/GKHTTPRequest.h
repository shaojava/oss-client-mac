//
//  GKHTTPRequest.h
//

#import <Foundation/Foundation.h>
/** @file GKHTTPRequest.h
 * @brief 网络请求操作
 */

@interface GKHTTPRequest : NSOperation
{
    NSString* method;
    NSDictionary* header;
    NSData*  body;
    NSString* url;
    NSString *parentPath;
    NSInteger mountId;
    NSInteger statusCode;
    NSMutableData *jsonData;
    BOOL _isRunning;
    
}
@property(nonatomic, copy) NSString* method;
@property(nonatomic, copy) NSString* url;
@property(nonatomic, retain) NSDictionary* header;
@property(nonatomic, retain) NSData* body;
@property(nonatomic, copy) NSString *parentPath;
@property(nonatomic) NSInteger mountId;
@property(nonatomic, retain) NSMutableData *jsonData;

- (id)initWithUrl:(NSString *)urlstr 
           method:(NSString *)methodstr 
           header:(NSDictionary *)headerDic  
         bodyData:(NSData *)bodyData;



-(NSData*)connectNetSyncWithResponse:(NSURLResponse**)response error:(NSError**)error;

@end
