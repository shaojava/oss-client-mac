#import <Foundation/Foundation.h>
#import "DataPair.h"

@interface DataLocator : NSObject
{
    NSMutableArray* arrayData;
}

@property(nonatomic,retain)NSMutableArray* arrayData;

-(void)LoadParisFromString:(NSString*)data;
-(BOOL)InsertPart:(ULONGLONG)ullFirst last:(ULONGLONG)ullLast;
-(BOOL)InsertParts:(NSArray*)array;
-(ULONGLONG)Size;
-(NSString*)OutPut;
-(DataPair*)FindSmallPair;
-(NSMutableArray*)GetInPairs:(ULONGLONG)ullFirst last:(ULONGLONG)ullLast;
-(void)Clear;
-(void)RemoveDataLocatiors:(DataLocator*)datas;
-(void)RemoveDataPairs:(NSArray*)datas;
-(void)RemovePair:(DataPair*)data;
-(void)RemovePairs:(ULONGLONG)ullFirst last:(ULONGLONG)ullLast;

@end
