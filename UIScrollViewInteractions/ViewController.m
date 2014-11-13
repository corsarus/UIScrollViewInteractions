//
//  ViewController.m
//  UIScrollViewInteractions
//
//  Created by Catalin (iMac) on 11/11/2014.
//  Copyright (c) 2014 Catalin Rosioru. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupScrollView];
}

- (void)setupScrollView
{
    // show both scroll indicators
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    
    // set the view controller the scroll view delegate
    self.scrollView.delegate = self;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // set the contentSize 3 times the screen size in both directions
    self.scrollView.contentSize = CGSizeMake(3 * screenWidth, 3 * screenHeight);
    
    // add the container subview and center it in the scroll view
    self.containerView = [[UIView alloc] init];
    self.containerView.frame = CGRectMake(0, 0, 3 * screenWidth, 3 * screenHeight);
    [self.scrollView addSubview:self.containerView];
    
    // automatically scroll to the center of the containerView
    [self.scrollView setContentOffset:CGPointMake(screenWidth, screenHeight)];
    
    // enable zooming
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 3.0;
    
    // add random subviews to the view
    [self addRandomSubviews:20 toView:self.containerView];
    
    [self addTapGesturesToScrollView:self.scrollView];
    
}

- (void)addRandomSubviews:(NSUInteger)count toView:(UIView *)view
{
    CGFloat containerWidth = self.containerView.bounds.size.width;
    CGFloat containerHeight = self.containerView.bounds.size.height;
    CGRect randomViewFrame;
    
    for (NSUInteger i = 0; i < count; i++) {
        
        BOOL isRandomViewOverlapping = YES;
        while (isRandomViewOverlapping) {
            isRandomViewOverlapping = NO;
            
            // random float between 0 and 1
            CGFloat randomMultiplier = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX));
            CGFloat randomMultiplierY = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX));
            
            NSUInteger randomViewWidth = (NSUInteger)(containerHeight * randomMultiplier / i);
            NSUInteger randomViewHeight = (NSUInteger)(containerHeight * randomMultiplier / i);
            CGPoint randomViewOrigin = CGPointMake((NSUInteger)(containerWidth * randomMultiplier - randomViewWidth),
                                                   (NSUInteger)(containerHeight * randomMultiplierY - randomViewHeight));
            randomViewFrame = CGRectMake(randomViewOrigin.x, randomViewOrigin.y,
                                                randomViewWidth, randomViewHeight);
            
            for (UIView *randomSubview in view.subviews) {
                if (!CGRectIsNull(CGRectIntersection(randomViewFrame, randomSubview.frame))) {
                    isRandomViewOverlapping = YES;
                    break;
                }
            }
            
        }
        
        CGFloat red = arc4random() / INT_MAX;
        CGFloat green = arc4random() / INT_MAX;
        CGFloat blue = arc4random() / INT_MAX;
        
        UIView *randomView = [[UIView alloc] initWithFrame:randomViewFrame];
        randomView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
        // add long press gesture for the drag & drop
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
        [randomView addGestureRecognizer:longPressGesture];
        
        [view addSubview:randomView];
    }
}

- (void)addTapGesturesToScrollView:(UIScrollView *)scrollView
{

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSubview:)];
    singleTap.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(zoomScrollView:)];
    doubleTap.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTap];
    
    // ignore the individual taps in a double-tap gesture
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)selectSubview:(UITapGestureRecognizer *)tapGesture
{
    // detect the tapped subview
    CGPoint hitPoint = [tapGesture locationInView:self.containerView];
    UIView *tappedView = [self.containerView hitTest:hitPoint withEvent:nil];
    
    // animate the tapped view opacity
    // the delay between the touch gesture and the view animation is caused by the scroll view which needs to makes sure it's not a pan ou pinch gesture
    if (tappedView != self.containerView) {
        [UIView animateWithDuration:0.08
                         animations:^{
                             tappedView.alpha = 0.5;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.08
                                              animations:^{
                                                  tappedView.alpha = 1.0;
                                              }];
                         }];
    }
}

- (void)zoomScrollView:(UITapGestureRecognizer *)tapGesture
{
    // reset the zoom scale if the content is zoomed in or out
    if (self.scrollView.zoomScale != 1.0) {
        [self.scrollView setZoomScale:1 animated:YES];
    }
}

- (void)longPressRecognized:(UILongPressGestureRecognizer *)longPressGesture
{
    UIView *pressedView = longPressGesture.view;
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan: {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 pressedView.alpha = 0.5;
                                 // "slowly" center the subview under the finger
                                 pressedView.center = [longPressGesture locationInView:pressedView.superview];
                             }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // make the subview follow the finger
            pressedView.center = [longPressGesture locationInView:pressedView.superview];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 pressedView.alpha = 1.0;
                             }];
            break;
        }
        default:
            break;
    }
}


# pragma mark Delegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

@end
