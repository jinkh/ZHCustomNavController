#import "UINavigationController+ZHCustomNav.h"
#import <objc/runtime.h>

@interface _ZHFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation _ZHFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // Disable when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.zh_interactivePopDisabled) {
        return NO;
    }

    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
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
    
    Method originalMethod3 = class_getInstanceMethod(self, @selector(setTitle:));
    Method swizzledMethod3 = class_getInstanceMethod(self, @selector(zh_setTitle:));
    method_exchangeImplementations(originalMethod3, swizzledMethod3);
}

- (void)zh_viewDidLoad
{
    [self zh_viewDidLoad];
    if (self.zh_customNav == nil && self.zh_showCustomNav) {
        UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
        navView.backgroundColor = [UIColor whiteColor];
        
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
        self.navigationController.navigationBarHidden = YES;
    }
}

-(void)zh_setTitle:(NSString *)title
{
    [self zh_setTitle:title];
    if ( self.zh_showCustomNav) {
        if (self.zh_customNav == nil) {
            UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
            navView.backgroundColor = [UIColor whiteColor];
            
            UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
            backBtn.backgroundColor = [UIColor clearColor];
            backBtn.contentMode = UIViewContentModeCenter;
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
            self.navigationController.navigationBarHidden = YES;
        }
        ((UILabel *)[self.zh_customNav viewWithTag:2000]).text = title;
    }
}

- (void)zh_viewWillAppear:(BOOL)animated
{

    [self zh_viewWillAppear:animated];
    if (self.zh_customNav != nil && self.zh_showCustomNav) {
        [self.zh_customNav  removeFromSuperview];
        [self.view addSubview:self.zh_customNav];
        [self.view bringSubviewToFront:self.zh_customNav];
        
        if (self.navigationController.viewControllers.count > 1) {
            [self.zh_customNav viewWithTag:1000].hidden = NO;
        } else {
            [self.zh_customNav viewWithTag:1000].hidden = YES;
        }
        
    }
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
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.zh_fullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.zh_fullscreenPopGestureRecognizer];

        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.zh_fullscreenPopGestureRecognizer.delegate = self.zh_popGestureRecognizerDelegate;
        [self.zh_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];

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
        
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

@end



@implementation UIViewController (ZHFullscreenPopGesture)


-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIView *)zh_customNav
{
    return objc_getAssociatedObject(self, @"navigationView");
}

-(void)setZh_customNav:(UIView *)navigationView
{
    objc_setAssociatedObject(self, @"navigationView", navigationView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)zh_showCustomNav
{
    return [objc_getAssociatedObject(self, @"showCustomNav") boolValue];
}

-(void)setZh_showCustomNav:(BOOL)showCustomNav
{
    objc_setAssociatedObject(self, @"showCustomNav", [NSNumber numberWithBool:showCustomNav], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)zh_interactivePopDisabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setZh_interactivePopDisabled:(BOOL)disabled
{
    objc_setAssociatedObject(self, @selector(zh_interactivePopDisabled), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)zh_prefersNavigationBarHidden
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setZh_prefersNavigationBarHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, @selector(zh_prefersNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
