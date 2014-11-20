#ifndef gokuai_Common_h
#define gokuai_Common_h

enum
{
    WEB_SUCCESS         =0x0,
	WEB_JSONERROR		=0x1,
	WEB_FILEOPENERROR	=0x2,
	WEB_FILESAVEERROR	=0x3,
	WEB_ACCESSKEYERROR	=0x4,
	WEB_UNSELECTFILE	=0x5,//这个不能变动
	WEB_FILEERROR		=0x5,
	WEB_PASSWORDERROR	=0x6,
	WEB_ENCRYPTERROR	=0x7,
	WEB_DECRYPTERROR	=0x8,
	WEB_CURLERROR		=0x9,
	WEB_OSSERROR		=0xa
};

#define ULONGLONG       unsigned long long
#define KeyCallWebScriptMethodNotification  @"CallWebScriptMethodNotification"
#define KeyDidLoginNotification             @"DidLoginedNotification"

#endif
