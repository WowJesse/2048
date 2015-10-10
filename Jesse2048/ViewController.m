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
@property (weak, nonatomic) IBOutlet UIView *bgView;//放置按钮的view

@property (nonatomic,strong) NSMutableArray *bgBtns;//背景按钮


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

//up swipe
- (void)swipeU:(UISwipeGestureRecognizer *)swipe
{
    for (UIButton *btn in self.bgBtns) {
        if (btn.currentTitle != nil) {
            //获取到上一个button之后判断是否有title  有的话相加  没的话继续上移
            [self moveBtn:btn X:0.f Y:-(marginY + btnHeight)];
        }
    }
    //随机在title为空的button添加title
    [self randomReduceBtn];
}
//down swipe
- (void)swipeD:(UISwipeGestureRecognizer *)swipe
{
    for (UIButton *btn in self.bgBtns) {
        if (btn.currentTitle != nil) {
            //获取到下一个button之后判断是否有title  有的话相加  没的话继续下移
            [self moveBtn:btn X:0.f Y:(marginY + btnHeight)];
        }
    }
    //随机在title为空的button添加title
    [self randomReduceBtn];
}
//left swipe
- (void)swipeL:(UISwipeGestureRecognizer *)swipe
{
    for (UIButton *btn in self.bgBtns) {
        if (btn.currentTitle != nil) {
            //获取到左一个button之后判断是否有title  有的话相加  没的话继续左移
            [self moveBtn:btn X:-(marginY + btnHeight) Y:0.f];
        }
    }
    //随机在title为空的button添加title
    [self randomReduceBtn];
}
//right swipe
- (void)swipeR:(UISwipeGestureRecognizer *)swipe
{
    for (UIButton *btn in self.bgBtns) {
        if (btn.currentTitle != nil) {
            //获取到右一个button之后判断是否有title  有的话相加  没的话继续右移
            [self moveBtn:btn X:(marginY + btnHeight) Y:0.f];
        }
    }
    //随机在title为空的button添加title
    [self randomReduceBtn];
}
//获取到上一个button之后判断是否有title  有的话相加  没的话继续上移
- (void)moveBtn:(UIButton *)btn X:(CGFloat)moveX Y:(CGFloat)moveY
{
    CGPoint currentBtnPoint = btn.center;
    CGPoint nextBtnPoint = CGPointMake(currentBtnPoint.x + moveX, currentBtnPoint.y + moveY);
    NSMutableArray *noTittleBtns = [NSMutableArray array];
    for (UIButton *nextBtn in self.bgBtns) {
        //获取到上一个button
        if (nextBtnPoint.x == nextBtn.center.x
            && nextBtnPoint.y == nextBtn.center.y) {
            //如果上面那个button跟下面的title一样的话相加
            if ([nextBtn.currentTitle isEqualToString:btn.currentTitle]) {
                [nextBtn setTitle:[NSString stringWithFormat:@"%d",[nextBtn.currentTitle intValue] + [btn.currentTitle intValue]] forState:UIControlStateNormal];
                [btn setTitle:nil forState:UIControlStateNormal];
                return;
            }
            //下面这些执行完毕之后会得到一个最上面title为空的button
            //如果上面那个button的title为空的话
            if (nextBtn.currentTitle == nil) {
                [noTittleBtns addObject:nextBtn];
                for (UIButton *next2Btn in self.bgBtns) {
                    if (next2Btn.center.x == nextBtn.center.x + moveX
                        && next2Btn.center.y == nextBtn.center.y + moveY) {
                        //如果上面上面那个button的title为空的话
                        if (next2Btn.currentTitle == nil) {
                            [noTittleBtns addObject:next2Btn];
                            for (UIButton *next3Btn in self.bgBtns) {
                                if (next3Btn.center.x == nextBtn.center.x + 2 * moveX
                                    && next3Btn.center.y == nextBtn.center.y + 2 * moveY) {
                                    //如果上面上面上面那个button的title为空的话
                                    if (next3Btn.currentTitle == nil) {
                                        [noTittleBtns addObject:next3Btn];
                                    }
                                }
                            }
                        }
                    }
                }
                //得到最上面为空的button之后，判断再上面还有button没，有的话判断相加
                for (UIButton *nextNoNullBtn in self.bgBtns) {
                    UIButton *nextestNullBtn = [noTittleBtns lastObject];
                    if (nextNoNullBtn.center.x == nextestNullBtn.center.x + moveX
                        && nextNoNullBtn.center.y == nextestNullBtn.center.y + moveY) {
                        //如果相等，就相加
                        if ([nextNoNullBtn.currentTitle isEqualToString:btn.currentTitle]) {
                            [nextNoNullBtn setTitle:[NSString stringWithFormat:@"%d",[nextNoNullBtn.currentTitle intValue] + [btn.currentTitle intValue]] forState:UIControlStateNormal];
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
