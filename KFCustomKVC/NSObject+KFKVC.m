//
//  NSObject+KFKVC.m
//  KFCustomKVC
//
//  Created by 冯哲 on 2021/7/4.
//

#import "NSObject+KFKVC.h"
#import <objc/runtime.h>

@implementation NSObject (KFKVC)

- (void)kf_setValue:(id)value forKey:(NSString *)key {
    
    // 1、 判空处理
    if (!key || key.length == 0) {
        return;
    }
    
    // 2、找到相关方法 set<Key> _set<Key> setIs<Key>
    NSString *Key = key.capitalizedString;
    NSString *setKey = [NSString stringWithFormat:@"set%@:",Key];
    NSString *_setKey = [NSString stringWithFormat:@"_set%@:",Key];
    NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:",Key];
    
    if ([self kf_performSelectorWithMethodName:setKey value:value]) {
        NSLog(@"**********************");
        NSLog(@"%@",setKey);
        NSLog(@"**********************");
        return;
    }else if ([self kf_performSelectorWithMethodName:_setKey value:value]) {
        NSLog(@"**********************");
        NSLog(@"%@",_setKey);
        NSLog(@"**********************");
        return;
    }else if ([self kf_performSelectorWithMethodName:setIsKey value:value]) {
        NSLog(@"**********************");
        NSLog(@"%@",setIsKey);
        NSLog(@"**********************");
        return;
    }
    // 3、判断是否能够直接赋值实例变量
    if (![self.class accessInstanceVariablesDirectly]) {
        @throw [NSException exceptionWithName:@"KFUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name %@.***",self,key] userInfo:nil];
    }
    // 4、找相关的实例变量进行赋值 _<key> _is<Key> <key> is<Key>
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    // 4.1 获取变量
    NSMutableArray *ivarNamesArray = [self getIvarListName];
    if ([ivarNamesArray containsObject:_key]) {
        // 4.2 获取相应的 ivar
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        // 4.3 对相应的 ivar 设值
        object_setIvar(self, ivar, value);
        NSLog(@"**********************");
        NSLog(@"%@",_key);
        NSLog(@"**********************");
        return;
    }else if ([ivarNamesArray containsObject:_isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        object_setIvar(self, ivar, value);
        NSLog(@"**********************");
        NSLog(@"%@",_isKey);
        NSLog(@"**********************");
        return;
    }else if ([ivarNamesArray containsObject:key]) {
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        object_setIvar(self, ivar, value);
        NSLog(@"**********************");
        NSLog(@"%@",key);
        NSLog(@"**********************");
        return;
    }else if ([ivarNamesArray containsObject:isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        object_setIvar(self, ivar, value);
        NSLog(@"**********************");
        NSLog(@"%@",isKey);
        NSLog(@"**********************");
        return;
    }
    // 5、找不到相关的实例变量， setValue: forUndefinedKey 抛出异常
    @throw [NSException exceptionWithName:@"KFUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ %@]: this class is not key value coding-compliant for the key name %@.****",self,NSStringFromSelector(_cmd),key] userInfo:nil];
}

- (nullable id)kf_valueForKey:(NSString *)key {
    // 1、判空处理
    if (!key || key.length == 0) {
        return nil;
    }
    
    // 2、 找到相关方法 get<Key> <key> is<Key> _<key>
    NSString *Key = key.capitalizedString;
    NSString *getKey = [NSString stringWithFormat:@"get%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:NSSelectorFromString(getKey)]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",getKey);
        NSLog(@"**********************");
        return [self performSelector:NSSelectorFromString(getKey)];
    }else if ([self respondsToSelector:NSSelectorFromString(key)]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",key);
        NSLog(@"**********************");
        return [self performSelector:NSSelectorFromString(key)];
    }else if ([self respondsToSelector:NSSelectorFromString(isKey)]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",isKey);
        NSLog(@"**********************");
        return [self performSelector:NSSelectorFromString(isKey)];
    }else if ([self respondsToSelector:NSSelectorFromString(_key)]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",_key);
        NSLog(@"**********************");
        return [self performSelector:NSSelectorFromString(_key)];
    }
#pragma clang diagnostic pop
    
    // 3、 查找 countOf<Key> objectIn<Key>AtIndex: 方法
    NSString *countOfKey = [NSString stringWithFormat:@"countOf%@",Key];
    NSString *objectInKeyAtIndex = [NSString stringWithFormat:@"objectIn%@AtIndex",Key];
    
    if ([self respondsToSelector:NSSelectorFromString(countOfKey)]) {
        if ([self respondsToSelector:NSSelectorFromString(objectInKeyAtIndex)]) {
            
        }
    }
    // 4、 继续查找 countOf<Key> enumeratorOf<Key> 和 memberOf<Key>
//    NSString *enumeratorOfKey = [NSString stringWithFormat:@"enumeratorOf%@",Key];
//    NSString *memberOfKey = [NSString stringWithFormat:@"memberOf%@",Key];
    // 5、 判断是否可以读取 实例变量
    if (![self.class accessInstanceVariablesDirectly]) {
        @throw [NSException exceptionWithName:@"KFUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name %@.****",self,key] userInfo:nil];
    }
    // 6、 读取实例变量的值 _<key> _is<Key> <key> is<Key>
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSMutableArray *ivarListArray = [self getIvarListName];
    if ([ivarListArray containsObject:_key]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",_key);
        NSLog(@"**********************");
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        return object_getIvar(self, ivar);
    }else if ([ivarListArray containsObject:_isKey]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",_isKey);
        NSLog(@"**********************");
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        return object_getIvar(self, ivar);
    }else if ([ivarListArray containsObject:key]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",key);
        NSLog(@"**********************");
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        return object_getIvar(self, ivar);
    }else if ([ivarListArray containsObject:isKey]) {
        NSLog(@"**********************");
        NSLog(@"kf_valueForKey:%@",isKey);
        NSLog(@"**********************");
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        return object_getIvar(self, ivar);
    }
    // 7、 找不到相关实例变量，valueForUndefinedKey 抛出异常
    @throw [NSException exceptionWithName:@"KFUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name %@.****",self,key] userInfo:nil];
}

#pragma mark - Private Methods
- (BOOL)kf_performSelectorWithMethodName:(NSString *)methodName value:(id)value {
    if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(methodName) withObject:value];
#pragma clang diagnostic pop
        return YES;
    }
    return NO;
}

- (id)kf_performSelectorWithMethodName:(NSString *)methodName {
    if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:NSSelectorFromString(methodName)];
#pragma clang diagnostic pop
    }
    return nil;
}


- (NSMutableArray *)getIvarListName {
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        const char *ivarNameChar = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:ivarNameChar];
        [mArray addObject:ivarName];
    }
    free(ivars);
    return mArray;
}


@end
