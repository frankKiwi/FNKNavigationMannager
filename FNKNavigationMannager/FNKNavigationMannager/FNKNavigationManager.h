//
//  FNKNavigationManager.h
//  FNKNavigationMannager
//
//  Created by LWW on 2020/10/12.
//  Copyright © 2020 LWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FNKNavigationManager : NSObject
/***  获取根控制器 */
+ (UIViewController *)FNK_findVisibleViewController;

/***  删除多余栈内的指定类 */

+ (void)removeMutilViewControllerWithSourceVcName:(NSString *)className;

/***  跳转到指定栈内的类 */

+(void)popToSpecailVcWithName:(NSString *)vcName withParams:(NSDictionary*)data;

/***  跳转类限定多少个,太多影响用户体验,也可能影响APP的性能 */

+ (NSInteger)pushLimitVCAfterWithCount:(NSInteger)limit andVCName:(NSString *)className;

/***  跳转类限定多少个,太多影响用户体验,也可能影响APP的性能,栈前处理 */

+ (NSInteger)pushLimitVCBeforeWithCount:(NSInteger)limit andVCName:(NSString *)className;

/***  删除栈内最后的一个类 */

+ (void)removeLastViewController;

/***  根据索引跳转到指定一个类 */

+ (void)popToSpecailVcWithIndex:(NSInteger)index withParams:(NSDictionary *)data;

/***  登录之后直接跳转到指定的类 */

@end

NS_ASSUME_NONNULL_END
