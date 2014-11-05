//
//  GKHTTPRequest.m
//

#import "GKHTTPRequest.h"
#import "Util.h"

@implementation GKHTTPRequest

@synthesize header;
@synthesize url;
@synthesize method;
@synthesize body;
@synthesize parentPath;
@synthesize mountId;
@synthesize jsonData;

- (id)initWithUrl:(NSString *)urlstr 
           method:(NSString *)methodstr 
           header:(NSDictionary *)headerDic  
         bodyData:(NSData *)bodyData{
    if (self = [super init]) {
        self.url = urlstr;
        self.method = methodstr;
        self.header = headerDic;
        self.body = bodyData;
        self.jsonData = [[[NSMutableData alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc 
{
    [method release];
    [header release];
    [body release];
    [url release];
    [jsonData release];
    if (parentPath!=nil)
        [parentPath release];
    [super dealloc];
}

-(void)connectNet
{
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%ld",[[self body] length]];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:[self method]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSDictionary* dictionaryHeader = [self header];
    if ([dictionaryHeader isKindOfClass:[NSDictionary class]])
    {
       NSArray* keyArray =  [dictionaryHeader allKeys];
        NSInteger count = [keyArray count];
        for(int i= 0; i < count;i++)
        {   
            NSString* keyIndex = [keyArray objectAtIndex:i];
            [request setValue:[dictionaryHeader objectForKey:keyIndex] forHTTPHeaderField:keyIndex];
        }
    }
    
    [request setHTTPBody:[self body]];
    [request setTimeoutInterval:60];
    NSURLConnection *conn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    if (conn!=nil) 
        [conn start];
}

-(NSData*)connectNetSyncWithResponse:(NSURLResponse**)response error:(NSError**)error
{
    NSMutableURLRequest *request=[[[NSMutableURLRequest alloc] init]autorelease];
    NSString *postLength = [NSString stringWithFormat:@"%ld",[[self body] length]];
    [request setURL:[NSURL URLWithString:[self url]]];
    [request setHTTPMethod:[self method]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSDictionary* dictionaryHeader = [self header];
    if ([dictionaryHeader isKindOfClass:[NSDictionary class]])
    {
       NSArray* keyArray =  [dictionaryHeader allKeys];
        NSInteger count = [keyArray count];
        for(int i= 0; i < count;i++)
        {   
            NSString* keyIndex = [keyArray objectAtIndex:i];
            [request setValue:[dictionaryHeader objectForKey:keyIndex] forHTTPHeaderField:keyIndex];
        }
    }
    
    [request setHTTPBody:[self body]];
    [request setTimeoutInterval:60];
    return [NSURLConnection sendSynchronousRequest:request returningResponse: response error:error] ;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
    statusCode = [res statusCode];
    [jsonData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [jsonData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _isRunning = NO;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    statusCode=[error code];
    _isRunning = NO;
}

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    _isRunning =YES;
    [self connectNet];
    while (_isRunning)
    {
        [[NSRunLoop currentRunLoop] run];
    }
    [pool release];
}

@end
