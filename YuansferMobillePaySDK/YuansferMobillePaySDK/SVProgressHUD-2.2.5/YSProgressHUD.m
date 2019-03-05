//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2018 Sam Vermette and contributors. All rights reserved.
//

#if !__has_feature(objc_arc)
#error YSProgressHUD is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "YSProgressHUD.h"
#import "YSIndefiniteAnimatedView.h"
#import "YSProgressAnimatedView.h"
#import "YSRadialGradientLayer.h"

NSString * const YSProgressHUDDidReceiveTouchEventNotification = @"YSProgressHUDDidReceiveTouchEventNotification";
NSString * const YSProgressHUDDidTouchDownInsideNotification = @"YSProgressHUDDidTouchDownInsideNotification";
NSString * const YSProgressHUDWillDisappearNotification = @"YSProgressHUDWillDisappearNotification";
NSString * const YSProgressHUDDidDisappearNotification = @"YSProgressHUDDidDisappearNotification";
NSString * const YSProgressHUDWillAppearNotification = @"YSProgressHUDWillAppearNotification";
NSString * const YSProgressHUDDidAppearNotification = @"YSProgressHUDDidAppearNotification";

NSString * const YSProgressHUDStatusUserInfoKey = @"YSProgressHUDStatusUserInfoKey";

static const CGFloat YSProgressHUDParallaxDepthPoints = 10.0f;
static const CGFloat YSProgressHUDUndefinedProgress = -1;
static const CGFloat YSProgressHUDDefaultAnimationDuration = 0.15f;
static const CGFloat YSProgressHUDVerticalSpacing = 12.0f;
static const CGFloat YSProgressHUDHorizontalSpacing = 12.0f;
static const CGFloat YSProgressHUDLabelSpacing = 8.0f;

NSString * const kError_1 = @"iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAQAAADYBBcfAAAAf0lEQVR4AcXPNwLCMBjFYOXk9N5Px8TExCnMKDr/m6IpLp/t0FM3ltTq2HJxuKKxKrEjjRHY5g+VTXhpLa0z6fonG2Ml2nGSlWmBSWMmjZk0ZlJZSEPmv/mvGRuzlgbMf42ZNGbSmEljJo2ZNGfSAivQg6xAFw6vDKm24Ewv3QFGy16sTuTeywAAAABJRU5ErkJggg==";
NSString * const kError_2 = @"iVBORw0KGgoAAAANSUhEUgAAADgAAAA4CAQAAAACj/OVAAAA+UlEQVR4Ae3WtVkFAQAE4X3WM64J7hIR0RNeARJdfpJg92SSwZkG/m+zzcf132qK7KUTv16OU2Q+rYpUqXKWjs6dp0qVh7TaS2WSLa7Kelp1G6pFitxJOgmTPsekzzHpc0z6HJM+x6TPMelzTPockz7HJHM+yZxPMueTzMkkcyrJnEoyp5LMqWSfOZe8Y04lgVMbvKy7bHhIu0b2w2PuEkj9Z/bMU8lcx/6xzIVJm2PS44C0OSBtjkidY1LnmNQ5JnWOSZ1jUueY1DkmdY5Jg+M6QAJnksz5ZJs7Bk4iT1ucTe6lVdHibPIhrZbylM0WZ5EHDTedX9J/NRVkiWJ8UPpsAAAAAElFTkSuQmCC";
NSString * const kError_3 = @"iVBORw0KGgoAAAANSUhEUgAAAFQAAABUCAMAAAArteDzAAAANlBMVEUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC3dmhyAAAAEnRSTlMAMNL2kgYv/63T8pOur7CY9c9OMeGqAAAA9UlEQVR42u3XOQ6DQBAFUWAYDzvm/pe1JZKWKiwSW90ZP3gZiOryfun6oYzVInUswys8D621qUpz+iJzGEoLqjDbEpa1BVWYbYzTFlRhbhGg6k2q3qTqTarepGpNr9L0Kk2v0vQqTa/S9CpNr9L0Kk2v0vQqTa/S9CpNr9L0Kk2v0vQqTa/S9CpNr9L0Kk2v0vQqTa/S9Oq+0/QqTK3S9OpxmwdMg+43uluU77uvDZpUvXkcXuV3qW5UfXdQ9SZVb1L1JlRtZhtmG2YbZhtmG2YbZhv+TRt251NteIapPNWG77AMT7XhFYZ+Xlb/g7iWq+/yfug+XhYjYODv3gkAAAAASUVORK5CYII=";

NSString * const kInfo_1 = @"iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAQAAADYBBcfAAABNElEQVR4Aa3UJUAkUQAG4A/XBGnSpZNGT6u93WakXoZ67h0rSO8Bd3plDe9xSTfl7PEG//408lw8pRcmrbrQSnNh1aQXbpWzreqzskR7mkTZZ1XbcjL1mlFX0S7UrqJuRq+IIfuWDcoyaNm+IYF+h35qc5M2Px3q9y/zlsNinqUJiy6Z94+cEwNCq2lCA2py/tgxDre2CBU7ACPqOtxVu7oR4J1PYt6kifnkHbCuKGYnTUzJBnAhuVfBxAXQ0nGvgh1ajyz44K7ed3KKNmLLcXvBT97HN0C8YGQDsGPszgVf//s259jAnQr2q8n7x6xFoQnjQotmrx/kH27z/fpBZtihRQOy9Ft0aFhEnxlN49HLalzTjH6ZcvZUfVD6cz2WfFC1J+9Wr0xZd+kqzaV1U155Or8AoAZgHvq3Ef0AAAAASUVORK5CYII=";
NSString * const kInfo_2 = @"iVBORw0KGgoAAAANSUhEUgAAADgAAAA4CAQAAAACj/OVAAAC90lEQVR4Ae3YA4wliRaA4a9Gt3vteN1jeyacYNTh2rZtm4333tp6i3ARrTW2bdvG2fAmd3RZG81XUUV/GUcWh7V0vTf8ZK6NQthorp+84XotVVgHdRaIQywL1OmoAhKDDRFCWOb/7jZIKyfKaOEELQ1wh08sEkIYolaiDN0ME8JaDXpKHFx3DVYKYZhuSlKl3h5hufscpRDVbrdQ2KNRlSLVGCfsUu9oxaj2nB3CODUKp481wnTdlKKt8cIafRRokC3CD45RqmpfClsMUoBetggfaqYciXphi17yONtq4SOJ8tULa9Q4hIyxwneaqoTE58JYGQfVKMx1rHwyHvSgjHyOMElodBDd7LZLd/k9IIQH5NfGNrt1sz+JEUIdFQ3yhDBMYj+1wjJHK0TGQx6SUYiM2UKt/fwt3CcNVwlD5NJRWOMoaWhmodBJjleFBml5WnhNjsVCD4VKXOQiiUK1FBbJor2wSqJQFwvhEoWbJrSUdaPwjcI9JIQXFe4N4QZZ7wh3pxq8WnhD1h/C4FSDfYWfZc0TalINnizMlbVROCbVYFNhk6wQpBpki/h3g5vtyD2kR6UabCKszr1ozko1eJIwJ/e2GJhqsJfwR+6Nf0eqwSuEd2TdJPw/1WCjcEPuw3tZqsGJQktZLBG6pBY8Q1gkx2vCy6kFHxFek6OTsFJ1KsGm5gid5DJEuC2V4EXCEPupFRaqrniwmSlC7cE+hJ+rePA+YYTkYJ/627UrOPiC/M6wyW7dDnV7TnWEfM4VwnnyaWGk0OigqowV/i+Rz0AD5feWMFaVQ6ixtmKfxE8K67Qs7Je7TqI8TxT2yw2DbRP+r0qpmntL2GawAvWzVhitpVKc5i9hrX7FD4a2ekJGMZq516biB0NQpcEeYY5rtSgwdpmpwh7/UaUk3QwXwiJPqnEoZ3nSXCEM100ZErXZ8eU0b7hKb6doAhIn6+lyjSbmjC9TGdBusTlnfaE6HVVYSzd4089mW2unndaa7RdvukFLh2X9A6AofdYJOr4uAAAAAElFTkSuQmCC";
NSString * const kInfo_3 = @"iVBORw0KGgoAAAANSUhEUgAAAFQAAABUCAQAAAC2YthKAAAEd0lEQVR4Ae2bBWzkRhSGP9uqU6kLhY2oIM56T7qAsAzHJzi+E5dBWOaKj5mZSQxlZmZmZmZuwxk9WTsH2XjGFCnfiNZrv/lNs/Pe/Is5I4xQZAxXsJF7eI0v+Zn/+ZNv+ZAXuYeNXMEYimSKxzks4RW66G3QuniFJZyDR+q0sZZv6Y3YvmUtbaSEywye0rr/lyfZxFVMpkoFBwCHClUmcxWbeJJ/tf2fYgYuCTOV1+u6/JgljKGJRjQxhiV8XHfkG0wjMUbzSNjRn2zhFKJyClv4K4zxCK3Ejs88/pcOfmM+zZjSzHx+k0j/Mw+fGGnhJQn9HwspY0uZhfwnEV+iSkxMC6/AQ9SIi4CHwjs0nRi4kh4V7h8uI24u5R8Vu4crscJhkZz1u7STBO28Iz0swjGXuU2C3EmBpChwr/SyzVTqWgmwBY8k8dkvPa3FgBvl4NU4JI3DGuntRiIyQ16hfTikgcM+ea1mEIEqv6rD7sMnLXx5Vn8lGPohL8qbXiRNCryl+n0RnyExT+3+N22YMItXeZU5mFDlD9X3PIZAq/ymX4oJNZlGd1HDhItkDtBKQx6RH0szzqNX2nmY8bDMrBowTaYeAWaMCq/oKMwIZLoynUFwZVq8ECHdZ1RYqDS8jtvoev7K0WTJ0TI4TuOwPKN2WEDWLFA6nuEwtKqv/6KZrGmWhKV1sEnIDvLAjsNPUjzJ088mD5wtdQCPgzhHffUZLracxEnY4vKZ0nMOB7FEfbEMW1aqOCuxZamKs5SDeEXOwI4avdJqWCF3+BV0KNGlErgjseP0UOjp2NGkEr8uSmiMUcGfhNwIRSpcY9C4QoaDHAmV4fIKNDaojZflSuhlKs4GNO5WG8fnSuh4FedeNF5VG6u5Etqi4ryGxldqYyVXQisqztfUIxMrN1dCHZl01iPFa3IlFMk2hqVQufXlXAkta7dee5lOyJXQE7SXSRuearkSGsjwNLwG/Pz/hG4cppOSYTPNK8vEuSl3E+eyfSpiL9QgFUGSqWUZC22cbMoZfIqbC6Eun8odNihApChUChDf4dmXdAyF2pd0oF1W4iuZC5UiGW32ZUcLofZlR5iOFHIzFSqFXKYblMZTFbpQXCcugzAdWWxIS6jBYoPwqCzfZCRUfBGPmi+ImQs1XxBLcInxJFmV7jEq5rYgS4xRF20LROcmOunkJqJT4E3x7fgMkUAGiNvwiM5R/S06HreJZycwMRZsTs1YsBkxFphaNVamYtVYZWTVENalZH45gj3S0zpbO9HtidqJ7ra0E2kGrXdoJQlG6wateCxvlyZoebuGGJgRmggfJCAuqjwoUX9nJjER1NkyF1DCliIL6myZATHiMz80uv7ILRyLKcdyMz+GRtf5+MROq2Yd3snZuETB5Wx28qeBddiAabxBb9g+YymTKdCIApNZymeaGXt6+vb2Tp6qs7cLdfb2p+hEt7fPwiUl2lnL9/RGbN+zlo78/wVjDB6ZUmQsV7KRe3idr/iZTv7kOz7iJe5hI1cylhIjjGBKH4JVYGTk5xMMAAAAAElFTkSuQmCC";

NSString * const kSuccess_1 = @"iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAQAAADYBBcfAAAAzUlEQVQ4Ee3BIS+EYQAA4OfzcuECwWx2xRTTiKaS+QFEGzeza3STJJtqmuGIJppIPZMuXrt0wYUb3k8QzBzupZnn4U/bdu8HtuR2JSvLHcgkWhadCBItenKhING8jitFiWa13RiUaFpLzbBEk5rqRiUa19AwJlFJXdOErkr6dDeipmVKV5kH5wZ8NORW24xPrYjO9Huv6FrHnC+tiqqCNwWXHi34Vll0KngVVD1b0pN10bGAzKFoTc82REeCPblNSSqiO7kdySqiff/8ygtf5zWMYSTZzgAAAABJRU5ErkJggg==";
NSString * const kSuccess_2 = @"iVBORw0KGgoAAAANSUhEUgAAADgAAAA4CAQAAAACj/OVAAABlUlEQVR4Ae3WJ5QaURSH8e8x6VXhRuLAERcsaKKDTvHgT3pMtvfed+3i0SBZtZjtPSa997xzVfq0mzYfTXF+lGH4Exf3Z2bo5Ak3UauDD3zgCUrdsNwHOlCpItw8Dgpd5b3lFjmCQiXhahxDoQu8tVydkyhU4JXlmpxFoRzPLLdMEoXO8dByq7golOG+5bZJoVCKHcvdJ41CLmuWe0gWhZK0LPeM8yh0liXLvSKPQqdoWO4tRRQ6Ts1y77iIQkeoWu49l1HIYUH+gsooZBgR7joqdQjXjkrXhRvBoFDZ73xw8NMV+T+vep0Pbbxj1DNa4p3Mh+N47Il94qwnsijzocFJPHdXvonpXybzweaDodsTKfOBlv/5YOgRcuqnZFbmwxouQHBy8odkOrz5YOgTcuK7ZIptmQ8ZgPDI8W+SLqthzwfDgJBjON+dDzmAKMgEgHSWpsyHAiFnGPyKPEk9yvlgGBJyFAMck/nwnhIRZRhGSI5SFe6Kzv/4hjxWiDjDqFAyH0CP7ECpBJ08pRPDX1RcXFzcR+Za3bOOSHVnAAAAAElFTkSuQmCC";
NSString * const kSuccess_3 = @"iVBORw0KGgoAAAANSUhEUgAAAFQAAABUCAQAAAC2YthKAAACkUlEQVR4Ae3aA5AeSxRH8fNs24pt27Zt27Zt27ZtOy+2bduZ+sf6cCs1vy4ues+yb9cOLpfL5XprfUBbLvI/ETDtPQZy697aiGHv0JVbD9YlDGvBLWe1x6xakjmJDzGqjGTO4VOMys9NJ3MpX2FUZq47mev4HqNScMXJ3MYvGBWPC07mPv7CqMicdTKPEgijQnLSyTxNKIwKwBEn8zyRMeoP9slxGQ+jfmKbk3mFVBj1LeuczOtkxagvWeJk3qQARn3KLDnVy2LUh0yQzNp25/ehktnS7vzeUzK78Q5GtZHMQbyHUfUkc6zd+b2CZM7kY4wqLPP7Ej7DqOwyv6/lK4xKxTUncws/YFR8uWbs5neMiirXjIMEwKgwnHYyjxESo4JwVK4ZkTDqH5nfLxAbo37T+Z2kGPUD62V+z4BRX7Fc5vc8duf3eXKql8Qjvqc948nu0fl9imRWx0OmPdiwksfm95GS2RRPkcOtokfm976S2cmT8/tU2bg8b6qD7Nbfk5nwMxs9dnFtIjuN5j087Gc2eSS1muwyjQ/xgl/YLB+kDK+jhOywgE/xkl/ZIn+gS/Oqcss1YyVfIbybWopXkV6uGRv4wftDxFZJLcnLSiJ/4rb7Zn7/nW2SWpyXEUv/TcB/CN+lFuNFIsr8fpRg+NDvbJfUojxPSJ3fCYeP/cEOSS2MUgE4IPN7dPzgT3ZKakEc4nd2yfyeEGUo9Qc5Iq6TBj/6i12Smh/1FWvkdTnws7/ZLTn5ZH5frL9uGPCPpN54kPoRM+VUr2TnZr5HUvPyAWMlswGG/Mte+bVZIpntMOY/J1VXb94Be6n7HsscznuYFIB9ph/zEQHZb/oxHxGAeZxlIF9hmMvlcrlcLpfrNuW/+kr37AsRAAAAAElFTkSuQmCC";

@interface YSProgressHUD ()

@property (nonatomic, strong) NSTimer *graceTimer;
@property (nonatomic, strong) NSTimer *fadeOutTimer;

@property (nonatomic, strong) UIControl *controlView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) YSRadialGradientLayer *backgroundRadialGradientLayer;
@property (nonatomic, strong) UIVisualEffectView *hudView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *indefiniteAnimatedView;
@property (nonatomic, strong) YSProgressAnimatedView *ringView;
@property (nonatomic, strong) YSProgressAnimatedView *backgroundRingView;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) NSUInteger activityCount;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;
@property (nonatomic, readonly) UIWindow *frontWindow;

#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, strong) UINotificationFeedbackGenerator *hapticGenerator NS_AVAILABLE_IOS(10_0);
#endif

@end

@implementation YSProgressHUD {
    BOOL _isInitializing;
}

+ (YSProgressHUD*)sharedView {
    static dispatch_once_t once;
    
    static YSProgressHUD *sharedView;
#if !defined(YS_APP_EXTENSIONS)
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds]; });
#else
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
#endif
    return sharedView;
}


#pragma mark - Setters

+ (void)setStatus:(NSString*)status {
    [[self sharedView] setStatus:status];
}

+ (void)setDefaultStyle:(YSProgressHUDStyle)style {
    [self sharedView].defaultStyle = style;
}

+ (void)setDefaultMaskType:(YSProgressHUDMaskType)maskType {
    [self sharedView].defaultMaskType = maskType;
}

+ (void)setDefaultAnimationType:(YSProgressHUDAnimationType)type {
    [self sharedView].defaultAnimationType = type;
}

+ (void)setContainerView:(nullable UIView*)containerView {
    [self sharedView].containerView = containerView;
}

+ (void)setMinimumSize:(CGSize)minimumSize {
    [self sharedView].minimumSize = minimumSize;
}

+ (void)setRingThickness:(CGFloat)ringThickness {
    [self sharedView].ringThickness = ringThickness;
}

+ (void)setRingRadius:(CGFloat)radius {
    [self sharedView].ringRadius = radius;
}

+ (void)setRingNoTextRadius:(CGFloat)radius {
    [self sharedView].ringNoTextRadius = radius;
}

+ (void)setCornerRadius:(CGFloat)cornerRadius {
    [self sharedView].cornerRadius = cornerRadius;
}

+ (void)setBorderColor:(nonnull UIColor*)color {
    [self sharedView].hudView.layer.borderColor = color.CGColor;
}

+ (void)setBorderWidth:(CGFloat)width {
    [self sharedView].hudView.layer.borderWidth = width;
}

+ (void)setFont:(UIFont*)font {
    [self sharedView].font = font;
}

+ (void)setForegroundColor:(UIColor*)color {
    [self sharedView].foregroundColor = color;
    [self setDefaultStyle:YSProgressHUDStyleCustom];
}

+ (void)setBackgroundColor:(UIColor*)color {
    [self sharedView].backgroundColor = color;
    [self setDefaultStyle:YSProgressHUDStyleCustom];
}

+ (void)setBackgroundLayerColor:(UIColor*)color {
    [self sharedView].backgroundLayerColor = color;
}

+ (void)setImageViewSize:(CGSize)size {
    [self sharedView].imageViewSize = size;
}

+ (void)setShouldTintImages:(BOOL)shouldTintImages {
    [self sharedView].shouldTintImages = shouldTintImages;
}

+ (void)setInfoImage:(UIImage*)image {
    [self sharedView].infoImage = image;
}

+ (void)setSuccessImage:(UIImage*)image {
    [self sharedView].successImage = image;
}

+ (void)setErrorImage:(UIImage*)image {
    [self sharedView].errorImage = image;
}

+ (void)setViewForExtension:(UIView*)view {
    [self sharedView].viewForExtension = view;
}

+ (void)setGraceTimeInterval:(NSTimeInterval)interval {
    [self sharedView].graceTimeInterval = interval;
}

+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].minimumDismissTimeInterval = interval;
}

+ (void)setMaximumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].maximumDismissTimeInterval = interval;
}

+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeInAnimationDuration = duration;
}

+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeOutAnimationDuration = duration;
}

+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel {
    [self sharedView].maxSupportedWindowLevel = windowLevel;
}

+ (void)setHapticsEnabled:(BOOL)hapticsEnabled {
    [self sharedView].hapticsEnabled = hapticsEnabled;
}

#pragma mark - Show Methods

+ (void)show {
    [self showWithStatus:nil];
}

+ (void)showWithMaskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self show];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showWithStatus:(NSString*)status {
    [self showProgress:YSProgressHUDUndefinedProgress status:status];
}

+ (void)showWithStatus:(NSString*)status maskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showProgress:(float)progress {
    [self showProgress:progress status:nil];
}

+ (void)showProgress:(float)progress maskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showProgress:(float)progress status:(NSString*)status {
    [[self sharedView] showProgress:progress status:status];
}

+ (void)showProgress:(float)progress status:(NSString*)status maskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress status:status];
    [self setDefaultMaskType:existingMaskType];
}


#pragma mark - Show, then automatically dismiss methods

+ (void)showInfoWithStatus:(NSString*)status {
    [self showImage:[self sharedView].infoImage status:status];
    
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeWarning];
        });
    }
#endif
}

+ (void)showInfoWithStatus:(NSString*)status maskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showInfoWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showSuccessWithStatus:(NSString*)status {
    [self showImage:[self sharedView].successImage status:status];

#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (@available(iOS 10, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
        });
    }
#endif
}

+ (void)showSuccessWithStatus:(NSString*)status maskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showSuccessWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
    
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
        });
    }
#endif
}

+ (void)showErrorWithStatus:(NSString*)status {
    [self showImage:[self sharedView].errorImage status:status];
    
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeError];
        });
    }
#endif
}

+ (void)showErrorWithStatus:(NSString*)status maskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showErrorWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
    
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeError];
        });
    }
#endif
}

+ (void)showImage:(UIImage*)image status:(NSString*)status {
    NSTimeInterval displayInterval = [self displayDurationForString:status];
    [[self sharedView] showImage:image status:status duration:displayInterval];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(YSProgressHUDMaskType)maskType {
    YSProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showImage:image status:status];
    [self setDefaultMaskType:existingMaskType];
}


#pragma mark - Dismiss Methods

+ (void)popActivity {
    if([self sharedView].activityCount > 0) {
        [self sharedView].activityCount--;
    }
    if([self sharedView].activityCount == 0) {
        [[self sharedView] dismiss];
    }
}

+ (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}

+ (void)dismissWithCompletion:(YSProgressHUDDismissCompletion)completion {
    [self dismissWithDelay:0.0 completion:completion];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay {
    [self dismissWithDelay:delay completion:nil];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(YSProgressHUDDismissCompletion)completion {
    [[self sharedView] dismissWithDelay:delay completion:completion];
}


#pragma mark - Offset

+ (void)setOffsetFromCenter:(UIOffset)offset {
    [self sharedView].offsetFromCenter = offset;
}

+ (void)resetOffsetFromCenter {
    [self setOffsetFromCenter:UIOffsetZero];
}


#pragma mark - Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        _isInitializing = YES;
        
        self.userInteractionEnabled = NO;
        self.activityCount = 0;
        
        self.backgroundView.alpha = 0.0f;
        self.imageView.alpha = 0.0f;
        self.statusLabel.alpha = 0.0f;
        self.indefiniteAnimatedView.alpha = 0.0f;
        self.ringView.alpha = self.backgroundRingView.alpha = 0.0f;
        

        _backgroundColor = [UIColor whiteColor];
        _foregroundColor = [UIColor blackColor];
        _backgroundLayerColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        // Set default values
        _defaultMaskType = YSProgressHUDMaskTypeNone;
        _defaultStyle = YSProgressHUDStyleLight;
        _defaultAnimationType = YSProgressHUDAnimationTypeFlat;
        _minimumSize = CGSizeZero;
        _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        _imageViewSize = CGSizeMake(28.0f, 28.0f);
        _shouldTintImages = YES;
        
        NSString *infoImageString = kInfo_1;
        if ([[NSString stringWithFormat:@"%.f", UIScreen.mainScreen.scale] isEqualToString:@"2"]) {
            infoImageString = kInfo_2;
        } else if ([[NSString stringWithFormat:@"%.f", UIScreen.mainScreen.scale] isEqualToString:@"3"]) {
            infoImageString = kInfo_3;
        }
        NSData *infoImageData = [[NSData alloc] initWithBase64EncodedString:infoImageString options:kNilOptions];
        
        NSString *successImageString = kSuccess_1;
        if ([[NSString stringWithFormat:@"%.f", UIScreen.mainScreen.scale] isEqualToString:@"2"]) {
            successImageString = kSuccess_2;
        } else if ([[NSString stringWithFormat:@"%.f", UIScreen.mainScreen.scale] isEqualToString:@"3"]) {
            successImageString = kSuccess_3;
        }
        NSData *successImageData = [[NSData alloc] initWithBase64EncodedString:successImageString options:kNilOptions];
        
        NSString *errorImageString = kError_1;
        if ([[NSString stringWithFormat:@"%.f", UIScreen.mainScreen.scale] isEqualToString:@"2"]) {
            errorImageString = kError_2;
        } else if ([[NSString stringWithFormat:@"%.f", UIScreen.mainScreen.scale] isEqualToString:@"3"]) {
            errorImageString = kError_3;
        }
        NSData *errorImageData = [[NSData alloc] initWithBase64EncodedString:errorImageString options:kNilOptions];
        
        _infoImage = [[UIImage alloc] initWithData:infoImageData];
        _successImage = [[UIImage alloc] initWithData:successImageData];
        _errorImage = [[UIImage alloc] initWithData:errorImageData];

        _ringThickness = 2.0f;
        _ringRadius = 18.0f;
        _ringNoTextRadius = 24.0f;
        
        _cornerRadius = 14.0f;
		
        _graceTimeInterval = 0.0f;
        _minimumDismissTimeInterval = 5.0;
        _maximumDismissTimeInterval = CGFLOAT_MAX;

        _fadeInAnimationDuration = YSProgressHUDDefaultAnimationDuration;
        _fadeOutAnimationDuration = YSProgressHUDDefaultAnimationDuration;
        
        _maxSupportedWindowLevel = UIWindowLevelNormal;
        
        _hapticsEnabled = NO;
        
        // Accessibility support
        self.accessibilityIdentifier = @"YSProgressHUD";
        self.isAccessibilityElement = YES;
        
        _isInitializing = NO;
    }
    return self;
}

- (void)updateHUDFrame {
    // Check if an image or progress ring is displayed
    BOOL imageUsed = (self.imageView.image) && !(self.imageView.hidden);
    BOOL progressUsed = self.imageView.hidden;
    
    // Calculate size of string
    CGRect labelRect = CGRectZero;
    CGFloat labelHeight = 0.0f;
    CGFloat labelWidth = 0.0f;
    
    if(self.statusLabel.text) {
        CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
        labelRect = [self.statusLabel.text boundingRectWithSize:constraintSize
                                                        options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName: self.statusLabel.font}
                                                        context:NULL];
        labelHeight = ceilf(CGRectGetHeight(labelRect));
        labelWidth = ceilf(CGRectGetWidth(labelRect));
    }
    
    // Calculate hud size based on content
    // For the beginning use default values, these
    // might get update if string is too large etc.
    CGFloat hudWidth;
    CGFloat hudHeight;
    
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    
    if(imageUsed || progressUsed) {
        contentWidth = CGRectGetWidth(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame);
        contentHeight = CGRectGetHeight(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame);
    }
    
    // |-spacing-content-spacing-|
    hudWidth = YSProgressHUDHorizontalSpacing + MAX(labelWidth, contentWidth) + YSProgressHUDHorizontalSpacing;
    
    // |-spacing-content-(labelSpacing-label-)spacing-|
    hudHeight = YSProgressHUDVerticalSpacing + labelHeight + contentHeight + YSProgressHUDVerticalSpacing;
    if(self.statusLabel.text && (imageUsed || progressUsed)){
        // Add spacing if both content and label are used
        hudHeight += YSProgressHUDLabelSpacing;
    }
    
    // Update values on subviews
    self.hudView.bounds = CGRectMake(0.0f, 0.0f, MAX(self.minimumSize.width, hudWidth), MAX(self.minimumSize.height, hudHeight));
    
    // Animate value update
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // Spinner and image view
    CGFloat centerY;
    if(self.statusLabel.text) {
        CGFloat yOffset = MAX(YSProgressHUDVerticalSpacing, (self.minimumSize.height - contentHeight - YSProgressHUDLabelSpacing - labelHeight) / 2.0f);
        centerY = yOffset + contentHeight / 2.0f;
    } else {
        centerY = CGRectGetMidY(self.hudView.bounds);
    }
    self.indefiniteAnimatedView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    if(self.progress != YSProgressHUDUndefinedProgress) {
        self.backgroundRingView.center = self.ringView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    }
    self.imageView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);

    // Label
    if(imageUsed || progressUsed) {
        centerY = CGRectGetMaxY(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame) + YSProgressHUDLabelSpacing + labelHeight / 2.0f;
    } else {
        centerY = CGRectGetMidY(self.hudView.bounds);
    }
    self.statusLabel.frame = labelRect;
    self.statusLabel.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    
    [CATransaction commit];
}

#if TARGET_OS_IOS
- (void)updateMotionEffectForOrientation:(UIInterfaceOrientation)orientation {
    UIInterpolatingMotionEffectType xMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis : UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis;
    UIInterpolatingMotionEffectType yMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis : UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis;
    [self updateMotionEffectForXMotionEffectType:xMotionEffectType yMotionEffectType:yMotionEffectType];
}
#endif

- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType {
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:xMotionEffectType];
    effectX.minimumRelativeValue = @(-YSProgressHUDParallaxDepthPoints);
    effectX.maximumRelativeValue = @(YSProgressHUDParallaxDepthPoints);
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:yMotionEffectType];
    effectY.minimumRelativeValue = @(-YSProgressHUDParallaxDepthPoints);
    effectY.maximumRelativeValue = @(YSProgressHUDParallaxDepthPoints);
    
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[effectX, effectY];
    
    // Clear old motion effect, then add new motion effects
    self.hudView.motionEffects = @[];
    [self.hudView addMotionEffect:effectGroup];
}

- (void)updateViewHierarchy {
    // Add the overlay to the application window if necessary
    if(!self.controlView.superview) {
        if(self.containerView){
            [self.containerView addSubview:self.controlView];
        } else {
#if !defined(YS_APP_EXTENSIONS)
            [self.frontWindow addSubview:self.controlView];
#else
            // If SVProgressHUD is used inside an app extension add it to the given view
            if(self.viewForExtension) {
                [self.viewForExtension addSubview:self.controlView];
            }
#endif
        }
    } else {
        // The HUD is already on screen, but maybe not in front. Therefore
        // ensure that overlay will be on top of rootViewController (which may
        // be changed during runtime).
        [self.controlView.superview bringSubviewToFront:self.controlView];
    }
    
    // Add self to the overlay view
    if(!self.superview) {
        [self.controlView addSubview:self];
    }
}

- (void)setStatus:(NSString*)status {
    self.statusLabel.text = status;
    self.statusLabel.hidden = status.length == 0;
    [self updateHUDFrame];
}

- (void)setGraceTimer:(NSTimer*)timer {
    if(_graceTimer) {
        [_graceTimer invalidate];
        _graceTimer = nil;
    }
    if(timer) {
        _graceTimer = timer;
    }
}

- (void)setFadeOutTimer:(NSTimer*)timer {
    if(_fadeOutTimer) {
        [_fadeOutTimer invalidate];
        _fadeOutTimer = nil;
    }
    if(timer) {
        _fadeOutTimer = timer;
    }
}


#pragma mark - Notifications and their handling

- (void)registerNotifications {
#if TARGET_OS_IOS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (NSDictionary*)notificationUserInfo {
    return (self.statusLabel.text ? @{YSProgressHUDStatusUserInfoKey : self.statusLabel.text} : nil);
}

- (void)positionHUD:(NSNotification*)notification {
    CGFloat keyboardHeight = 0.0f;
    double animationDuration = 0.0;

#if !defined(YS_APP_EXTENSIONS) && TARGET_OS_IOS
    self.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
#elif !defined(YS_APP_EXTENSIONS) && !TARGET_OS_IOS
    self.frame= [UIApplication sharedApplication].keyWindow.bounds;
#else
    if (self.viewForExtension) {
        self.frame = self.viewForExtension.frame;
    } else {
        self.frame = UIScreen.mainScreen.bounds;
    }
#if TARGET_OS_IOS
    UIInterfaceOrientation orientation = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
#endif
#endif
    
#if TARGET_OS_IOS
    // Get keyboardHeight in regard to current state
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            keyboardHeight = CGRectGetWidth(keyboardFrame);
            
            if(UIInterfaceOrientationIsPortrait(orientation)) {
                keyboardHeight = CGRectGetHeight(keyboardFrame);
            }
        }
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
#endif
    
    // Get the currently active frame of the display (depends on orientation)
    CGRect orientationFrame = self.bounds;

#if !defined(YS_APP_EXTENSIONS) && TARGET_OS_IOS
    CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
#else
    CGRect statusBarFrame = CGRectZero;
#endif
    
#if TARGET_OS_IOS
    // Update the motion effects in regard to orientation
    [self updateMotionEffectForOrientation:orientation];
#else
    [self updateMotionEffectForXMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis yMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
#endif
    
    // Calculate available height for display
    CGFloat activeHeight = CGRectGetHeight(orientationFrame);
    if(keyboardHeight > 0) {
        activeHeight += CGRectGetHeight(statusBarFrame) * 2;
    }
    activeHeight -= keyboardHeight;
    
    CGFloat posX = CGRectGetMidX(orientationFrame);
    CGFloat posY = floorf(activeHeight*0.45f);

    CGFloat rotateAngle = 0.0;
    CGPoint newCenter = CGPointMake(posX, posY);
    
    if(notification) {
        // Animate update if notification was present
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                             [self.hudView setNeedsDisplay];
                         } completion:nil];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    if (self.containerView) {
        self.hudView.center = CGPointMake(self.containerView.center.x + self.offsetFromCenter.horizontal, self.containerView.center.y + self.offsetFromCenter.vertical);
    } else {
        self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
    }
}


#pragma mark - Event handling

- (void)controlViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:YSProgressHUDDidReceiveTouchEventNotification
                                                        object:self
                                                      userInfo:[self notificationUserInfo]];
    
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.hudView.frame, touchLocation)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:YSProgressHUDDidTouchDownInsideNotification
                                                            object:self
                                                          userInfo:[self notificationUserInfo]];
    }
}


#pragma mark - Master show/dismiss methods

- (void)showProgress:(float)progress status:(NSString*)status {
    __weak YSProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong YSProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            if(strongSelf.fadeOutTimer) {
                strongSelf.activityCount = 0;
            }
            
            // Stop timer
            strongSelf.fadeOutTimer = nil;
            strongSelf.graceTimer = nil;
            
            // Update / Check view hierarchy to ensure the HUD is visible
            [strongSelf updateViewHierarchy];
            
            // Reset imageView and fadeout timer if an image is currently displayed
            strongSelf.imageView.hidden = YES;
            strongSelf.imageView.image = nil;
            
            // Update text and set progress to the given value
            strongSelf.statusLabel.hidden = status.length == 0;
            strongSelf.statusLabel.text = status;
            strongSelf.progress = progress;
            
            // Choose the "right" indicator depending on the progress
            if(progress >= 0) {
                // Cancel the indefiniteAnimatedView, then show the ringLayer
                [strongSelf cancelIndefiniteAnimatedViewAnimation];
                
                // Add ring to HUD
                if(!strongSelf.ringView.superview){
                    [strongSelf.hudView.contentView addSubview:strongSelf.ringView];
                }
                if(!strongSelf.backgroundRingView.superview){
                    [strongSelf.hudView.contentView addSubview:strongSelf.backgroundRingView];
                }
                
                // Set progress animated
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                strongSelf.ringView.strokeEnd = progress;
                [CATransaction commit];
                
                // Update the activity count
                if(progress == 0) {
                    strongSelf.activityCount++;
                }
            } else {
                // Cancel the ringLayer animation, then show the indefiniteAnimatedView
                [strongSelf cancelRingLayerAnimation];
                
                // Add indefiniteAnimatedView to HUD
                [strongSelf.hudView.contentView addSubview:strongSelf.indefiniteAnimatedView];
                if([strongSelf.indefiniteAnimatedView respondsToSelector:@selector(startAnimating)]) {
                    [(id)strongSelf.indefiniteAnimatedView startAnimating];
                }
                
                // Update the activity count
                strongSelf.activityCount++;
            }
            
            // Fade in delayed if a grace time is set
            if (self.graceTimeInterval > 0.0 && self.backgroundView.alpha == 0.0f) {
                strongSelf.graceTimer = [NSTimer timerWithTimeInterval:self.graceTimeInterval target:strongSelf selector:@selector(fadeIn:) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:strongSelf.graceTimer forMode:NSRunLoopCommonModes];
            } else {
                [strongSelf fadeIn:nil];
            }
            
            // Tell the Haptics Generator to prepare for feedback, which may come soon
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
            if (@available(iOS 10.0, *)) {
                [strongSelf.hapticGenerator prepare];
            }
#endif
        }
    }];
}

- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration {
    __weak YSProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong YSProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            // Stop timer
            strongSelf.fadeOutTimer = nil;
            strongSelf.graceTimer = nil;
            
            // Update / Check view hierarchy to ensure the HUD is visible
            [strongSelf updateViewHierarchy];
            
            // Reset progress and cancel any running animation
            strongSelf.progress = YSProgressHUDUndefinedProgress;
            [strongSelf cancelRingLayerAnimation];
            [strongSelf cancelIndefiniteAnimatedViewAnimation];
            
            // Update imageView
            if (self.shouldTintImages) {
                if (image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    strongSelf.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                strongSelf.imageView.tintColor = strongSelf.foregroundColorForStyle;;
            } else {
                strongSelf.imageView.image = image;
            }
            strongSelf.imageView.hidden = NO;
            
            // Update text
            strongSelf.statusLabel.hidden = status.length == 0;
            strongSelf.statusLabel.text = status;
            
            // Fade in delayed if a grace time is set
            // An image will be dismissed automatically. Thus pass the duration as userInfo.
            if (self.graceTimeInterval > 0.0 && self.backgroundView.alpha == 0.0f) {
                strongSelf.graceTimer = [NSTimer timerWithTimeInterval:self.graceTimeInterval target:strongSelf selector:@selector(fadeIn:) userInfo:@(duration) repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:strongSelf.graceTimer forMode:NSRunLoopCommonModes];
            } else {
                [strongSelf fadeIn:@(duration)];
            }
        }
    }];
}

- (void)fadeIn:(id)data {
    // Update the HUDs frame to the new content and position HUD
    [self updateHUDFrame];
    [self positionHUD:nil];
    
    // Update accessibility as well as user interaction
    if(self.defaultMaskType != YSProgressHUDMaskTypeNone) {
        self.controlView.userInteractionEnabled = YES;
        self.accessibilityLabel = self.statusLabel.text ?: NSLocalizedString(@"Loading", nil);
        self.isAccessibilityElement = YES;
    } else {
        self.controlView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = self.statusLabel.text ?: NSLocalizedString(@"Loading", nil);
        self.hudView.isAccessibilityElement = YES;
    }
    
    // Get duration
    id duration = [data isKindOfClass:[NSTimer class]] ? ((NSTimer *)data).userInfo : data;
    
    // Show if not already visible
    if(self.backgroundView.alpha != 1.0f) {
        // Post notification to inform user
        [[NSNotificationCenter defaultCenter] postNotificationName:YSProgressHUDWillAppearNotification
                                                            object:self
                                                          userInfo:[self notificationUserInfo]];
        
        // Shrink HUD to to make a nice appear / pop up animation
        self.hudView.transform = self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.5f, 1/1.5f);
        
        __block void (^animationsBlock)(void) = ^{
            // Zoom HUD a little to make a nice appear / pop up animation
            self.hudView.transform = CGAffineTransformIdentity;
            
            // Fade in all effects (colors, blur, etc.)
            [self fadeInEffects];
        };
        
        __block void (^completionBlock)(void) = ^{
            // Check if we really achieved to show the HUD (<=> alpha)
            // and the change of these values has not been cancelled in between e.g. due to a dismissal
            if(self.backgroundView.alpha == 1.0f){
                // Register observer <=> we now have to handle orientation changes etc.
                [self registerNotifications];
                
                // Post notification to inform user
                [[NSNotificationCenter defaultCenter] postNotificationName:YSProgressHUDDidAppearNotification
                                                                    object:self
                                                                  userInfo:[self notificationUserInfo]];
                
                // Update accessibility
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.statusLabel.text);
                
                // Dismiss automatically if a duration was passed as userInfo. We start a timer
                // which then will call dismiss after the predefined duration
                if(duration){
                    self.fadeOutTimer = [NSTimer timerWithTimeInterval:[(NSNumber *)duration doubleValue] target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
                }
            }
        };
        
        // Animate appearance
        if (self.fadeInAnimationDuration > 0) {
            // Animate appearance
            [UIView animateWithDuration:self.fadeInAnimationDuration
                                  delay:0
                                options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                             animations:^{
                                 animationsBlock();
                             } completion:^(BOOL finished) {
                                 completionBlock();
                             }];
        } else {
            animationsBlock();
            completionBlock();
        }
        
        // Inform iOS to redraw the view hierarchy
        [self setNeedsDisplay];
    } else {
        // Update accessibility
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.statusLabel.text);
        
        // Dismiss automatically if a duration was passed as userInfo. We start a timer
        // which then will call dismiss after the predefined duration
        if(duration){
            self.fadeOutTimer = [NSTimer timerWithTimeInterval:[(NSNumber *)duration doubleValue] target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}

- (void)dismissWithDelay:(NSTimeInterval)delay completion:(YSProgressHUDDismissCompletion)completion {
    __weak YSProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong YSProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            // Stop timer
            strongSelf.graceTimer = nil;
            
            // Post notification to inform user
            [[NSNotificationCenter defaultCenter] postNotificationName:YSProgressHUDWillDisappearNotification
                                                                object:nil
                                                              userInfo:[strongSelf notificationUserInfo]];
            
            // Reset activity count
            strongSelf.activityCount = 0;
            
            __block void (^animationsBlock)(void) = ^{
                // Shrink HUD a little to make a nice disappear animation
                strongSelf.hudView.transform = CGAffineTransformScale(strongSelf.hudView.transform, 1/1.3f, 1/1.3f);
                
                // Fade out all effects (colors, blur, etc.)
                [strongSelf fadeOutEffects];
            };
            
            __block void (^completionBlock)(void) = ^{
                // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between e.g. due to a new show
                if(self.backgroundView.alpha == 0.0f){
                    // Clean up view hierarchy (overlays)
                    [strongSelf.controlView removeFromSuperview];
                    [strongSelf.backgroundView removeFromSuperview];
                    [strongSelf.hudView removeFromSuperview];
                    [strongSelf removeFromSuperview];
                    
                    // Reset progress and cancel any running animation
                    strongSelf.progress = YSProgressHUDUndefinedProgress;
                    [strongSelf cancelRingLayerAnimation];
                    [strongSelf cancelIndefiniteAnimatedViewAnimation];
                    
                    // Remove observer <=> we do not have to handle orientation changes etc.
                    [[NSNotificationCenter defaultCenter] removeObserver:strongSelf];
                    
                    // Post notification to inform user
                    [[NSNotificationCenter defaultCenter] postNotificationName:YSProgressHUDDidDisappearNotification
                                                                        object:strongSelf
                                                                      userInfo:[strongSelf notificationUserInfo]];
                    
                    // Tell the rootViewController to update the StatusBar appearance
#if !defined(YS_APP_EXTENSIONS) && TARGET_OS_IOS
                    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                    [rootController setNeedsStatusBarAppearanceUpdate];
#endif
                    
                    // Run an (optional) completionHandler
                    if (completion) {
                        completion();
                    }
                }
            };
            
            // UIViewAnimationOptionBeginFromCurrentState AND a delay doesn't always work as expected
            // When UIViewAnimationOptionBeginFromCurrentState is set, animateWithDuration: evaluates the current
            // values to check if an animation is necessary. The evaluation happens at function call time and not
            // after the delay => the animation is sometimes skipped. Therefore we delay using dispatch_after.
            
            dispatch_time_t dipatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
            dispatch_after(dipatchTime, dispatch_get_main_queue(), ^{
                if (strongSelf.fadeOutAnimationDuration > 0) {
                    // Animate appearance
                    [UIView animateWithDuration:strongSelf.fadeOutAnimationDuration
                                          delay:0
                                        options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^{
                                         animationsBlock();
                                     } completion:^(BOOL finished) {
                                         completionBlock();
                                     }];
                } else {
                    animationsBlock();
                    completionBlock();
                }
            });
            
            // Inform iOS to redraw the view hierarchy
            [strongSelf setNeedsDisplay];
        }
    }];
}


#pragma mark - Ring progress animation

- (UIView*)indefiniteAnimatedView {
    // Get the correct spinner for defaultAnimationType
    if(self.defaultAnimationType == YSProgressHUDAnimationTypeFlat){
        // Check if spinner exists and is an object of different class
        if(_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[YSIndefiniteAnimatedView class]]){
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        
        if(!_indefiniteAnimatedView){
            _indefiniteAnimatedView = [[YSIndefiniteAnimatedView alloc] initWithFrame:CGRectZero];
        }
        
        // Update styling
        YSIndefiniteAnimatedView *indefiniteAnimatedView = (YSIndefiniteAnimatedView*)_indefiniteAnimatedView;
        indefiniteAnimatedView.strokeColor = self.foregroundColorForStyle;
        indefiniteAnimatedView.strokeThickness = self.ringThickness;
        indefiniteAnimatedView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    } else {
        // Check if spinner exists and is an object of different class
        if(_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[UIActivityIndicatorView class]]){
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        
        if(!_indefiniteAnimatedView){
            _indefiniteAnimatedView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        
        // Update styling
        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView*)_indefiniteAnimatedView;
        activityIndicatorView.color = self.foregroundColorForStyle;
    }
    [_indefiniteAnimatedView sizeToFit];
    
    return _indefiniteAnimatedView;
}

- (YSProgressAnimatedView*)ringView {
    if(!_ringView) {
        _ringView = [[YSProgressAnimatedView alloc] initWithFrame:CGRectZero];
    }
    
    // Update styling
    _ringView.strokeColor = self.foregroundColorForStyle;
    _ringView.strokeThickness = self.ringThickness;
    _ringView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    
    return _ringView;
}

- (YSProgressAnimatedView*)backgroundRingView {
    if(!_backgroundRingView) {
        _backgroundRingView = [[YSProgressAnimatedView alloc] initWithFrame:CGRectZero];
        _backgroundRingView.strokeEnd = 1.0f;
    }
    
    // Update styling
    _backgroundRingView.strokeColor = [self.foregroundColorForStyle colorWithAlphaComponent:0.1f];
    _backgroundRingView.strokeThickness = self.ringThickness;
    _backgroundRingView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    
    return _backgroundRingView;
}

- (void)cancelRingLayerAnimation {
    // Animate value update, stop animation
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self.hudView.layer removeAllAnimations];
    self.ringView.strokeEnd = 0.0f;
    
    [CATransaction commit];
    
    // Remove from view
    [self.ringView removeFromSuperview];
    [self.backgroundRingView removeFromSuperview];
}

- (void)cancelIndefiniteAnimatedViewAnimation {
    // Stop animation
    if([self.indefiniteAnimatedView respondsToSelector:@selector(stopAnimating)]) {
        [(id)self.indefiniteAnimatedView stopAnimating];
    }
    // Remove from view
    [self.indefiniteAnimatedView removeFromSuperview];
}


#pragma mark - Utilities

+ (BOOL)isVisible {
    // Checking one alpha value is sufficient as they are all the same
    return [self sharedView].backgroundView.alpha > 0.0f;
}


#pragma mark - Getters

+ (NSTimeInterval)displayDurationForString:(NSString*)string {
    CGFloat minimum = MAX((CGFloat)string.length * 0.06 + 0.5, [self sharedView].minimumDismissTimeInterval);
    return MIN(minimum, [self sharedView].maximumDismissTimeInterval);
}

- (UIColor*)foregroundColorForStyle {
    if(self.defaultStyle == YSProgressHUDStyleLight) {
        return [UIColor blackColor];
    } else if(self.defaultStyle == YSProgressHUDStyleDark) {
        return [UIColor whiteColor];
    } else {
        return self.foregroundColor;
    }
}

- (UIColor*)backgroundColorForStyle {
    if(self.defaultStyle == YSProgressHUDStyleLight) {
        return [UIColor whiteColor];
    } else if(self.defaultStyle == YSProgressHUDStyleDark) {
        return [UIColor blackColor];
    } else {
        return self.backgroundColor;
    }
}

- (UIControl*)controlView {
    if(!_controlView) {
        _controlView = [UIControl new];
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controlView.backgroundColor = [UIColor clearColor];
        _controlView.userInteractionEnabled = YES;
        [_controlView addTarget:self action:@selector(controlViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    
    // Update frames
#if !defined(YS_APP_EXTENSIONS)
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _controlView.frame = windowBounds;
#else
    _controlView.frame = [UIScreen mainScreen].bounds;
#endif
    
    return _controlView;
}

-(UIView *)backgroundView {
    if(!_backgroundView){
        _backgroundView = [UIView new];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    if(!_backgroundView.superview){
        [self insertSubview:_backgroundView belowSubview:self.hudView];
    }
    
    // Update styling
    if(self.defaultMaskType == YSProgressHUDMaskTypeGradient){
        if(!_backgroundRadialGradientLayer){
            _backgroundRadialGradientLayer = [YSRadialGradientLayer layer];
        }
        if(!_backgroundRadialGradientLayer.superlayer){
            [_backgroundView.layer insertSublayer:_backgroundRadialGradientLayer atIndex:0];
        }
        _backgroundView.backgroundColor = [UIColor clearColor];
    } else {
        if(_backgroundRadialGradientLayer && _backgroundRadialGradientLayer.superlayer){
            [_backgroundRadialGradientLayer removeFromSuperlayer];
        }
        if(self.defaultMaskType == YSProgressHUDMaskTypeBlack){
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        } else if(self.defaultMaskType == YSProgressHUDMaskTypeCustom){
            _backgroundView.backgroundColor = self.backgroundLayerColor;
        } else {
            _backgroundView.backgroundColor = [UIColor clearColor];
        }
    }

    // Update frame
    if(_backgroundView){
        _backgroundView.frame = self.bounds;
    }
    if(_backgroundRadialGradientLayer){
        _backgroundRadialGradientLayer.frame = self.bounds;
        
        // Calculate the new center of the gradient, it may change if keyboard is visible
        CGPoint gradientCenter = self.center;
        gradientCenter.y = (self.bounds.size.height - self.visibleKeyboardHeight)/2;
        _backgroundRadialGradientLayer.gradientCenter = gradientCenter;
        [_backgroundRadialGradientLayer setNeedsDisplay];
    }
    
    return _backgroundView;
}
- (UIVisualEffectView*)hudView {
    if(!_hudView) {
        _hudView = [UIVisualEffectView new];
        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    if(!_hudView.superview) {
        [self addSubview:_hudView];
    }
    
    // Update styling
    _hudView.layer.cornerRadius = self.cornerRadius;
    
    return _hudView;
}

- (UILabel*)statusLabel {
    if(!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _statusLabel.numberOfLines = 0;
    }
    if(!_statusLabel.superview) {
      [self.hudView.contentView addSubview:_statusLabel];
    }
    
    // Update styling
    _statusLabel.textColor = self.foregroundColorForStyle;
    _statusLabel.font = self.font;

    return _statusLabel;
}

- (UIImageView*)imageView {
    if(_imageView && !CGSizeEqualToSize(_imageView.bounds.size, _imageViewSize)) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _imageViewSize.width, _imageViewSize.height)];
    }
    if(!_imageView.superview) {
        [self.hudView.contentView addSubview:_imageView];
    }
    
    return _imageView;
}


#pragma mark - Helper
    
- (CGFloat)visibleKeyboardHeight {
#if !defined(YS_APP_EXTENSIONS)
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in UIApplication.sharedApplication.windows) {
        if(![testWindow.class isEqual:UIWindow.class]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in keyboardWindow.subviews) {
        NSString *viewName = NSStringFromClass(possibleKeyboard.class);
        if([viewName hasPrefix:@"UI"]){
            if([viewName hasSuffix:@"PeripheralHostView"] || [viewName hasSuffix:@"Keyboard"]){
                return CGRectGetHeight(possibleKeyboard.bounds);
            } else if ([viewName hasSuffix:@"InputSetContainerView"]){
                for (__strong UIView *possibleKeyboardSubview in possibleKeyboard.subviews) {
                    viewName = NSStringFromClass(possibleKeyboardSubview.class);
                    if([viewName hasPrefix:@"UI"] && [viewName hasSuffix:@"InputSetHostView"]) {
                        CGRect convertedRect = [possibleKeyboard convertRect:possibleKeyboardSubview.frame toView:self];
                        CGRect intersectedRect = CGRectIntersection(convertedRect, self.bounds);
                        if (!CGRectIsNull(intersectedRect)) {
                            return CGRectGetHeight(intersectedRect);
                        }
                    }
                }
            }
        }
    }
#endif
    return 0;
}
    
- (UIWindow *)frontWindow {
#if !defined(YS_APP_EXTENSIONS)
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= self.maxSupportedWindowLevel);
        BOOL windowKeyWindow = window.isKeyWindow;
			
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
#endif
    return nil;
}
    
- (void)fadeInEffects {
    if(self.defaultStyle != YSProgressHUDStyleCustom) {
        // Add blur effect
        UIBlurEffectStyle blurEffectStyle = self.defaultStyle == YSProgressHUDStyleDark ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
        self.hudView.effect = blurEffect;
        
        // We omit UIVibrancy effect and use a suitable background color as an alternative.
        // This will make everything more readable. See the following for details:
        // https://www.omnigroup.com/developer/how-to-make-text-in-a-uivisualeffectview-readable-on-any-background
        
        self.hudView.backgroundColor = [self.backgroundColorForStyle colorWithAlphaComponent:0.6f];
    } else {
        self.hudView.backgroundColor =  self.backgroundColorForStyle;
    }

    // Fade in views
    self.backgroundView.alpha = 1.0f;
    
    self.imageView.alpha = 1.0f;
    self.statusLabel.alpha = 1.0f;
    self.indefiniteAnimatedView.alpha = 1.0f;
    self.ringView.alpha = self.backgroundRingView.alpha = 1.0f;
}

- (void)fadeOutEffects
{
    if(self.defaultStyle != YSProgressHUDStyleCustom) {
        // Remove blur effect
        self.hudView.effect = nil;
    }

    // Remove background color
    self.hudView.backgroundColor = [UIColor clearColor];
    
    // Fade out views
    self.backgroundView.alpha = 0.0f;
    
    self.imageView.alpha = 0.0f;
    self.statusLabel.alpha = 0.0f;
    self.indefiniteAnimatedView.alpha = 0.0f;
    self.ringView.alpha = self.backgroundRingView.alpha = 0.0f;
}

#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UINotificationFeedbackGenerator *)hapticGenerator NS_AVAILABLE_IOS(10_0) {
	// Only return if haptics are enabled
	if(!self.hapticsEnabled) {
		return nil;
	}
	
	if(!_hapticGenerator) {
		_hapticGenerator = [[UINotificationFeedbackGenerator alloc] init];
	}
	return _hapticGenerator;
}
#endif

    
#pragma mark - UIAppearance Setters

- (void)setDefaultStyle:(YSProgressHUDStyle)style {
    if (!_isInitializing) _defaultStyle = style;
}

- (void)setDefaultMaskType:(YSProgressHUDMaskType)maskType {
    if (!_isInitializing) _defaultMaskType = maskType;
}

- (void)setDefaultAnimationType:(YSProgressHUDAnimationType)animationType {
    if (!_isInitializing) _defaultAnimationType = animationType;
}

- (void)setContainerView:(UIView *)containerView {
    if (!_isInitializing) _containerView = containerView;
}

- (void)setMinimumSize:(CGSize)minimumSize {
    if (!_isInitializing) _minimumSize = minimumSize;
}

- (void)setRingThickness:(CGFloat)ringThickness {
    if (!_isInitializing) _ringThickness = ringThickness;
}

- (void)setRingRadius:(CGFloat)ringRadius {
    if (!_isInitializing) _ringRadius = ringRadius;
}

- (void)setRingNoTextRadius:(CGFloat)ringNoTextRadius {
    if (!_isInitializing) _ringNoTextRadius = ringNoTextRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (!_isInitializing) _cornerRadius = cornerRadius;
}

- (void)setFont:(UIFont*)font {
    if (!_isInitializing) _font = font;
}

- (void)setForegroundColor:(UIColor*)color {
    if (!_isInitializing) _foregroundColor = color;
}

- (void)setBackgroundColor:(UIColor*)color {
    if (!_isInitializing) _backgroundColor = color;
}

- (void)setBackgroundLayerColor:(UIColor*)color {
    if (!_isInitializing) _backgroundLayerColor = color;
}

- (void)setShouldTintImages:(BOOL)shouldTintImages {
    if (!_isInitializing) _shouldTintImages = shouldTintImages;
}

- (void)setInfoImage:(UIImage*)image {
    if (!_isInitializing) _infoImage = image;
}

- (void)setSuccessImage:(UIImage*)image {
    if (!_isInitializing) _successImage = image;
}

- (void)setErrorImage:(UIImage*)image {
    if (!_isInitializing) _errorImage = image;
}

- (void)setViewForExtension:(UIView*)view {
    if (!_isInitializing) _viewForExtension = view;
}

- (void)setOffsetFromCenter:(UIOffset)offset {
    if (!_isInitializing) _offsetFromCenter = offset;
}

- (void)setMinimumDismissTimeInterval:(NSTimeInterval)minimumDismissTimeInterval {
    if (!_isInitializing) _minimumDismissTimeInterval = minimumDismissTimeInterval;
}

- (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    if (!_isInitializing) _fadeInAnimationDuration = duration;
}

- (void)setFadeOutAnimationDuration:(NSTimeInterval)duration {
    if (!_isInitializing) _fadeOutAnimationDuration = duration;
}

- (void)setMaxSupportedWindowLevel:(UIWindowLevel)maxSupportedWindowLevel {
    if (!_isInitializing) _maxSupportedWindowLevel = maxSupportedWindowLevel;
}

@end
