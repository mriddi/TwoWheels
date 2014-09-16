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

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initContext:self.frame.size];
        [super setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void) initContext:(CGSize)size {
    
	int bitmapByteCount;
	int	bitmapBytesPerRow;
    
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow = (size.width * 4);
	bitmapByteCount = (bitmapBytesPerRow * size.height);
    unsigned char cacheBitmap = malloc( bitmapByteCount );
    
	_cacheContext = CGBitmapContextCreate (cacheBitmap, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
    
    CGContextSetFillColorWithColor(_cacheContext, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(_cacheContext, self.bounds);
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(_cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}

- (void) drawToCache{
    CGContextSetLineWidth(_cacheContext, 2 );
    CGContextSetRGBStrokeColor(_cacheContext, 1.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(_cacheContext);
    CGContextMoveToPoint(_cacheContext, _lastPoint.x, _lastPoint.y);
    CGContextAddLineToPoint(_cacheContext, _drawToPoint.x, _drawToPoint.y);
    CGContextStrokePath(_cacheContext);

    CGRect r1 = CGRectMake(_lastPoint.x-2, _lastPoint.y-2, 4, 4);
    CGRect r2 = CGRectMake(_drawToPoint.x-2, _drawToPoint.y-2, 4, 4);
    
    
    [self setNeedsDisplayInRect:CGRectUnion(r1, r2) ];
}

@end
