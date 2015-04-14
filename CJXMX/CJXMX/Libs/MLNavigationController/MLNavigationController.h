//
//  MLNavigationController.h
//  MLNavigation
//
//  Created by Molon on 13-9-25.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLNavigationController : UINavigationController

//默认为YES，标识当前此NavigationController是否可以拖拽返回
//用于某些页面不适合被拖拽返回时候
@property (nonatomic,assign) BOOL canDragBack;

@end
