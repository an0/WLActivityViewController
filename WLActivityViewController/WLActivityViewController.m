//
//  WLActivityViewController.m
//  WLActivityViewController
//
//  Created by Ling Wang on 3/17/15.
//  Copyright (c) 2015 Moke. All rights reserved.
//

#import "WLActivityViewController.h"

@interface UIView (AnimationRemoval)

- (void)removeAllAnimations;

@end

@implementation UIView (AnimationRemoval)

- (void)removeAllAnimations {
    [self.layer removeAllAnimations];
    for (UIView *subview in self.subviews) {
        [subview removeAllAnimations];
    }
}

@end

@interface ActivityViewControllerTitleView : UIView {
    UILabel *_label;
    CAShapeLayer *_mask;
}

@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) CGFloat cornerRadius;

@end

@implementation ActivityViewControllerTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        _mask = [CAShapeLayer new];
        self.layer.mask = _mask;
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        effectView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:effectView];

        _label = [UILabel new];
        _label.font = [UIFont systemFontOfSize:13];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        _label.numberOfLines = 2;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_label];
        
        NSDictionary *viewDict = NSDictionaryOfVariableBindings(effectView, _label);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[effectView]|" options:kNilOptions metrics:nil views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[effectView]|" options:kNilOptions metrics:nil views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_label]-10-|" options:kNilOptions metrics:nil views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_label]-10-|" options:kNilOptions metrics:nil views:viewDict]];
    }
    return self;
}

- (NSString *)title {
    return _label.text;
}

- (void)setTitle:(NSString *)title {
    _label.text = title;
}

- (CGSize)intrinsicContentSize {
    CGSize size = _label.intrinsicContentSize;
    size.width += 2 * 10;
    size.height += 2 * 10;
    return size;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    NSString *referenceAnimationKey = self.layer.animationKeys.firstObject;
    if (referenceAnimationKey != nil) {
        [CATransaction begin];
        CAAnimation *referenceAnimation = [self.layer animationForKey:referenceAnimationKey];
        CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        maskAnimation.fromValue = (__bridge id _Nullable)(_mask.path);
        maskAnimation.duration = referenceAnimation.duration;
        maskAnimation.timingFunction = referenceAnimation.timingFunction;
        [_mask addAnimation:maskAnimation forKey:@"path"];
        [CATransaction commit];
    }
    _mask.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius].CGPath;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
    _mask.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius].CGPath;
}

@end

@interface WLActivityViewController () {
    ActivityViewControllerTitleView *_titleView;
}

@end

@implementation WLActivityViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 
    if (self.title.length > 0 && _titleView == nil) {
        [self showTitleView:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (animated) {
        [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
            _titleView.alpha = 0;
        }];
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    if (self.isViewLoaded) {
        if (self.title.length > 0 && _titleView == nil) {
            [self showTitleView:YES];
        } else if (self.title.length == 0 && _titleView != nil) {
            [self hideTitleView:YES];
        } else {
            _titleView.title = title;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view.window layoutIfNeeded];
            }];
        }
    }
}

- (void)showTitleView:(BOOL)animated {
    UIView *transitionView = self.view.superview;
    UIView *popoverView;
    while (transitionView.superview != nil && ![transitionView.superview isKindOfClass:[UIWindow class]]) {
        if (self.popoverPresentationController != nil) {
            // Find popover view.
            if ([NSStringFromClass([transitionView class]) containsString:@"UIPopoverView"]) {
                popoverView = transitionView;
            }
        }
        transitionView = transitionView.superview;
    }
    UIView *containerView;
    if (popoverView != nil) {
        containerView = popoverView;
    } else {
        containerView = self.view.subviews.firstObject;
        // For parallax, it must be embedded at least this deep.
        containerView = containerView.subviews.lastObject;
    }
    UIView *contentView = containerView.subviews.lastObject;
    _titleView = [[ActivityViewControllerTitleView alloc] initWithFrame:contentView.bounds];
    if (popoverView != nil) {
        _titleView.cornerRadius = 11;
    } else {
        _titleView.cornerRadius = 4;
    }
    _titleView.title = self.title;
    _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:_titleView];
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(_titleView, contentView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_titleView]|" options:kNilOptions metrics:nil views:viewDict]];
    if (self.popoverPresentationController != nil && self.popoverPresentationController.arrowDirection == UIPopoverArrowDirectionUp) {
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentView]-[_titleView]" options:kNilOptions metrics:nil views:viewDict]];
    } else {
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleView]-[contentView]" options:kNilOptions metrics:nil views:viewDict]];
    }
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [transitionView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:transitionView attribute:NSLayoutAttributeTop multiplier:1 constant:20]];
    [transitionView addConstraint:[NSLayoutConstraint constraintWithItem:_titleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:transitionView attribute:NSLayoutAttributeBottom multiplier:1 constant:-20]];
    
    if (animated) {
        _titleView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view.window layoutIfNeeded];
            // Do not show layout animation for _titleView, only show alpha animaiton.
            [_titleView removeAllAnimations];
            _titleView.alpha = 1;
        }];
    }
}

- (void)hideTitleView:(BOOL)animated {
    [_titleView removeFromSuperview];
    _titleView = nil;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view.window layoutIfNeeded];
        }];
    }
}

@end
