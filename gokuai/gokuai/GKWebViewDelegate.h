
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////

@class BrowserWebWindowController;

////////////////////////////////////////////////////////////////////////////////////////////////

@interface GKWebViewDelegate : NSObject {
    
    id delegateController;
    BOOL    _bWindowsCloes;
}

////////////////////////////////////////////////////////////////////////////////////////////////

@property(nonatomic,assign)id delegateController;
@property(nonatomic)BOOL _bWindowsCloes;

////////////////////////////////////////////////////////////////////////////////////////////////

-(id)initWithDelegateController:(id)controller;


////////////////////////////////////////////////////////////////////////////////////////////////
@end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

#define DEF_CACHE_TOTAL_QUOTA   (1024*1024*5)
#define DEF_CACHE_ORIGIN_QUOTA  (1024*1024*5)

@interface WebPreferences (WebPreferencesPrivate)
- (void)_setLocalStorageDatabasePath:(NSString *)path;
- (void) setLocalStorageEnabled: (BOOL) localStorageEnabled;
- (void) setDatabasesEnabled:(BOOL)databasesEnabled;
- (void) setDeveloperExtrasEnabled:(BOOL)developerExtrasEnabled;
- (void) setWebGLEnabled:(BOOL)webGLEnabled;
- (void) setOfflineWebApplicationCacheEnabled:(BOOL)offlineWebApplicationCacheEnabled;

- (int64_t)applicationCacheTotalQuota;
- (void)setApplicationCacheTotalQuota:(int64_t)quota;
- (int64_t)applicationCacheDefaultOriginQuota;
- (void)setApplicationCacheDefaultOriginQuota:(int64_t)quota;

-(BOOL)GetRootMountListSub:(NSInteger)sub
                    parent:(NSInteger)parent
                    mounts:(NSMutableArray**)mounts;

@end