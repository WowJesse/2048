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

#define kHighestScore   @"highestScore"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;//放置按钮的view
@property (nonatomic,strong) NSMutableArray *bgBtns;//背景按钮

@property (weak, nonatomic) IBOutlet UILabel *currentScore;
@property (weak, nonatomic) IBOutlet UILabel *highestScore;
@property (nonatomic) int score;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) int beginTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //add backgroundLittleView
    [self addBGLittleView];
    [self setSwipes];
    //随机生成一个button
    [self randomReduceBtn];
    //从本地读取出来保存的最高分数
    [self getHighestScore2Label];
    //设置游戏时间
    [self setGameTime];
}
- (void)setGameTime
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
}
//每秒60帧的刷新本方法
- (void)setNeedsDisplay
{
    self.beginTime ++;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",self.beginTime / 60,self.beginTime % 60];
}
//重新设置计时器的label
- (void)resetTimeLabel
{
    [self.timer invalidate];
    self.timer = nil;
    self.beginTime = 0;
    [self setGameTime];
}
//从本地读取最高纪录
- (void)getHighestScore2Label
{
    id sign = [[NSUserDefaults standardUserDefaults] objectForKey:kHighestScore];
    if (sign) {
        self.highestScore.text = sign;
    }
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
//随机生成一个button
- (void)randomReduceBtn
{
    NSMutableArray *noTittleBtns = [NSMutableArray array];
    for (UIButton *btn in self.bgBtns) {
        if ([btn currentTitle] == nil) {
            [noTittleBtns addObject:btn];
        }
    }
    if (noTittleBtns.count == 0) {
        return;
    }
    //随机在空title的数组中设置一个title
    int i = arc4random_uniform((int)noTittleBtns.count);
    UIButton *btn = noTittleBtns[i];
    [btn setTitle:@"2" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setBtnsBGColor];
}
//便利所有button  构造button的背景
- (void)setBtnsBGColor
{
    for (UIButton *btn in self.bgBtns) {
        if (btn.currentTitle != nil) {
            for (int i = 0; i < 2048; i ++) {
                if (pow(2, i) == [btn.currentTitle floatValue]) {
                    [btn setBackgroundColor:[self setBtnBGColor:i]];
                }
            }
        }else{
            btn.backgroundColor = [UIColor colorWithRed:0.5 green:0.3 blue:0.3 alpha:0.1];
        }
    }
}
//判断是否结束游戏
- (void)judgeGameOver
{
    NSMutableArray *muarr = [NSMutableArray array];
    for (UIButton *btn in self.bgBtns) {
        if (btn.currentTitle == nil) {
            [muarr addObject:btn];
        }
    }
    if (muarr.count == 0 && [self noSameTitle]) {
        //保存到本地
        [self saveHighestScore];
        [self.timer invalidate];
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"很遗憾" message:@"游戏结束" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"再来一局" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //再来一局
            for (UIButton *btn in self.bgView.subviews) {
                [btn removeFromSuperview];
            }
            [self.bgBtns removeAllObjects];
            //add backgroundLittleView
            [self addBGLittleView];
            [self setSwipes];
            self.score = 0;
            [self setScoreLabel];
            //随机生成一个button
            [self randomReduceBtn];
            //重新设置计时器label
            [self resetTimeLabel];
        }];
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
}
//判断是否还有相邻的title相同的按钮
- (BOOL)noSameTitle
{
    for (UIButton *btn in self.bgBtns) {
        CGPoint upBtn = CGPointMake(btn.center.x, btn.center.y - (marginY + btnHeight));
        CGPoint leftBtn = CGPointMake(btn.center.x - (marginY + btnHeight), btn.center.y);
        CGPoint downBtn = CGPointMake(btn.center.x, btn.center.y + (marginY + btnHeight));
        CGPoint rightBtn = CGPointMake(btn.center.x + (marginY + btnHeight), btn.center.y);
        for (UIButton *nextBtn in self.bgBtns) {
            if ((nextBtn.center.x == upBtn.x && nextBtn.center.y == upBtn.y)
                || (nextBtn.center.x == leftBtn.x && nextBtn.center.y == leftBtn.y)
                || (nextBtn.center.x == downBtn.x && nextBtn.center.y == downBtn.y)
                || (nextBtn.center.x == rightBtn.x && nextBtn.center.y == rightBtn.y)) {
                if ([btn.currentTitle isEqualToString:nextBtn.currentTitle]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}
//设置分数label
- (void)setScoreLabel
{
    self.currentScore.text = [NSString stringWithFormat:@"%d",self.score];
    if (self.score > [self.highestScore.text intValue]) {
        self.highestScore.text = [NSString stringWithFormat:@"%d",self.score];
    }
}
//把最高分保存到本地
- (void)saveHighestScore
{
    id sign = [[NSUserDefaults standardUserDefaults] objectForKey:kHighestScore];
    if (sign) {
        if (self.score > [(NSString *)sign intValue]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHighestScore];
            [[NSUserDefaults standardUserDefaults] setObject:self.highestScore.text forKey:kHighestScore];
        }
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:self.highestScore.text forKey:kHighestScore];
    }
}
//设置button的颜色
- (UIColor *)setBtnBGColor:(float)multiple
{
    UIColor *color = [UIColor colorWithRed:(1 - multiple / 17.f) green:(1 - multiple / 34.f) blue:(1 - multiple / 34.f) alpha:1];
    return color;
}
//重新开始
- (IBAction)restart:(UIButton *)sender {
    //保存到本地
    [self saveHighestScore];
    [self.timer invalidate];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"重新开始" message:@"小可爱你确定要重新开始嘛~ " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"确定开始" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //再来一局
        //重新设置计时器label
        [self resetTimeLabel];
        for (UIButton *btn in self.bgView.subviews) {
            [btn removeFromSuperview];
        }
        [self.bgBtns removeAllObjects];
        //add backgroundLittleView
        [self addBGLittleView];
        [self setSwipes];
        self.score = 0;
        [self setScoreLabel];
        //随机生成一个button
        [self randomReduceBtn];
        
    }];
    UIAlertAction *aaShare = [UIAlertAction actionWithTitle:@"并不" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setGameTime];
    }];
    [ac addAction:aa];
    [ac addAction:aaShare];
    [self presentViewController:ac animated:YES completion:nil];
}
//退出游戏
- (IBAction)bye:(UIButton *)sender {
    //保存到本地
    [self saveHighestScore];
    [self.timer invalidate];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"小可爱你确定要退出游戏嘛~ T_T ?" message:@"如有BUG,coder邮箱:jia_xin8@163.com" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"确定退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        exit(0);
    }];
    UIAlertAction *aaShare = [UIAlertAction actionWithTitle:@"继续玩~" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setGameTime];
    }];
    [ac addAction:aa];
    [ac addAction:aaShare];
    [self presentViewController:ac animated:YES completion:nil];

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
    [self judgeGameOver];
    [self setScoreLabel];
}
//down swipe
- (void)swipeD:(UISwipeGestureRecognizer *)swipe
{
    NSArray *tempArr = [[self.bgBtns reverseObjectEnumerator] allObjects];
    for (UIButton *btn in tempArr) {
        if (btn.currentTitle != nil) {
            //获取到下一个button之后判断是否有title  有的话相加  没的话继续下移
            [self moveBtn:btn X:0.f Y:(marginY + btnHeight)];
        }
    }
    //随机在title为空的button添加title
    [self randomReduceBtn];
    [self judgeGameOver];
    [self setScoreLabel];
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
    [self judgeGameOver];
    [self setScoreLabel];
}
//right swipe
- (void)swipeR:(UISwipeGestureRecognizer *)swipe
{
    NSArray *tempArr = [[self.bgBtns reverseObjectEnumerator] allObjects];
    for (UIButton *btn in tempArr) {
        if (btn.currentTitle != nil) {
            //获取到右一个button之后判断是否有title  有的话相加  没的话继续右移
            [self moveBtn:btn X:(marginY + btnHeight) Y:0.f];
        }
    }
    //随机在title为空的button添加title
    [self randomReduceBtn];
    [self judgeGameOver];
    [self setScoreLabel];
}
//获取到后一个button之后判断是否有title  有的话相加  没的话继续上移
- (void)moveBtn:(UIButton *)btn X:(CGFloat)moveX Y:(CGFloat)moveY
{
    CGPoint currentBtnPoint = btn.center;
    CGPoint nextBtnPoint = CGPointMake(currentBtnPoint.x + moveX, currentBtnPoint.y + moveY);
    NSMutableArray *noTittleBtns = [NSMutableArray array];
    for (UIButton *nextBtn in self.bgBtns) {
        //获取到后一个button
        if (nextBtnPoint.x == nextBtn.center.x
            && nextBtnPoint.y == nextBtn.center.y) {
            //如果后面那个button跟前面的title一样的话相加
            if ([nextBtn.currentTitle isEqualToString:btn.currentTitle]) {
                int toBtn = [nextBtn.currentTitle intValue] + [btn.currentTitle intValue];
                [nextBtn setTitle:[NSString stringWithFormat:@"%d",toBtn] forState:UIControlStateNormal];
                self.score = self.score + toBtn;
                [btn setTitle:nil forState:UIControlStateNormal];
                return;
            }
            //下面这些执行完毕之后会得到一个最后面title为空的button
            //如果后面那个button的title为空的话
            if (nextBtn.currentTitle == nil) {
                [noTittleBtns addObject:nextBtn];
                for (UIButton *next2Btn in self.bgBtns) {
                    if (next2Btn.center.x == nextBtn.center.x + moveX
                        && next2Btn.center.y == nextBtn.center.y + moveY) {
                        //如果后面后面那个button的title为空的话
                        if (next2Btn.currentTitle == nil) {
                            [noTittleBtns addObject:next2Btn];
                            for (UIButton *next3Btn in self.bgBtns) {
                                if (next3Btn.center.x == nextBtn.center.x + 2 * moveX
                                    && next3Btn.center.y == nextBtn.center.y + 2 * moveY) {
                                    //如果后面后面后面那个button的title为空的话
                                    if (next3Btn.currentTitle == nil) {
                                        [noTittleBtns addObject:next3Btn];
                                    }
                                }
                            }
                        }
                    }
                }
                //得到最后面为空的button之后，判断再后面还有button没，有的话判断相加
                for (UIButton *nextNoNullBtn in self.bgBtns) {
                    UIButton *nextestNullBtn = [noTittleBtns lastObject];
                    if (nextNoNullBtn.center.x == nextestNullBtn.center.x + moveX
                        && nextNoNullBtn.center.y == nextestNullBtn.center.y + moveY) {
                        //如果相等，就相加
                        if ([nextNoNullBtn.currentTitle isEqualToString:btn.currentTitle]) {
                            
                            int toBtn = [nextNoNullBtn.currentTitle intValue] + [btn.currentTitle intValue];
                            [nextNoNullBtn setTitle:[NSString stringWithFormat:@"%d",toBtn] forState:UIControlStateNormal];
                            self.score = self.score + toBtn;
                            [btn setTitle:nil forState:UIControlStateNormal];
                            return;
                        }
                    }
                }
                //如果最后面为空的再后面没有button之后，设置
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
