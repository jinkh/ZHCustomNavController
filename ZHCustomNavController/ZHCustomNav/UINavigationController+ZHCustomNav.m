#import "UINavigationController+ZHCustomNav.h"
#import <objc/runtime.h>

@interface _ZHFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation _ZHFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Disable when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.zh_interactivePopDisabled) {
        return NO;
    }

    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        objc_setAssociatedObject(gestureRecognizer, @"popBack", [NSNumber numberWithBool:0], OBJC_ASSOCIATION_COPY_NONATOMIC);
        return YES;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (fabs(translation.y) < fabs(translation.x)) {
        objc_setAssociatedObject(gestureRecognizer, @"popBack", [NSNumber numberWithBool:1], OBJC_ASSOCIATION_COPY_NONATOMIC);
    } else {
        objc_setAssociatedObject(gestureRecognizer, @"popBack", [NSNumber numberWithBool:0], OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL popBack = [objc_getAssociatedObject(gestureRecognizer, @"popBack") boolValue];
    if (popBack) {
        return NO;
    }
    return YES;
}

@end

typedef void (^_ZHViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (ZHFullscreenPopGesturePrivate)

@property (nonatomic, copy) _ZHViewControllerWillAppearInjectBlock zh_willAppearInjectBlock;

@end

@implementation UIViewController (ZHFullscreenPopGesturePrivate)

+ (void)load
{
    Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(zh_viewWillAppear:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    Method originalMethod2 = class_getInstanceMethod(self, @selector(viewDidLoad));
    Method swizzledMethod2 = class_getInstanceMethod(self, @selector(zh_viewDidLoad));
    method_exchangeImplementations(originalMethod2, swizzledMethod2);
    
}

-(void)zh_viewDidLoad
{
    [self zh_viewDidLoad];
    [self reloadCustomNav];
}

- (void)zh_viewWillAppear:(BOOL)animated
{

    [self zh_viewWillAppear:animated];
    
    [self reloadCustomNav];

    if (self.zh_willAppearInjectBlock) {
        self.zh_willAppearInjectBlock(self, animated);
    }
}

- (_ZHViewControllerWillAppearInjectBlock)zh_willAppearInjectBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZh_willAppearInjectBlock:(_ZHViewControllerWillAppearInjectBlock)block
{
    objc_setAssociatedObject(self, @selector(zh_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UINavigationController (ZHFullscreenPopGesture)

+ (void)load
{
    // Inject "-pushViewController:animated:"
    Method originalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(zh_pushViewController:animated:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)zh_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.view.gestureRecognizers containsObject:self.zh_fullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.view addGestureRecognizer:self.zh_fullscreenPopGestureRecognizer];
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // Forward to primary implementation.
    [self zh_pushViewController:viewController animated:animated];
}

- (_ZHFullscreenPopGestureRecognizerDelegate *)zh_popGestureRecognizerDelegate
{
    _ZHFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);

    if (!delegate) {
        delegate = [[_ZHFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)zh_fullscreenPopGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);

    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        panGestureRecognizer.delegate = self.zh_popGestureRecognizerDelegate;
        [panGestureRecognizer addTarget:self action:@selector(panAction:)];
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

-(void)panAction:(UIPanGestureRecognizer *)getsture
{
    BOOL popBack = [objc_getAssociatedObject(getsture, @"popBack") boolValue];
    if (popBack) {
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        
        SEL selector = NSSelectorFromString(@"handleNavigationTransition:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[internalTarget class] instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:internalTarget];
        [invocation setArgument:&getsture atIndex:2];
        [invocation invoke];
    } else {
        BOOL autoDisplay = self.visibleViewController.zh_autoDisplayCustomNav;
        if (autoDisplay == NO) {
            return;
        }
        BOOL tracking = [NSRunLoop currentRunLoop].currentMode == UITrackingRunLoopMode;
        if (tracking ) {
            CGFloat navHeight = self.visibleViewController.zh_customNav.frame.size.height;
            CGPoint translation = [getsture translationInView:getsture.view];
            CGFloat changeAlpha = fabs(translation.y)/navHeight > 1.0f ? 1.0f : fabs(translation.y)/navHeight;
            NSLog(@"alpha = %f", changeAlpha);
            if (translation.y < 0) {
                self.visibleViewController.zh_customNav.alpha -= changeAlpha;
            } else {
                self.visibleViewController.zh_customNav.alpha += changeAlpha;
            }
            if (self.visibleViewController.zh_customNav.alpha < 0) {
                self.visibleViewController.zh_customNav.alpha = 0;
            }
            if (self.visibleViewController.zh_customNav.alpha > 1) {
                self.visibleViewController.zh_customNav.alpha = 1;
            }
            [getsture setTranslation:CGPointZero inView:getsture.view];
        }
    }
}

@end



@implementation UIViewController (ZHFullscreenPopGesture)


-(void)goBack
{
    
    if (self.navigationController == nil || self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)reloadCustomNav
{
    if (self.zh_customNav == nil) {
        UIImageView *navView = [[UIImageView alloc] initWithFrame:
                                CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 63)];
        navView.backgroundColor = [UIColor whiteColor];
        navView.image = [UIImage imageNamed:@"nav_bg"];
        navView.contentMode = UIViewContentModeScaleAspectFill;
        navView.userInteractionEnabled = YES;
        navView.layer.masksToBounds = YES;
        
        UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
        backBtn.backgroundColor = [UIColor clearColor];
        backBtn.contentMode = UIViewContentModeCenter;
        backBtn.tag = 1000;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [backBtn setImage:[UIImage imageNamed:@"nav_button_back_n"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"nav_button_back_h"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20 , [UIScreen mainScreen].bounds.size.width-100, 44)];
        titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
        titleLabel.font = [UIFont systemFontOfSize:18];  //设置文本字体与大小
        titleLabel.textColor = [UIColor redColor];  //设置文本颜色
        titleLabel.tag = 2000;
        titleLabel.textAlignment = UIBaselineAdjustmentAlignCenters;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [navView addSubview:titleLabel];
        
        self.zh_customNav = navView;
        
    }
    
    if (self.zh_showCustomNav) {
        self.zh_customNav.hidden = NO;
        self.navigationController.navigationBarHidden = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        UILabel *titleLabel = [self.zh_customNav viewWithTag:2000];
        if (titleLabel) {
            titleLabel.text = self.title;
        }
        
        [self.zh_customNav removeFromSuperview];
        [self.view addSubview:self.zh_customNav];
        [self.view bringSubviewToFront:self.zh_customNav];

        UIButton *backBtn = [self.zh_customNav viewWithTag:2000];
        if (backBtn) {
            if (self.navigationController== nil || self.navigationController.viewControllers.count > 1) {
                [self.zh_customNav viewWithTag:1000].hidden = NO;
            } else {
                [self.zh_customNav viewWithTag:1000].hidden = YES;
            }
        }
        
    } else {
        self.zh_customNav.hidden = YES;
    }
}

-(UIView *)zh_customNav
{
    return objc_getAssociatedObject(self, @"navigationView");
}

-(void)setZh_customNav:(UIView *)navigationView
{
    objc_setAssociatedObject(self, @"navigationView", navigationView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self reloadCustomNav];
}


-(BOOL)zh_showCustomNav
{
    return [objc_getAssociatedObject(self, @"showCustomNav") boolValue];
}

-(void)setZh_showCustomNav:(BOOL)showCustomNav
{
    objc_setAssociatedObject(self, @"showCustomNav", [NSNumber numberWithBool:showCustomNav], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self reloadCustomNav];
}

-(BOOL)zh_autoDisplayCustomNav
{
    return [objc_getAssociatedObject(self, @"autoDisplayCustomNav") boolValue];
}

-(void)setZh_autoDisplayCustomNav:(BOOL)showCustomNav
{
    objc_setAssociatedObject(self, @"autoDisplayCustomNav", [NSNumber numberWithBool:showCustomNav], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)zh_interactivePopDisabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setZh_interactivePopDisabled:(BOOL)disabled
{
    objc_setAssociatedObject(self, @selector(zh_interactivePopDisabled), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
