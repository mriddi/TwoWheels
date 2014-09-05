//
//  NDAMenuGestureRecognizer.h
//  TooWheels
//
//  Created by mriddi on 29.08.14.
//  Copyright (c) 2014 Пользователь. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "NDAMath.h"

@protocol NDAMenuGestureRecognizerDelegate <UIGestureRecognizerDelegate>
@required
- (void) moviedToSector: (Byte) sector;
- (void) finishedInSector: (Byte) sector;
- (BOOL) gestureRecognizerShouldMove:(UIGestureRecognizer *)gestureRecognizer;
@end

typedef NS_ENUM(NSInteger, MenuSector) {
    Center,Up,Right,Down,Left
};

@interface NDAMenuGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) CGPoint menuCenter;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
