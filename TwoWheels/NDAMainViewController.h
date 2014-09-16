//
//  CircularGestureViewController.h
//


#import <UIKit/UIKit.h>
#import "NDARotationGestureRecognizer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BIDView.h"


#define degreeInPoint 2.25
#define inRadius 5
#define outRadius 200
#define cursorHideShowTime 1
#define controllersHideShowTime 2
#define moveFactor 2
#define distanceTrigger 200


@interface NDAMainViewController : UIViewController <NDARotationGestureRecognizerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    CGFloat bufferAngleLeft;
    CGFloat bufferAngleRight;
    CGPoint centerPoint;
    CGPoint lastPoint;
    CGPoint drawToPoint;
    NDARotationGestureRecognizer *gestureRecognizerLeft;
    NDARotationGestureRecognizer *gestureRecognizerRight;
    UITapGestureRecognizer *gestureRecognizerMenu;
    CGSize screenSize;
    BOOL eracerSet;
    BOOL isShowMenu;
    NSTimer *controllersTimer;
    NSTimer *cursorTimer;
}

typedef NS_ENUM(NSInteger, MenuSector) {
    Center,Up,Right,Down,Left
};

@property (strong, nonatomic) IBOutlet BIDView *paintingView;

@property (strong, nonatomic)  UIImageView *helpImageView;
@property (strong, nonatomic) IBOutlet UIImageView *cursor;
@property (strong, nonatomic) IBOutlet UIImageView *paintingImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftWheel;
@property (strong, nonatomic) IBOutlet UIImageView *rightWheel;
@property (strong, nonatomic) IBOutlet UIImageView *menuView;

@end
