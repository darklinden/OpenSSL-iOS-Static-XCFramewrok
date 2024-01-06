#import <Foundation/Foundation.h>

@interface AESUtil : NSObject

+ (nullable NSString*)encrypt:(nonnull NSString*)message withKey:(nonnull NSString*)strkey;
+ (nullable NSString*)decrypt:(nonnull NSString*)data withKey:(nonnull NSString*)strkey;

@end
