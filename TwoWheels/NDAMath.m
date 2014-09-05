//
//  NDAMath.m
//  TooWheels
//
//  Created by mriddi on 28.08.14.
//  Copyright (c) 2014 Пользователь. All rights reserved.
//

#import "NDAMath.h"

@implementation NDAMath

CGFloat distanceBetweenPoints(CGPoint point1, CGPoint point2)
{
    CGFloat dx = point1.x - point2.x;
    CGFloat dy = point1.y - point2.y;
    return sqrt(dx*dx + dy*dy);
}

CGFloat angleBetweenLinesInDegrees(CGPoint beginLineA,CGPoint endLineA, CGPoint beginLineB, CGPoint endLineB)
{
    CGFloat a = endLineA.x - beginLineA.x;
    CGFloat b = endLineA.y - beginLineA.y;
    CGFloat c = endLineB.x - beginLineB.x;
    CGFloat d = endLineB.y - beginLineB.y;
    
    CGFloat atanA = atan2(a, b);
    CGFloat atanB = atan2(c, d);
    
    return (atanA - atanB) * 180 / M_PI;
}

@end
