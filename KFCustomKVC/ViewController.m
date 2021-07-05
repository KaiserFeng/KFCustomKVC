//
//  ViewController.m
//  KFCustomKVC
//
//  Created by 冯哲 on 2021/7/4.
//

#import "ViewController.h"
#import "KFPerson.h"
#import "NSObject+KFKVC.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KFPerson *person = [[KFPerson alloc] init];
    [person kf_setValue:@"KF" forKey:@"name"];
    [self getMethodList];
    NSLog(@"--%@--",[person kf_valueForKey:@"name"]);
}

- (void)getMethodList {
    
    Class currentClass = [KFPerson class];
    while (currentClass) {
        unsigned int count = 0;
        Method *methodList = class_copyMethodList(currentClass, &count);
        for (int i = 0; i < count; i ++) {
            Method method = methodList[i];
            NSString *className = NSStringFromClass(currentClass);
            NSString *methodName = NSStringFromSelector(method_getName(method));
            NSLog(@"%@--%@",className,methodName);
        }
        free(methodList);
        currentClass = class_getSuperclass(currentClass);
    }
}


@end
