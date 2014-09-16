//
//  BIDView.h
//  TwoWheels
//
//  Created by mriddi on 16.09.14.
//  Copyright (c) 2014 Пользователь. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDView : UIView

- (void) drawToCache;

@property CGContextRef cacheContext;
@property CGPoint lastPoint;
@property CGPoint drawToPoint;

@end
