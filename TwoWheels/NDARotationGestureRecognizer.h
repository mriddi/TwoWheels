//
//  CircularGestureRecognizer.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "NDAMath.h"
@class NDARotationGestureRecognizer;

@protocol NDARotationGestureRecognizerDelegate <UIGestureRecognizerDelegate>
@required
- (void) willRotateAndConvert: (CGFloat) angle : (NDARotationGestureRecognizer *) gestureRecognizer;
- (BOOL) gestureRecognizerShouldMove:(UIGestureRecognizer *)gestureRecognizer;
@end

@interface NDARotationGestureRecognizer : UIGestureRecognizer
{
    CGPoint midPoint;
    CGFloat innerRadius;
    CGFloat outerRadius;
    CGFloat cumulatedAngle;
}


- (void) setMidPoint: (CGPoint) midPoint
            innerRadius: (CGFloat) innerRadius
            outerRadius: (CGFloat) outerRadius;

- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end
