//
//  PDEmitterView.m
//  PDLiveRoom
//
//  Created by 彭懂 on 16/9/6.
//  Copyright © 2016年 彭懂. All rights reserved.
//

#import "PDEmitterView.h"

#define kScreenWidth            CGRectGetWidth([UIScreen mainScreen].bounds)
#define M_RATIO_SIZE(s) ceilf(kScreenWidth/(375.0/s))
@interface PDEmitterView ()

@property (nonatomic, strong) NSMutableArray *keepArray;
@property (nonatomic, strong) NSMutableArray *deletArray;
@property (nonatomic, assign) NSInteger zanCount;

@end

@implementation PDEmitterView

// 采用tableview的回收机制
- (NSMutableArray *)keepArray
{
    if (!_keepArray) {
        _keepArray = [[NSMutableArray alloc] init];
    }
    return _keepArray;
}

- (NSMutableArray *)deletArray
{
    if (!_deletArray) {
        _deletArray = [[NSMutableArray alloc] init];
    }
    return _deletArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.zanCount = 0;
    }
    return self;
}

- (void)sendUpEmitter
{
    _zanCount ++;
    if (_zanCount == INT_MAX) {
        _zanCount = 0;
    }
    CALayer *shipLabyer = nil;
    if (self.deletArray.count > 0) {
        shipLabyer = [self.deletArray firstObject];
        [self.deletArray removeObject:shipLabyer];
    } else {
        shipLabyer = [CALayer layer];
        shipLabyer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"live_dzax_icon"].CGImage);
        shipLabyer.contentsScale = [UIScreen mainScreen].scale;
        shipLabyer.frame = CGRectMake(self.bounds.size.width / 2.0, self.bounds.size.height, M_RATIO_SIZE(20), M_RATIO_SIZE(20));
    }
    shipLabyer.opacity = 1.0;
    [self.layer addSublayer:shipLabyer];
    [self.keepArray addObject:shipLabyer];
    
    [self animationKeyFrameWithLayer:shipLabyer];
}

- (void)animationKeyFrameWithLayer:(CALayer *)layer
{
    NSInteger with = self.bounds.size.width-M_RATIO_SIZE(5);
    NSInteger height = self.bounds.size.height;
    // 线的路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 起点
    [path moveToPoint:CGPointMake(with, height)];
    // 其他点
    [path addLineToPoint:CGPointMake(0,height - M_RATIO_SIZE(27))];
    [path addLineToPoint:CGPointMake(M_RATIO_SIZE(30),height -  M_RATIO_SIZE(50))];
    [path addLineToPoint:CGPointMake(0,height -  M_RATIO_SIZE(79))];
    [path addLineToPoint:CGPointMake(M_RATIO_SIZE(30), height - M_RATIO_SIZE(107))];
    [path addLineToPoint:CGPointMake(0, 0)];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 1.2 + (arc4random() % 6) / 10.0;
//    animation.rotationMode = kCAAnimationRotateAuto;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.path = path.CGPath;
    animation.fillMode = kCAFillModeForwards;
    
    // 缩放
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.1];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.7];
    scaleAnimation.duration = 1 + (arc4random() % 10) / 10.0;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    alphaAnimation.fromValue = @(1.0);
    alphaAnimation.toValue = @(0.0);
    alphaAnimation.duration = animation.duration-1;
    alphaAnimation.beginTime = 1.0f;// 动画延迟时间 default is 0
    alphaAnimation.autoreverses = NO;//动画结束的时候是否要按原来返回到原来的状态

//    alphaAnimation.removedOnCompletion = NO;
    alphaAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.repeatCount = 1;
    animationGroup.removedOnCompletion = NO;
    animationGroup.duration = animation.duration;
    animationGroup.fillMode = kCAFillModeForwards;
//    animationGroup.animations = @[animation, scaleAnimation, alphaAnimation];
    animationGroup.animations = @[animation, alphaAnimation];

//    animationGroup.delegate = self;
    [layer addAnimation:animationGroup forKey:[NSString stringWithFormat:@"animation%zd", _zanCount]];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *layer = [self.keepArray firstObject];
    [layer removeAllAnimations];
    [self.deletArray addObject:layer];
    [layer removeFromSuperlayer];
    [self.keepArray removeObject:layer];
}

@end
