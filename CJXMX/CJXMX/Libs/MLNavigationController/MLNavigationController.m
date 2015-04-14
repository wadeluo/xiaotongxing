//
//  MLNavigationController.m
//  MLNavigation
//
//  Created by Molon on 13-9-25.
//  Copyright (c) 2013年 Molon. All rights reserved.
//

#import "MLNavigationController.h"
#import <QuartzCore/QuartzCore.h>

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define ANIMATE_DURATION 0.35 //PS:低于0.35的话 正常点击返回时候标题栏会有动画错位。

@interface MLNavigationController ()
{
    //以下四个是在拖曳时候用到的，所以直接操作会更快，放在这里
    CGPoint startTouch; //开始触摸的位置
    BOOL isMoving; //标识当前页面是否正在处于拖拽过程中
    UIImageView *lastScreenShotView; //上个页面的截图View
    UIView *blackMask; //黑色MaskView
}

//背景View，里面包含黑色MaskView和上一个页面的截图
@property (nonatomic,strong) UIView *backgroundView;
//页面截图记录数组，先进后出。
@property (nonatomic,strong) NSMutableArray *screenShotsList;

@end

@implementation MLNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //初始化非View成员
        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
        self.canDragBack = YES;
        isMoving = NO;
    }
    return self;
}

- (void)dealloc
{
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    self.screenShotsList = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //给当前的view添加一个左侧阴影条
    UIImageView *shadowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    
    //设置对拖动操作的监视
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(paningGestureReceive:)];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Utility Methods -

//截图
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

//设置上个页面截图的透明度和位置
- (void)moveViewWithX:(float)x
{
    x = x>self.view.frame.size.width?self.view.frame.size.width:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    
    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    blackMask.alpha = alpha;
}

- (void)resetBackgroundView
{
    if (!self.view.superview) {
        return; //还没有父View的时候不需要处理背景View
    }
    //将背景View和其中的黑色Mask初始化完毕
    if (!self.backgroundView) {
        CGRect frame = self.view.frame;
        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
        [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
        blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
        blackMask.backgroundColor = [UIColor blackColor];
        [self.backgroundView addSubview:blackMask];
    }
    
    self.backgroundView.hidden = YES;
    
    //设置上一页作为背景
    if ([lastScreenShotView.image isEqual:[self.screenShotsList lastObject]]) {
        return;//如果上页背景图没有改变即不重新设置
    }
	if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
	UIImage *lastScreenShot = [self.screenShotsList lastObject];
	lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
	[self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
}

#pragma mark - Override Push and Pop -

// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //当前页面截图并且记录
    [self.screenShotsList addObject:[self capture]];
	
    //无动画推入下一个页面
	[super pushViewController:viewController animated:NO];
	
    //本身就不要求动画的直接return
	if (!animated) {
		return;
	}
	
	//设置上一页作为背景
	[self resetBackgroundView];
	
    //执行新页面推入动画，
    self.backgroundView.hidden = NO;
	[self moveViewWithX:self.view.frame.size.width]; //重置到屏幕右侧
	[UIView animateWithDuration:ANIMATE_DURATION animations:^{
		[self moveViewWithX:0];
	} completion:^(BOOL finished) {
		self.backgroundView.hidden = YES; //隐藏背景View即可
	}];
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	//如果不需要动画的就直接pop
	if (!animated) {
		[self.screenShotsList removeLastObject];
		return [super popViewControllerAnimated:animated];
	}
	
	//重置上页背景
	[self resetBackgroundView];
	
    //刚好和push是反过来的
	self.backgroundView.hidden = NO;
	[self moveViewWithX:0];
	[UIView animateWithDuration:ANIMATE_DURATION animations:^{
		[self moveViewWithX:self.view.frame.size.width];
	} completion:^(BOOL finished) {
		[self.screenShotsList removeLastObject];
		[super popViewControllerAnimated:NO];
		CGRect frame = self.view.frame;
		frame.origin.x = 0;
		self.view.frame = frame;
		self.backgroundView.hidden = YES; //隐藏背景View即可
	}];
	return NULL; //TODO:这里就不能获取到返回值了,TODO,TODO
}



#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    //如果只有一个页面，或者当前不让拖拽返回，就直接return
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    //开始拖拽，显示背景view，若没初始化即初始化
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        isMoving = YES;
        startTouch = touchPoint; //记录开始触摸点
        
        //重置背景View和内容
        [self resetBackgroundView];
        //显示背景View
        self.backgroundView.hidden = NO;
        
        //结束拖曳，根据拖曳的距离来判断该自动返回还是恢复。
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        if (touchPoint.x - startTouch.x > 50) //超过50位置即自动返回，否则恢复
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:self.view.frame.size.width];
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                self.backgroundView.hidden = YES;
                isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
        //取消拖曳，即恢复
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    //正在拖曳，即调整背景图和当前View位置
    if (isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

@end
