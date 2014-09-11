//
//  CircularGestureViewController.h
//


#import <UIKit/UIKit.h>
#import "NDARotationGestureRecognizer.h"
#import "NDAMenuGestureRecognizer.h"
#import <AudioToolbox/AudioToolbox.h>


#define degreeInPoint 2.25
#define inRadius 5
#define outRadius 100
#define cursorHideShowTime 1
#define controllersHideShowTime 2
#define moveFactor 2
#define distanceTrigger 200


@interface NDAMainViewController : UIViewController <NDARotationGestureRecognizerDelegate,NDAMenuGestureRecognizerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    CGFloat bufferAngleLeft;
    CGFloat bufferAngleRight;
    CGPoint centerPoint;
    CGPoint lastPoint;
    CGPoint drawToPoint;
    NDARotationGestureRecognizer *gestureRecognizerLeft;
    NDARotationGestureRecognizer *gestureRecognizerRight;
    NDAMenuGestureRecognizer *gestureRecognizerMenu;
    CGRect screenBounds;
    BOOL eracerSet;
    NSTimer *controllersTimer;
    NSTimer *cursorTimer;
}

@property (strong, nonatomic)  UIImageView *helpImageView;
@property (strong, nonatomic) IBOutlet UIImageView *cursor;
@property (strong, nonatomic) IBOutlet UIImageView *paintingImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftWheel;
@property (strong, nonatomic) IBOutlet UIImageView *rightWheel;
@property (strong, nonatomic) IBOutlet UIImageView *menuView;

@end
