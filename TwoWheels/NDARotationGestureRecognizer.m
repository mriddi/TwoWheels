//
//  CircularGestureRecognizer.m
//

#import "NDARotationGestureRecognizer.h"


@implementation NDARotationGestureRecognizer


- (void) setMidPoint: (CGPoint) _midPoint
            innerRadius: (CGFloat) _innerRadius
            outerRadius: (CGFloat) _outerRadius
    classInstanceMarker: (NSString *) _classInstanceMarker
{
    midPoint    = _midPoint;
    innerRadius = _innerRadius;
    outerRadius = _outerRadius;
    classInstanceMarker=_classInstanceMarker;
}

#pragma mark - UIGestureRecognizer methods implementation

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (![(id <NDARotationGestureRecognizerDelegate>)self.delegate gestureRecognizerShouldMove:self]){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint  = [[touches anyObject] locationInView: self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView: self.view];
    // make sure the new point is within the area
    CGFloat distance = distanceBetweenPoints(midPoint, nowPoint);
    if ( innerRadius <= distance && distance <= outerRadius)
    {
        // calculate rotation angle between two points
        CGFloat angle = angleBetweenLinesInDegrees(midPoint, prevPoint, midPoint, nowPoint);

        // fix value, if the 12 o'clock position is between prevPoint and nowPoint
        if (angle > 180)
        {
            angle -= 360;
        }
        else if (angle < -180)
        {
            angle += 360;
        }

        // sum up single steps
        cumulatedAngle += angle;

        // call delegate
        [(id <NDARotationGestureRecognizerDelegate> )self.delegate willRotateAndConvert:angle:classInstanceMarker];
    }
    else
    {
        // finger moved outside the area
        self.state = UIGestureRecognizerStateFailed;
    }
} 

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [super touchesEnded:touches withEvent:event];
    if (self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateRecognized;
    }
    else
    {
        self.state = UIGestureRecognizerStateFailed;
    }
    cumulatedAngle = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateFailed;
    cumulatedAngle = 0;
}

- (void)reset
{
    [super reset];
    cumulatedAngle = 0;
}

@end
