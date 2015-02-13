
#import "DataLocator.h"

@implementation DataLocator

@synthesize arrayData;

-(id)init
{
    if (self = [super init])
    {
        self.arrayData=[NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

-(void)dealloc
{
    self.arrayData=nil;
    [super dealloc];
}

-(void)LoadParisFromString:(NSString*)data{
    NSArray* array=[data componentsSeparatedByString:@","];
    for (NSString * item in array) {
        NSArray* arrayitem=[item componentsSeparatedByString:@"-"];
        if (![arrayitem isKindOfClass:[NSArray class]]||arrayitem.count<2) {
            continue;
        }
        ULONGLONG frist=[[arrayitem objectAtIndex:0] longLongValue];
        ULONGLONG last=[[arrayitem objectAtIndex:1] longLongValue];
        [self InsertPart:frist last:last];
    }
}

-(BOOL)InsertPart:(ULONGLONG)ullFirst last:(ULONGLONG)ullLast
{
    ULONGLONG ullTempFirst=ullFirst;
    ULONGLONG ullTempLast=ullLast;
    if (ullTempFirst>ullTempLast) {
        return NO;
    }
    NSMutableArray* arrayTemp=[NSMutableArray arrayWithCapacity:0];
    for (DataPair *item in arrayData) {
        if (ullTempFirst<item.ullFirstMark) {
            if (ullTempLast>item.ullFirstMark) {
                [arrayTemp addObject:item];
                if (ullTempLast<item.ullLastMark) {
                    ullTempLast=item.ullLastMark;
                }
            }
            else if (ullTempLast+1==item.ullFirstMark) {
                [arrayTemp addObject:item];
                if (ullTempLast<item.ullLastMark) {
                    ullTempLast=item.ullLastMark;
                }
            }
            else {
            }
        }
        else {
            if (ullTempFirst>item.ullLastMark&&ullTempFirst!=item.ullLastMark+1) {
                continue;
            }
            ullTempFirst=item.ullFirstMark;
            if (ullTempLast<item.ullLastMark) {
                return YES;
            }
            else {
                [arrayTemp addObject:item];
            }
        }
    }
    for (DataPair * removeitem in arrayTemp) {
        for (int i=0;i<arrayData.count;) {
            DataPair* item=[arrayData objectAtIndex:i];
            if (item.ullFirstMark==removeitem.ullFirstMark&&item.ullLastMark==removeitem.ullLastMark) {
                [arrayData removeObjectAtIndex:i];
            }
            else {
                i++;
            }
        }
    }
    DataPair *newitem=[[[DataPair alloc]init:ullTempFirst last:ullTempLast]autorelease];
    [arrayData addObject:newitem];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ullFirstMark" ascending:YES];
    [arrayData sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return YES;
}

-(BOOL)InsertParts:(NSArray*)array
{
    for (DataPair* item in array) {
        [self InsertPart:item.ullFirstMark last:item.ullLastMark];
    }
    return YES;
}

-(ULONGLONG)Size
{
    ULONGLONG count=0;
    for (DataPair * item in arrayData) {
        count+=item.ullLastMark-item.ullFirstMark+1;
    }
    return count;
}

-(NSString*)OutPut
{
    NSMutableString *ret=[NSMutableString stringWithCapacity:1000];
    int num=0;
    for (DataPair * item in arrayData) {
        if (num!=0) {
            [ret appendFormat:@","];
        }
        [ret appendFormat:@"%llu-%llu",item.ullFirstMark,item.ullLastMark];
        num++;
    }
    return ret;
}

-(DataPair*)FindSmallPair
{
    if ([self.arrayData count]==0) {
        return [[[DataPair alloc]init:ZeroPos last:ZeroPos]autorelease];
    }
    NSInteger index=0;
    ULONGLONG num=ZeroPos;
    for (int i=0;i<self.arrayData.count;i++) {
        DataPair * item=[self.arrayData objectAtIndex:i];
        ULONGLONG temp=item.ullLastMark-item.ullFirstMark+1;
        if(temp<num)
        {
            index=0;
            num=temp;
        }
    }
    return [self.arrayData objectAtIndex:index];
}

-(NSMutableArray*)GetInPairs:(ULONGLONG)ullFirst last:(ULONGLONG)ullLast
{
    NSMutableArray* ret=[NSMutableArray arrayWithCapacity:0];
    for (DataPair *item in self.arrayData) {
        if (ullLast<item.ullFirstMark) {
            continue;
        }
        else if (ullLast>item.ullLastMark) {
            if (ullFirst<item.ullLastMark) {
                DataPair *newitem=[[[DataPair alloc]init:item.ullFirstMark last:item.ullLastMark]autorelease];
                [ret addObject:newitem];
            }
            else if (ullFirst>=item.ullFirstMark&&ullFirst<=item.ullLastMark) {
                DataPair *newitem=[[[DataPair alloc]init:ullFirst last:item.ullLastMark]autorelease];
                [ret addObject:newitem];
            }
            else {
                continue;
            }
        }
        else {
            if (ullFirst<item.ullFirstMark) {
                DataPair *newitem=[[[DataPair alloc]init:item.ullFirstMark last:ullLast]autorelease];
                [ret addObject:newitem];
            }
            else {
                DataPair *newitem=[[[DataPair alloc]init:ullFirst last:ullLast]autorelease];
                [ret addObject:newitem];
                break;
            }
        }
    }
    return ret;
}

-(void)Clear
{
    [arrayData removeAllObjects];
}

-(void)RemoveDataLocatiors:(DataLocator*)datas
{
    [self RemoveDataPairs:datas.arrayData];
}

-(void)RemoveDataPairs:(NSArray*)datas
{
    for (DataPair *item in datas) {
        [self RemovePair:item];
    }
}

-(void)RemovePair:(DataPair*)data
{
    [self RemovePairs:data.ullFirstMark last:data.ullLastMark];
}

-(void)RemovePairs:(ULONGLONG)ullFirst last:(ULONGLONG)ullLast
{
    if (ullFirst>ullLast) {
        return;
    }
    ULONGLONG ullTempFirst=ullFirst;
    ULONGLONG ullTempLast=ullLast;
    NSMutableArray* arraydelete=[NSMutableArray arrayWithCapacity:0];
    NSMutableArray* arrayadd=[NSMutableArray arrayWithCapacity:0];
    for (DataPair *item in arrayData) {
        if (ullTempFirst<item.ullFirstMark) {
            if (ullTempLast<item.ullFirstMark) {
                break;
            }
            if (ullTempLast>=item.ullFirstMark&&ullTempLast<=item.ullLastMark) {
                [arraydelete addObject:item];
                if (ullTempLast<item.ullLastMark) {
                    DataPair *newitem=[[[DataPair alloc]init:ullTempLast+1 last:item.ullLastMark]autorelease];
                    [arrayadd addObject:newitem];
                }
                break;
            }
            if (ullTempLast>item.ullLastMark) {
                [arraydelete addObject:item];
                ullTempFirst=item.ullLastMark+1;
                continue;
            }
        }
        else if (ullTempFirst==item.ullFirstMark) {
            [arraydelete addObject:item];
            if (ullTempLast==item.ullLastMark) {
                break;
            }
            if (ullTempLast<item.ullLastMark) {
                DataPair *newitem=[[[DataPair alloc]init:ullTempLast+1 last:item.ullLastMark]autorelease];
                [arrayadd addObject:newitem];
                break;
            }
            if (ullTempLast>item.ullLastMark) {
                ullTempFirst=item.ullLastMark+1;
                continue;
            }
        }
        else if (ullTempFirst>item.ullFirstMark&&ullTempFirst<item.ullLastMark) {
            [arraydelete addObject:item];
            if (ullTempLast==item.ullLastMark) {
                DataPair *newitem=[[[DataPair alloc]init:item.ullFirstMark last:ullTempFirst-1]autorelease];
                [arrayadd addObject:newitem];
                break;
            }
            if (ullTempLast<=item.ullLastMark) {
                DataPair *newitem=[[[DataPair alloc]init:item.ullFirstMark last:ullTempFirst-1]autorelease];
                [arrayadd addObject:newitem];
                
                DataPair *newitem1=[[[DataPair alloc]init:ullTempLast+1 last:item.ullLastMark]autorelease];
                [arrayadd addObject:newitem1];
                break;
            }
            if (ullTempLast>item.ullLastMark) {
                DataPair *newitem=[[[DataPair alloc]init:item.ullFirstMark last:ullTempFirst-1]autorelease];
                [arrayadd addObject:newitem];
                ullTempFirst=item.ullLastMark+1;
                continue;
            }
        }
        else {
            continue;
        }
    }
    for (DataPair * removeitem in arraydelete) {
        for (int i=0;i<arrayData.count;) {
            DataPair* item=[arrayData objectAtIndex:i];
            if (item.ullFirstMark==removeitem.ullFirstMark&&item.ullLastMark==removeitem.ullLastMark) {
                [arrayData removeObjectAtIndex:i];
            }
            else {
                i++;
            }
        }
    }
    for (DataPair * additem in arrayadd) {
        [arrayData addObject:additem];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ullFirstMark" ascending:YES];
    [arrayData sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
