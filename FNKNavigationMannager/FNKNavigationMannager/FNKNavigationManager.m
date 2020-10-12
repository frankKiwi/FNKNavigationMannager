//
//  FNKNavigationManager.m
//  FNKNavigationMannager
//
//  Created by LWW on 2020/10/12.
//  Copyright © 2020 LWW. All rights reserved.
//

#import "FNKNavigationManager.h"
#import <objc/runtime.h>

@implementation FNKNavigationManager
+(UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication].delegate window] ;
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (UIViewController *)FNK_findVisibleViewController {
    
    UIViewController* currentViewController = [self FNK_getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                currentViewController = [self getCurrentVC];
                break;
            }
        }
    }
    if (currentViewController == nil) {
        currentViewController = [self getCurrentVC];
    }
    
    return currentViewController;
}
+ (UIViewController *)FNK_getRootViewController{

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}
/***  删除多余栈内的指定类 */

+ (void)removeMutilViewControllerWithSourceVcName:(NSString *)className{
      UIViewController *currentVC = [self FNK_findVisibleViewController];
      if (currentVC.presentingViewController&&[currentVC isKindOfClass:NSClassFromString(className)]){
         [currentVC dismissViewControllerAnimated:YES completion:nil];
        return;
      }
      NSMutableArray *dataArr = [NSMutableArray arrayWithArray:currentVC.navigationController.viewControllers];
       [dataArr enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(className)]) {
                [dataArr removeObjectAtIndex:idx];
            }
       }];
       currentVC.navigationController.viewControllers = dataArr;
}
/***  根据索引跳转到指定一个类 */

+ (void)popToSpecailVcWithIndex:(NSInteger)index withParams:(NSDictionary *)data{
    UIViewController *currentVC = [self FNK_findVisibleViewController];
    NSMutableArray *dataArr = [NSMutableArray arrayWithArray:currentVC.navigationController.viewControllers];
    UIViewController *targetVC = dataArr[index];
    if (data.count > 0) {
        [self setValueToVC:targetVC withData:data];
    }
    [currentVC.navigationController popToViewController:targetVC animated:YES];

}

/***  删除栈内最后的一个类 */

+ (void)removeLastViewController{
      UIViewController *currentVC = [self FNK_findVisibleViewController];
      
      NSMutableArray *dataArr = [NSMutableArray arrayWithArray:currentVC.navigationController.viewControllers];
    [dataArr removeObjectAtIndex:dataArr.count-1];
    [currentVC.navigationController setViewControllers:dataArr animated:YES];

}
/***  跳转到指定栈内的类 */

+(void)popToSpecailVcWithName:(NSString *)vcName withParams:(NSDictionary*)data{
    __block UIViewController*targetVC = nil;
    UIViewController *currentVC = [self FNK_findVisibleViewController];
    NSMutableArray *dataArr = [NSMutableArray arrayWithArray:currentVC.navigationController.viewControllers];
    [dataArr enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if ([obj isKindOfClass:NSClassFromString(vcName)]) {
             targetVC = obj;
             if (data.count >0) {
                 [self setValueToVC:targetVC withData:data];
             }
             *stop = YES;
         }
    }];
    [currentVC.navigationController popToViewController:targetVC animated:YES];
}
/***  跳转类限定多少个,太多影响用户体验,也可能影响APP的性能,栈后处理 */

+ (NSInteger)pushLimitVCAfterWithCount:(NSInteger)limit andVCName:(NSString *)className{
    NSUInteger limitNum = limit;
    if (limitNum <= 0) {
        return 0;
    }
    UIViewController *currentVC = [self FNK_findVisibleViewController];
    NSArray *vcs = currentVC.navigationController.viewControllers;
    NSMutableArray *targetDetailVCIndexArrM = [NSMutableArray array];
    for (NSInteger i = vcs.count - 1; i >= 0; i--) {
        if (![vcs[i] isKindOfClass:[NSClassFromString(className) class]]) {
            break;
        }
        [targetDetailVCIndexArrM addObject:@(i)];
    }
    
    if (targetDetailVCIndexArrM.count > limitNum) {
        NSMutableArray *vcsArrM = [vcs mutableCopy];
        [vcsArrM removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(limitNum, targetDetailVCIndexArrM.count-limitNum)]];
        [currentVC.navigationController setViewControllers:vcsArrM animated:YES];
    }
    return targetDetailVCIndexArrM.count;
}

/***  跳转类限定多少个,太多影响用户体验,也可能影响APP的性能,栈前处理 */

+ (NSInteger)pushLimitVCBeforeWithCount:(NSInteger)limit andVCName:(NSString *)className{
    NSUInteger limitNum = limit;
    if (limitNum <= 0) {
        return 0;
    }
    UIViewController *currentVC = [self FNK_findVisibleViewController];
    NSArray *vcs = currentVC.navigationController.viewControllers;
    NSMutableArray *targetDetailVCIndexArrM = [NSMutableArray array];
    for (NSInteger i = vcs.count - 1; i >= 0; i--) {
        if (![vcs[i] isKindOfClass:[NSClassFromString(className) class]]) {
            break;
        }
        [targetDetailVCIndexArrM addObject:@(i)];
    }
    
    if (targetDetailVCIndexArrM.count > limitNum) {
        NSMutableArray *vcsArrM = [vcs mutableCopy];
        [vcsArrM removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, targetDetailVCIndexArrM.count-limitNum)]];
        [currentVC.navigationController setViewControllers:vcsArrM animated:YES];
    }
    return targetDetailVCIndexArrM.count;
}

/***  为目标类赋值 */

+ (UIViewController*)setValueToVC:(UIViewController *)vc withData:(NSDictionary*)data{
    unsigned int count = 0;
       Ivar *members = class_copyIvarList([vc class], &count);
       for (int i = 0; i < count; i++) {
           Ivar ivar = members[i];
           const char *memberName = ivar_getName(ivar);
           NSString *strName = [NSString  stringWithCString:memberName encoding:NSUTF8StringEncoding];
           NSString*property= [strName substringWithRange:NSMakeRange(1, strName.length-1)];
           if ([data.allKeys containsObject:property]) {
              [vc setValue:data[property] forKey:property];
           }
       }
    return vc;
}


@end
