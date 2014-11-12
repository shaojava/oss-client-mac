#import <Foundation/Foundation.h>
#import "Common.h"

#define UPLOADPARTSIZE      54
#define MAXFILESIZEUPLOAD   10485760

enum{
    TRANSTASK_NULL  =0x0,
    TRANSTASK_START =0x1,
    TRANSTASK_NORMAL=0x2,
    TRANSTASK_STOP  =0x3,
    TRANSTASK_FINISH=0x4,
    TRANSTASK_ERROR =0x5,
    TRANSTASK_REMOVE=0x100
};

enum
{
	TRANSERROR_FILEUNSAME           =0x1,  //文件不一致
	TRANSERROR_WRITETIMEOUT         =0x4,//请求超时
	TRANSERROR_OPENFILE             =0x5,    //打开文件失败
	TRANSERROR_FILEHASH             =0xd,
	TRANSERROR_CREATEDIF            =0xf,
	TRANSERROR_OPENDIF              =0x10,
	TRANSERROR_UNLINK               =0x13,
	TRANSERROR_CREATEMULTIPARTERROR =0x14,
	TRANSERROR_OSSERROR             =0x15,
	TRANSERROR_MD5ERROR             =0x16,
	TRANSERROR_EXIST                =-1
};

@interface TransTaskItem : NSObject
{
    NSString* strPathhash;
    NSString* strHost;
    NSString* strBucket;
    NSString* strObject;
    NSString* strFullpath;
    ULONGLONG ullFilesize;
    ULONGLONG ullOffset;
    NSInteger nStatus;
    NSString* strUploadId;
    NSInteger nErrorNum;
    NSString* strMsg;
    ULONGLONG ullSpeed;
}

@property(nonatomic,retain)NSString* strPathhash;
@property(nonatomic,retain)NSString* strHost;
@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strObject;
@property(nonatomic,retain)NSString* strFullpath;
@property(nonatomic)ULONGLONG ullFilesize;
@property(nonatomic)ULONGLONG ullOffset;
@property(nonatomic)NSInteger nStatus;
@property(nonatomic,retain)NSString* strUploadId;
@property(nonatomic)NSInteger nErrorNum;
@property(nonatomic,retain)NSString* strMsg;
@property(nonatomic)ULONGLONG ullSpeed;

@end

@interface SaveFileItem : NSObject
{
    NSString* strHost;
    NSString* strBucket;
    NSString* strObject;
    NSString* strFullpath;
    NSString* strEtag;
    ULONGLONG ullFilesize;
    BOOL      bDir;
}

@property(nonatomic,retain)NSString* strHost;
@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strObject;
@property(nonatomic,retain)NSString* strFullpath;
@property(nonatomic,retain)NSString* strEtag;
@property(nonatomic)ULONGLONG ullFilesize;
@property(nonatomic)BOOL bDir;

@end

@interface CopyFileItem : NSObject
{
    NSString* strHost;
    NSString* strBucket;
    NSString* strObject;
    ULONGLONG ullFilesize;
    NSString* strDstHost;
    NSString* strDstBucket;
    NSString* strDstObject;
}

@property(nonatomic,retain)NSString* strHost;
@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strObject;
@property(nonatomic)ULONGLONG ullFilesize;
@property(nonatomic,retain)NSString* strDstHost;
@property(nonatomic,retain)NSString* strDstBucket;
@property(nonatomic,retain)NSString* strDstObject;

@end

@interface DeleteFileItem : NSObject
{
    NSString* strHost;
    NSString* strBucket;
    NSString* strObject;}

@property(nonatomic,retain)NSString* strHost;
@property(nonatomic,retain)NSString* strBucket;
@property(nonatomic,retain)NSString* strObject;

@end



