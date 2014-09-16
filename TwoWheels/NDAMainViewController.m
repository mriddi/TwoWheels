//
//  CircularGestureViewController.m
//

#import <QuartzCore/QuartzCore.h>
#import "NDAMainViewController.h"


@implementation NDAMainViewController

@synthesize cursor;
@synthesize leftWheel;
@synthesize rightWheel;
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


- (void) viewDidLoad{
    gestureRecognizerLeft = [[NDARotationGestureRecognizer alloc] init];
    gestureRecognizerRight = [[NDARotationGestureRecognizer alloc] init];
    gestureRecognizerMenu = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMenuTap:)];
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
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHelpTap:)];
        [self.view addGestureRecognizer:tapGestureRecognizer];
        
        gestureRecognizerLeft.enabled = NO;
        gestureRecognizerRight.enabled = NO;
        gestureRecognizerMenu.enabled = NO;
        cursor.hidden = YES;
    }else{
        [cursorTimer invalidate];
        cursorTimer=[NSTimer scheduledTimerWithTimeInterval:cursorHideShowTime target:self selector:@selector(cursorHideShow) userInfo:nil repeats:YES];
    }
}

-  (void)viewDidAppear:(BOOL)animated{
    bufferAngleLeft = 0;
    bufferAngleRight = 0;
    eracerSet=NO;
    isShowMenu = NO;
    screenSize=self.view.bounds.size;
    centerPoint = CGPointMake(screenSize.width/2,screenSize.height/2);
    drawToPoint = centerPoint;
    lastPoint= centerPoint;
    [self setCursorPosition:centerPoint];
}

#pragma mark - CircularGestureRecognizerDelegate protocol methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    if (gestureRecognizer == gestureRecognizerLeft) {
        if ([touch locationInView:self.view].x < screenSize.width/2) {
            return YES;
        }
    } else if (gestureRecognizer == gestureRecognizerRight){
        if ([touch locationInView:self.view].x >= screenSize.width/2) {
            return YES;
        }
    }
    else if(gestureRecognizer == gestureRecognizerMenu){
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldMove:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTouches != 1){
        CGPoint touchA = [gestureRecognizer locationOfTouch:0 inView:self.view];
        CGPoint touchB = [gestureRecognizer locationOfTouch:1 inView:self.view];
        CGFloat distance = distanceBetweenPoints(touchA, touchB);
        if (distance < distanceTrigger){
            rightWheel.alpha = 0;
            leftWheel.alpha = 0;
            isShowMenu = YES;
            gestureRecognizerLeft.enabled = NO;
            gestureRecognizerRight.enabled = NO;
            menuView.center = touchA;
            if (!eracerSet)
                [menuView setImage:[UIImage imageNamed:@"eracerEmpty.png"]];
            else
                [menuView setImage:[UIImage imageNamed:@"penEmpty.png"]];
            return NO;
        }
    }
    if (gestureRecognizerLeft.numberOfTouches == 1 && gestureRecognizerRight.numberOfTouches == 1) {
        CGPoint touchA = [gestureRecognizerLeft locationOfTouch:0 inView:self.view];
        CGPoint touchB = [gestureRecognizerRight locationOfTouch:0 inView:self.view];
        CGFloat distance = distanceBetweenPoints(touchA, touchB);
        if (distance < distanceTrigger){
            rightWheel.alpha = 0;
            leftWheel.alpha = 0;
            isShowMenu = YES;
            gestureRecognizerLeft.enabled = NO;
            gestureRecognizerRight.enabled = NO;
            menuView.center = touchA;
            if (!eracerSet)
                [menuView setImage:[UIImage imageNamed:@"eracerEmpty.png"]];
            else
                [menuView setImage:[UIImage imageNamed:@"penEmpty.png"]];
            return NO;
        }
    }
    
    if (gestureRecognizer == gestureRecognizerLeft)
        [self startLeft];
    if (gestureRecognizer == gestureRecognizerRight)
        [self startRight];
    return YES;
}

- (void) startLeft {
    [UIView animateWithDuration:0.5 animations:^{leftWheel.alpha = 1;}];
    leftWheel.center = CGPointMake([gestureRecognizerLeft locationInView:self.view].x- leftWheel.bounds.size.width/2, [gestureRecognizerLeft locationInView:self.view].y);
    leftWheel.transform = CGAffineTransformMakeRotation(0);
    [gestureRecognizerLeft setMidPoint: leftWheel.center
                           innerRadius: inRadius
                           outerRadius: outRadius];
}

-(void) startRight{
    [UIView animateWithDuration:0.5 animations:^{rightWheel.alpha = 1;}];
    rightWheel.center = CGPointMake([gestureRecognizerRight locationInView:self.view].x- rightWheel.bounds.size.width/2, [gestureRecognizerRight locationInView:self.view].y);
    rightWheel.transform = CGAffineTransformMakeRotation(0);
    [gestureRecognizerRight setMidPoint: rightWheel.center
                            innerRadius: inRadius
                            outerRadius: outRadius];
}

- (void) onMenuTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (isShowMenu){
        Byte sector;
        CGFloat angle = angleBetweenLinesInDegrees(menuView.center, CGPointMake(menuView.center.x+100, menuView.center.y), menuView.center, [gestureRecognizer locationInView: self.view]);
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
        
        CGFloat distance = distanceBetweenPoints(menuView.center, [gestureRecognizer locationInView: self.view]);
        if (distance < 100.0f){
            if (!eracerSet) {
                if (sector == Up)
                    [menuView setImage:[UIImage imageNamed:@"eracerEracer.png"]];
                if (sector == Right)
                    [menuView setImage:[UIImage imageNamed:@"eracerSave.png"]];
                if (sector == Down)
                    [menuView setImage:[UIImage imageNamed:@"eracerClear.png"]];
                if (sector == Left)
                    [menuView setImage:[UIImage imageNamed:@"eracerLoad.png"]];
            } else{
                if (sector == Up)
                    [menuView setImage:[UIImage imageNamed:@"penPen.png"]];
                if (sector == Right)
                    [menuView setImage:[UIImage imageNamed:@"penSave.png"]];
                if (sector == Down)
                    [menuView setImage:[UIImage imageNamed:@"penClear.png"]];
                if (sector == Left)
                    [menuView setImage:[UIImage imageNamed:@"penLoad.png"]];
            }
        }
        
        [UIView animateWithDuration:.2 animations:^{
            menuView.alpha = 0;
                    } completion:^(BOOL finished){
            [menuView setImage:nil];
            menuView.alpha=1;
            if (distance < 100.0f){
                if (sector == Up)
                    [self eracer];
                if (sector == Right)
                    [self savePicture];
                if (sector == Down)
                    [self clearScreen];
                if (sector == Left)
                    [self loadPicture];
            }
            isShowMenu = NO;
            gestureRecognizerLeft.enabled = YES;
            gestureRecognizerRight.enabled = YES;
        }];
    }
}

-(void) onHelpTap: (UITapGestureRecognizer*) tapGestureRecognizer {
    [self.helpImageView removeFromSuperview];
    gestureRecognizerLeft.enabled = YES;
    gestureRecognizerRight.enabled = YES;
    gestureRecognizerMenu.enabled = YES;
    tapGestureRecognizer.enabled = NO;
    cursor.hidden = NO;
    cursorTimer=[NSTimer scheduledTimerWithTimeInterval:cursorHideShowTime target:self selector:@selector(cursorHideShow) userInfo:nil repeats:YES];
}

- (void) willRotateAndConvert: (CGFloat) angle : (NDARotationGestureRecognizer *) gestureRecognizer{
    if(gestureRecognizer == gestureRecognizerRight) {
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

    
    
    _paintingView.lastPoint =lastPoint;
    _paintingView.drawToPoint = drawToPoint;
    
    [_paintingView drawToCache];
    lastPoint = drawToPoint;
    
    [self setCursorPosition:drawToPoint];
    
    [controllersTimer invalidate];
    controllersTimer=[NSTimer scheduledTimerWithTimeInterval:controllersHideShowTime target:self selector:@selector(hideControllers) userInfo:nil repeats:NO];
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

#pragma mark - Menu methods


- (void) clearScreen {
    bufferAngleLeft = 0;
    bufferAngleRight = 0;
    lastPoint= centerPoint;
    drawToPoint = centerPoint;
    [UIView animateWithDuration:0.5 animations:^{[self setCursorPosition:centerPoint];}];
}

- (void) savePicture {

    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:CGBitmapContextCreateImage(_paintingView.cacheContext)], nil, nil, nil );
    
    AudioServicesPlaySystemSound(1108);
    
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
    CGContextDrawImage(_paintingView.cacheContext, self.view.bounds, image.CGImage);
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Helper methods

-(void) hideControllers {
    [UIView animateWithDuration:0.5 animations:^{
        leftWheel.alpha = 0;
        rightWheel.alpha = 0;
    }];
}

-(CGPoint) checkForScreenOutRight:(CGPoint) checkPoint{
    if (checkPoint.x+1>screenSize.width-moveFactor) {
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
    if (checkPoint.y+1>screenSize.height-moveFactor) {
        return checkPoint;
    } else {
        return checkPoint=CGPointMake(checkPoint.x, checkPoint.y+moveFactor);
    }
}

-(CGPoint) checkForScreenOutUp:(CGPoint) checkPoint{
    if (checkPoint.y-1<moveFactor) {
        return checkPoint;
    } else {
        return checkPoint=CGPointMake(checkPoint.x, checkPoint.y-moveFactor);
    }
}

@end