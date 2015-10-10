//
//  ViewController.m
//  Jesse2048
//
//  Created by qingyun on 15/10/9.
//  Copyright (c) 2015年 hnqingyun. All rights reserved.
//

#import "ViewController.h"

#define marginX     10.f
#define marginY     10.f
#define btnWidth    0.25 * ([UIScreen mainScreen].bounds.size.width - (5 * marginX))
#define btnHeight   0.25 * ([UIScreen mainScreen].bounds.size.width - (5 * marginY))


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic,strong) NSMutableArray *bgBtns;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add backgroundLittleView
    [self addBGLittleView];
    [self setSwipes];
    //随机生成一个button
    [self randomReduceBtn];
}
- (void)setSwipes
{
    //up swipe
    UISwipeGestureRecognizer *swipeU = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeU:)];
    swipeU.direction = UISwipeGestureRecognizerDirectionUp;
    [self.bgView addGestureRecognizer:swipeU];
    //down swipe
    UISwipeGestureRecognizer *swipeD = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeD:)];
    swipeD.direction = UISwipeGestureRecognizerDirectionDown;
    [self.bgView addGestureRecognizer:swipeD];
    //left swipe
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeL:)];
    swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.bgView addGestureRecognizer:swipeL];
    //right swipe
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeR:)];
    swipeR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.bgView addGestureRecognizer:swipeR];
    
}
- (void)randomReduceBtn
{
    NSMutableArray *noTittleBtns = [NSMutableArray array];
    for (UIButton *btn in self.bgBtns) {
        if ([btn currentTitle] == nil) {
            [noTittleBtns addObject:btn];
        }
    }
    //随机在空title的数组中设置一个title
    int i = arc4random_uniform((int)noTittleBtns.count);
    UIButton *btn = noTittleBtns[i];
    [btn setTitle:@"2" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

//up down swipe
- (void)swipeU:(UISwipeGestureRecognizer *)swipe
{
    for (UIButton *btn in self.bgBtns) {
        if (btn.currentTitle != nil) {
            //获取到上一个button之后判断是否有title  有的话相加  没的话继续上移
            [self moveBtnUp:btn];
        }
    }
    //随机在title为空的button添加title
    [self randomReduceBtn];
}
//获取到上一个button之后判断是否有title  有的话相加  没的话继续上移
- (void)moveBtnUp:(UIButton *)btn
{
    CGPoint currentBtnPoint = btn.center;
    CGPoint upBtnPoint = CGPointMake(currentBtnPoint.x, currentBtnPoint.y - (marginY + btnHeight));
    NSMutableArray *noTittleBtns = [NSMutableArray array];
    for (UIButton *upBtn in self.bgBtns) {
        //获取到上一个button
        if (upBtnPoint.x == upBtn.center.x
            && upBtnPoint.y == upBtn.center.y) {
            //如果上面那个button跟下面的title一样的话相加
            if ([upBtn.currentTitle isEqualToString:btn.currentTitle]) {
                [upBtn setTitle:[NSString stringWithFormat:@"%d",[upBtn.currentTitle intValue] + [btn.currentTitle intValue]] forState:UIControlStateNormal];
                [btn setTitle:nil forState:UIControlStateNormal];
            }
            //下面这些执行完毕之后会得到一个最上面title为空的button
            //如果上面那个button的title为空的话
            if (upBtn.currentTitle == nil) {
                [noTittleBtns addObject:upBtn];
                for (UIButton *up2Btn in self.bgBtns) {
                    if (up2Btn.center.x == upBtn.center.x
                        && up2Btn.center.y == upBtn.center.y - (marginY + btnHeight)) {
                        //如果上面上面那个button的title为空的话
                        if (up2Btn.currentTitle == nil) {
                            [noTittleBtns addObject:up2Btn];
                            for (UIButton *up3Btn in self.bgBtns) {
                                if (up3Btn.center.x == upBtn.center.x
                                    && up3Btn.center.y == upBtn.center.y - 2 * (marginY + btnHeight)) {
                                    //如果上面上面上面那个button的title为空的话
                                    if (up3Btn.currentTitle == nil) {
                                        [noTittleBtns addObject:up3Btn];
                                    }
                                }
                            }
                        }
                    }
                }
                //得到最上面为空的button之后，判断再上面还有button没，有的话判断相加
                for (UIButton *upNoNullBtn in self.bgBtns) {
                    UIButton *upestNullBtn = [noTittleBtns lastObject];
                    if (upNoNullBtn.center.x == upestNullBtn.center.x
                        && upNoNullBtn.center.y == upestNullBtn.center.y - (marginY + btnHeight)) {
                        //如果相等，就相加
                        if ([upNoNullBtn.currentTitle isEqualToString:btn.currentTitle]) {
                            [upNoNullBtn setTitle:[NSString stringWithFormat:@"%d",[upNoNullBtn.currentTitle intValue] + [btn.currentTitle intValue]] forState:UIControlStateNormal];
                            [btn setTitle:nil forState:UIControlStateNormal];
                            return;
                        }
                    }
                }
                //如果最上面为空的再上面没有button之后，设置
                [[noTittleBtns lastObject] setTitle:[btn currentTitle] forState:UIControlStateNormal];
                [[noTittleBtns lastObject] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitle:nil forState:UIControlStateNormal];

            }
        }
    }
}
- (void)swipeD:(UISwipeGestureRecognizer *)swipe
{
    
}
//left right swipe
- (void)swipeL:(UISwipeGestureRecognizer *)swipe
{
    
}
- (void)swipeR:(UISwipeGestureRecognizer *)swipe
{
    
}
-(void)addBGLittleView
{
    for (int i = 0; i < 16; i ++) {
        int row = i / 4;
        int colunm = i % 4;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        btn.frame = CGRectMake(colunm * (marginX + btnWidth) + marginX, row * (marginY + btnHeight) + marginY, btnWidth, btnHeight);
        btn.layer.cornerRadius = 10;
        btn.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.4];
        btn.userInteractionEnabled = YES;
        [self.bgBtns addObject:btn];
        [self.bgView addSubview:btn];
    }
}
#pragma mark - lazy load
-(NSMutableArray *)bgBtns
{
    if (_bgBtns == nil) {
        _bgBtns = [NSMutableArray array];
    }
    return _bgBtns;
}
@end
