//
//  CircularGestureViewController.m
//

#import <QuartzCore/QuartzCore.h>
#import "NDAMainViewController.h"


@implementation NDAMainViewController

@synthesize cursor;
@synthesize leftWheel;
@synthesize rightWheel;
@synthesize paintingImageView;
@synthesize menuView;

#pragma mark - View lifecycle

-(BOOL) prefersStatusBarHidden{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-  (BOOL)shouldAutorotate {
    return YES;
}

-  (void)viewDidAppear:(BOOL)animated{
    bufferAngleLeft = 0;
    bufferAngleRight = 0;
    myScreenshoot=nil;
    eracerSet=NO;
    screenBounds=self.view.bounds;
    centerPoint = CGPointMake(screenBounds.size.width/2,screenBounds.size.height/2);
    drawToPoint = centerPoint;
    lastPoint= centerPoint;
    [self setCursorPosition:centerPoint];
    gestureRecognizerLeft = [[NDARotationGestureRecognizer alloc] init];
    gestureRecognizerRight = [[NDARotationGestureRecognizer alloc] init];
    gestureRecognizerMenu = [[NDAMenuGestureRecognizer alloc]init];
    gestureRecognizerLeft.delegate=self;
    gestureRecognizerRight.delegate=self;
    gestureRecognizerMenu.delegate=self;
    [self.view addGestureRecognizer: gestureRecognizerLeft];
    [self.view addGestureRecognizer: gestureRecognizerRight];
    [self.view addGestureRecognizer:gestureRecognizerMenu];
    
    // Show help
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey: @"launches"]]){
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"launches"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        

        _helpImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Help.png"]];
        _helpImageView.frame = self.view.bounds;
        [self.view addSubview:_helpImageView];
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self.view addGestureRecognizer:tapGestureRecognizer];
        
        gestureRecognizerLeft.enabled = NO;
        gestureRecognizerRight.enabled = NO;
        gestureRecognizerMenu.enabled = NO;
        cursor.hidden = YES;
    }else{
        cursorTimer=[NSTimer scheduledTimerWithTimeInterval:cursorHideShowTime target:self selector:@selector(cursorHideShow) userInfo:nil repeats:YES];
    }
}

#pragma mark - CircularGestureRecognizerDelegate protocol methods

-(void) onTap: (UITapGestureRecognizer*) tapGestureRecognizer {
    [self.helpImageView removeFromSuperview];
    gestureRecognizerLeft.enabled = YES;
    gestureRecognizerRight.enabled = YES;
    gestureRecognizerMenu.enabled = YES;
    tapGestureRecognizer.enabled = NO;
    cursor.hidden = NO;
    cursorTimer=[NSTimer scheduledTimerWithTimeInterval:cursorHideShowTime target:self selector:@selector(cursorHideShow) userInfo:nil repeats:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == gestureRecognizerLeft) {
        if ([touch locationInView:self.view].x < screenBounds.size.width/2) {
            return YES;
        }
    } else if (gestureRecognizer == gestureRecognizerRight){
        if ([touch locationInView:self.view].x >= screenBounds.size.width/2) {
            return YES;
        }
    } else if(gestureRecognizer == gestureRecognizerMenu){
        return YES;
    }
    
    return NO;
}

- (BOOL)gestureRecognizerShouldMove:(UIGestureRecognizer *)gestureRecognizer{
    
    if (gestureRecognizerMenu.numberOfTouches == 1) {
        if (gestureRecognizer == gestureRecognizerLeft) {
            [self startLeft];
            return YES;
        }
        if (gestureRecognizer == gestureRecognizerRight) {
            [self startRight];
            return YES;
        }
        if (gestureRecognizer == gestureRecognizerMenu) {
            return NO;
        }
    }
    
    if (gestureRecognizerMenu.numberOfTouches == 2){
        CGPoint touchA = [gestureRecognizerMenu locationOfTouch:0 inView:self.view];
        CGPoint touchB = [gestureRecognizerMenu locationOfTouch:1 inView:self.view];
        CGFloat distance = distanceBetweenPoints(touchA, touchB);
        
        NSLog(@"%f", distance);
        
        if (distance < distanceTrigger) {
            if (gestureRecognizer == gestureRecognizerLeft) {
                return NO;
            }
            if (gestureRecognizer == gestureRecognizerRight) {
                return NO;
            }
            if (gestureRecognizer == gestureRecognizerMenu) {
                return YES;
            }
        } else {
            if (gestureRecognizer == gestureRecognizerLeft) {
                [self startLeft];
                return YES;
            }
            if (gestureRecognizer == gestureRecognizerRight) {
                [self startRight];
                return YES;
            }
            if (gestureRecognizer == gestureRecognizerMenu) {
                return NO;
            }
        }
    }
    return NO;
}

- (void) startLeft {
    leftWheel.center = CGPointMake([gestureRecognizerLeft locationInView:self.view].x- leftWheel.bounds.size.width/2, [gestureRecognizerLeft locationInView:self.view].y);
    leftWheel.transform = CGAffineTransformMakeRotation(0);
    [gestureRecognizerLeft setMidPoint: leftWheel.center
                           innerRadius: leftWheel.frame.size.width/2 / outToInRadius
                           outerRadius: leftWheel.frame.size.width/2 + outRadiusExtender
                   classInstanceMarker: @"Left"];
}

-(void) startRight{
    rightWheel.center = CGPointMake([gestureRecognizerRight locationInView:self.view].x- rightWheel.bounds.size.width/2, [gestureRecognizerRight locationInView:self.view].y);
    rightWheel.transform = CGAffineTransformMakeRotation(0);
    [gestureRecognizerRight setMidPoint: rightWheel.center
                            innerRadius: rightWheel.frame.size.width/2 / outToInRadius
                            outerRadius: rightWheel.frame.size.width/2 + outRadiusExtender
                    classInstanceMarker: @"Right"];
}

- (void) moviedToSector:(Byte)sector{
    menuView.center = gestureRecognizerMenu.menuCenter;
    if (!eracerSet) {
        if (sector == Center)
            [menuView setImage:[UIImage imageNamed:@"eracerEmpty.png"]];
        if (sector == Up)
            [menuView setImage:[UIImage imageNamed:@"eracerEracer.png"]];
        if (sector == Right)
            [menuView setImage:[UIImage imageNamed:@"eracerSave.png"]];
        if (sector == Down)
            [menuView setImage:[UIImage imageNamed:@"eracerClear.png"]];
        if (sector == Left)
            [menuView setImage:[UIImage imageNamed:@"eracerLoad.png"]];
    } else{
        if (sector == Center)
            [menuView setImage:[UIImage imageNamed:@"penPen.png"]];
        if (sector == Up)
            [menuView setImage:[UIImage imageNamed:@"penEracer.png"]];
        if (sector == Right)
            [menuView setImage:[UIImage imageNamed:@"penSave.png"]];
        if (sector == Down)
            [menuView setImage:[UIImage imageNamed:@"penClear.png"]];
        if (sector == Left)
            [menuView setImage:[UIImage imageNamed:@"penLoad.png"]];
    }
    
}

-(void) finishedInSector:(Byte)sector{
    [menuView setImage:nil];
    if (sector == Up)
        [self eracer];
    if (sector == Right)
        [self savePicture];
    if (sector == Down)
        [self clearScreen];
    if (sector == Left)
        [self loadPicture];
}

- (void) willRotateAndConvert: (CGFloat) angle :(NSString*) classInstanceTag
{
    if([classInstanceTag isEqualToString:@"Right"]) {
        rightWheel.transform = CGAffineTransformRotate(rightWheel.transform,angle *  M_PI / 180);
        bufferAngleRight+= angle;
        if (bufferAngleRight>=degreeInPoint) {
            bufferAngleRight=0;
            drawToPoint=[self checkForScreenOutDown:drawToPoint];
        } else if (bufferAngleRight<=-degreeInPoint){
            bufferAngleRight=0;
            drawToPoint=[self checkForScreenOutUp:drawToPoint];
        }}
    else{
        leftWheel.transform = CGAffineTransformRotate(leftWheel.transform,angle *  M_PI / 180);
        bufferAngleLeft+= angle;
        if (bufferAngleLeft>=degreeInPoint) {
            bufferAngleLeft=0;
            drawToPoint=[self checkForScreenOutRight:drawToPoint];
        } else if (bufferAngleLeft<=-degreeInPoint){
            bufferAngleLeft=0;
            drawToPoint=[self checkForScreenOutLeft:drawToPoint];
        }}
    [self drawToPoint:drawToPoint];
    [self setCursorPosition:drawToPoint];
}

#pragma mark - Painting methods

-(void) cursorHideShow{
    if (cursor.hidden==YES)
        cursor.hidden=NO;
    else
        cursor.hidden=YES;
}

-(void) setCursorPosition : (CGPoint) currentPoint{
    cursor.frame = CGRectMake(currentPoint.x-cursor.frame.size.width/2, currentPoint.y-cursor.frame.size.height/2, cursor.frame.size.width, cursor.frame.size.height);
}

-(void) drawToPoint : (CGPoint) point{
    UIGraphicsBeginImageContext(CGSizeMake(568, 320));
    [paintingImageView.image drawInRect:(CGRect){.origin.x = 0.0f, .origin.y = 0.0f, 568, 320}];
    
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point.x, point.y);
    
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), moveFactor );
    if (eracerSet) 
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.886 , 0.917 , 0.776 , 1.0);
    else
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    paintingImageView.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    lastPoint=point;
}

#pragma mark - Hidding/showing controllers methods

-(void) hideControllers {
    [UIView animateWithDuration:0.5 animations:^{
        leftWheel.alpha = 0;
        rightWheel.alpha = 0;
    }];
}

-(void) showControllers {
    [UIView animateWithDuration:0.5 animations:^{
        leftWheel.alpha = 1;
        rightWheel.alpha = 1;
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self showControllers];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    [controllersTimer invalidate];
    controllersTimer=[NSTimer scheduledTimerWithTimeInterval:controllersHideShowTime target:self selector:@selector(hideControllers) userInfo:nil repeats:NO];
}

#pragma mark - Menu methods


- (void) clearScreen {
    bufferAngleLeft = 0;
    bufferAngleRight = 0;
    lastPoint= centerPoint;
    drawToPoint = centerPoint;
    paintingImageView.image=nil;
    [UIView animateWithDuration:0.5 animations:^{[self setCursorPosition:centerPoint];}];
}

- (void) savePicture {
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    myScreenshoot=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(myScreenshoot, nil, nil, nil );
    
    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/camera_shutter_burst.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained  CFURLRef)fileURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
    
    UIView * flash = [[UIView alloc] initWithFrame:self.view.bounds];
    flash.backgroundColor = [UIColor whiteColor];
    flash.alpha = 0;
    [self.view addSubview:flash];
    [UIView animateWithDuration: .3
                     animations:^{flash.alpha = 1;}
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:.3
                                          animations:^{flash.alpha = 0;}
                                          completion:^(BOOL finished){[flash removeFromSuperview];}];
                     }];
}

- (void) loadPicture {
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerLibrary.delegate = self;
    [self presentViewController:pickerLibrary animated:YES completion:nil];
}

- (void) eracer {
    eracerSet = !eracerSet;
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    paintingImageView.image = image;
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Helper methods

-(CGPoint) checkForScreenOutRight:(CGPoint) checkPoint{
    if (checkPoint.x+1>screenBounds.size.width-moveFactor) {
        return checkPoint;
    } else {
        return checkPoint=CGPointMake(checkPoint.x+moveFactor, checkPoint.y);
    }
}

-(CGPoint) checkForScreenOutLeft:(CGPoint) checkPoint{
    if (checkPoint.x-1<moveFactor) {
        return checkPoint;
    } else {
        return checkPoint=CGPointMake(checkPoint.x-moveFactor, checkPoint.y);
    }
}

-(CGPoint) checkForScreenOutDown:(CGPoint) checkPoint{
    if (checkPoint.y+1>screenBounds.size.height-moveFactor) {
        return checkPoint;
    } else {
        return checkPoint=CGPointMake(checkPoint.x, checkPoint.y+moveFactor);
    }
}

-(CGPoint) checkForScreenOutUp:(CGPoint) checkPoint{
    if (checkPoint.y+1<moveFactor) {
        return checkPoint;
    } else {
        return checkPoint=CGPointMake(checkPoint.x, checkPoint.y-moveFactor);
    }
}

@end