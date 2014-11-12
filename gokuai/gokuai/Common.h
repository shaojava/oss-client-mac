#ifndef gokuai_Common_h
#define gokuai_Common_h

#define MY_NO_ERROR                 0

enum
{
	WEB_JSONERROR		=0x1,
	WEB_FILEOPENERROR	=0x2,
	WEB_ENCRYPTERROR	=0x3,
	WEB_DECRYPTERROR	=0x4,
	WEB_UNSELECTFILE	=0x5,
	WEB_ACCESSKEYERROR	=0x6,
	WEB_FILEERROR		=0x7,
	WEB_PASSWORDERROR	=0x8,
    WEB_PASSWORDENCRYPTERROR=0x9
};

#define MY_ERROR_EXIST				10000
#define MY_ERROR_UNLINK				10001
#define MY_ERROR_ROMOVESUB			10004
#define MY_ERROR_SYNC_NOT_EXIST     10005
#define MY_ERROR_LINK_MOVE          10006
#define MY_ERROR_JSON               10007
#define MY_ERROR_SERVER_NOT_EXIST   10008
#define MY_ERROR_EMOJI_NOT_SUPPORT  10009

#define ULONGLONG       unsigned long long

#define KeyCallWebScriptMethodNotification                      @"CallWebScriptMethodNotification"
#define KeyDidLoginNotification                                 @"DidLoginedNotification"

#endif
