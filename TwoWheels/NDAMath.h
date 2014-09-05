//
//  NDAMath.h
//  TooWheels
//
//  Created by mriddi on 28.08.14.
//  Copyright (c) 2014 Пользователь. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDAMath : NSObject

CGFloat distanceBetweenPoints(CGPoint point1, CGPoint point2);
CGFloat angleBetweenLinesInDegrees(CGPoint beginLineA,CGPoint endLineA, CGPoint beginLineB, CGPoint endLineB);

@end
