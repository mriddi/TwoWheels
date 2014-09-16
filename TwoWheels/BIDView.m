//
//  BIDView.m
//  TwoWheels
//
//  Created by mriddi on 16.09.14.
//  Copyright (c) 2014 Пользователь. All rights reserved.
//

#import "BIDView.h"

@implementation BIDView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    NSLog(@"%@" , NSStringFromCGSize(self.frame.size));
    
    NSLog(@"%@   --   %@" ,  NSStringFromCGPoint(_drawToPoint), NSStringFromCGPoint(_lastPoint));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, 2 );
    
//    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 320, 200);
    CGContextAddLineToPoint(context, 420, 300);
    CGContextStrokePath(context);

    CGRect rectangle = CGRectMake(0, 100, 320, 100);
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, rectangle);

}


@end
