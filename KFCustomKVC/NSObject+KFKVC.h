//
//  NSObject+KFKVC.h
//  KFCustomKVC
//
//  Created by 冯哲 on 2021/7/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KFKVC)

- (void)kf_setValue:(id)value forKey:(NSString *)key;
- (nullable id)kf_valueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
