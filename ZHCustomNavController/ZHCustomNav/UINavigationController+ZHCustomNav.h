
#import <UIKit/UIKit.h>

@interface UINavigationController (ZHFullscreenPopGesture)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *zh_fullscreenPopGestureRecognizer;

@end


@interface UIViewController (ZHFullscreenPopGesture)

@property (nonatomic, assign) BOOL zh_interactivePopDisabled;

@property (strong, nonatomic) UIView *zh_customNav;

@property (assign, nonatomic) BOOL zh_showCustomNav;

@property (strong, nonatomic) NSString *zh_title;

-(void)reloadCustomNav;


@end
