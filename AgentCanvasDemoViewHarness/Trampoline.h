#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Calls `fn` with x0 = arg0 and x20 = meta (Swift's generic-metadata register),
/// returning x0. Used to call `UIHostingController.init(rootView:)`, whose Content
/// metadata travels in x20.
void * _Nullable DLCallRet1_X20(void * _Nonnull arg0, void * _Nonnull meta, void * _Nonnull fn);

NS_ASSUME_NONNULL_END
