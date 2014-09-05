//
//  NDAMenuGestureRecognizer.m
//  TooWheels
//
//  Created by mriddi on 29.08.14.
//  Copyright (c) 2014 Пользователь. All rights reserved.
//

#import "NDAMenuGestureRecognizer.h"

@implementation NDAMenuGestureRecognizer

const CGFloat radius = 100.f;
@synthesize menuCenter;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    menuCenter = [[touches anyObject] locationInView:self.view];
    if (![(id <NDAMenuGestureRecognizerDelegate>)self.delegate gestureRecognizerShouldMove:self]){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [(id <NDAMenuGestureRecognizerDelegate>) self.delegate moviedToSector: [self calculatesectorWithTouches:touches]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [(id <NDAMenuGestureRecognizerDelegate>) self.delegate finishedInSector: [self calculatesectorWithTouches:touches]];
}

- (Byte) calculatesectorWithTouches: (NSSet *) touches{
    Byte sector;
    CGFloat angle = angleBetweenLinesInDegrees(menuCenter, CGPointMake(menuCenter.x+radius, menuCenter.y), menuCenter, [[touches anyObject] locationInView: self.view]);
    if (angle <= - 45){
        sector = Up;
    }else if (angle > - 45 && angle <= 45){
        sector = Right;
    }else if (angle > 45 && angle <= 135){
        sector = Down;
    }else
    {
        sector = Left;
    }
    return sector;
}

@end
