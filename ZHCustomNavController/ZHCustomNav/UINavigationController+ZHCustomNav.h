
#import <UIKit/UIKit.h>

@interface UINavigationController (ZHFullscreenPopGesture)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *zh_fullscreenPopGestureRecognizer;

@end


@interface UIViewController (ZHFullscreenPopGesture)

@property (nonatomic, assign) BOOL zh_interactivePopDisabled;

@property (strong, nonatomic) UIView *zh_customNav;

@property (assign, nonatomic) BOOL zh_showCustomNav;

//当viewcontroller中包含scrollview,并且上下滑动，自动显示隐藏CustomNav
@property (assign, nonatomic) BOOL zh_autoDisplayCustomNav;

-(void)reloadCustomNav;


@end
