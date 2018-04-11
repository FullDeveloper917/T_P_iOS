//
//  YLPopInputPasswordView.m
//  YouLanAgents
//
//  Created by lqcjdx on 15/5/27.
//  Copyright (c) 2015年 YL. All rights reserved.
//

#define kLineTag 1000
#define kDotTag 3000

#import "PopInputView.h"
#import <QuartzCore/QuartzCore.h>

#define kPasswordLength  6

@interface PopInputView()<UITextFieldDelegate>
{
    
}
@property(nonatomic,strong)UIControl *overlayView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *lineLabel;
@property(nonatomic,strong)UITextField *textFiled;
@property(nonatomic,strong)UIButton *btnCreate;
@property(nonatomic,strong)UIButton *btnCancel;
@end

@implementation PopInputView

-(instancetype)init{
    if(self = [super init]){
        [self customInit];
    }
    
    return self;
}

-(void)customInit
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 20;
//    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.backgroundColor = [UIColor colorWithRed:59/255.0 green:103/255.0 blue:188/255.0 alpha:1];
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:30];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"Create a Topic";
    [self addSubview:_titleLabel];
    
//    _lineLabel = [[UILabel alloc]init];
//    _lineLabel.backgroundColor = [UIColor grayColor];
//    [self addSubview:_lineLabel];
    
    _textFiled = [[UITextField alloc]init];
    _textFiled.backgroundColor = [UIColor whiteColor];
    _textFiled.layer.masksToBounds = YES;
    _textFiled.layer.borderColor = [UIColor grayColor].CGColor;
    _textFiled.layer.borderWidth = 1;
    _textFiled.layer.cornerRadius = 5;
    _textFiled.delegate = self;
//    _textFiled.tintColor = [UIColor clearColor];
//    _textFiled.textColor = [UIColor clearColor];
    _textFiled.font = [UIFont systemFontOfSize:20];
    [_textFiled addTarget:self action:@selector(textFiledEdingChanged) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textFiled];
    
    _btnCreate = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCreate.backgroundColor = [UIColor colorWithRed:48/255.0 green:109/255.0 blue:238/255.0 alpha:1];
    _btnCreate.layer.masksToBounds = YES;
    _btnCreate.layer.borderWidth = 1;
    _btnCreate.layer.borderColor = [UIColor grayColor].CGColor;
    _btnCreate.layer.cornerRadius = 5;
    _btnCreate.titleLabel.font = [UIFont systemFontOfSize:16];
    [_btnCreate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnCreate setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [_btnCreate setTitle:@"Create" forState:UIControlStateNormal];
    [_btnCreate setTitle:@"Create" forState:UIControlStateHighlighted];
    _btnCreate.tag = 0;
    [_btnCreate addTarget:self action:@selector(buttonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnCreate];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCancel.backgroundColor = [UIColor colorWithRed:48/255.0 green:109/255.0 blue:200/255.0 alpha:1];
    _btnCancel.layer.masksToBounds = YES;
    _btnCancel.layer.cornerRadius = 5;
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [_btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnCancel setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [_btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [_btnCancel setTitle:@"Cancel" forState:UIControlStateHighlighted];
    _btnCancel.tag = 1;
    [_btnCancel addTarget:self action:@selector(buttonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnCancel];
    
    _overlayView = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [_overlayView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setFrame:(CGRect)frame{
    CGRect sFrame = CGRectMake(20, 30, frame.size.width - 40, frame.size.width - 60);
    
    [super setFrame:sFrame];
    _overlayView.frame = [[UIScreen mainScreen] bounds];
    
    CGFloat offsetX = 10;
    CGFloat offsetY = sFrame.size.height * 0.5 - 20;
    
    CGFloat offsetY1 = 50;
    _titleLabel.frame = CGRectMake(offsetX, offsetY1, sFrame.size.width - 2 * offsetX, 30);
    
    _textFiled.frame = CGRectMake(offsetX, offsetY, sFrame.size.width - 2 * offsetX, 40);

//    offsetY += _titleLabel.frame.size.height + 10;
//    _lineLabel.frame = CGRectMake(offsetX, offsetY, sFrame.size.width - 2 * offsetX, 1);
    
    offsetY = sFrame.size.height - 60;
    CGFloat btnWidth = (sFrame.size.width - offsetX * 3)/2.0;
    _btnCreate.frame = CGRectMake(offsetX, offsetY, btnWidth, 35);
    _btnCancel.frame = CGRectMake(offsetX * 2 + btnWidth, offsetY, btnWidth, 35);
}

#pragma mark ---animation methods
-(void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [_textFiled becomeFirstResponder];
    }];
}

- (void)fadeOut
{
    [self endEditing:YES];
    
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [_overlayView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (void)pop
{
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:_overlayView];
    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f, keywindow.bounds.size.height/2.0f-100);
    [self fadeIn];
}

- (void)dismiss
{
    [self fadeOut];
}

-(void)buttonClickedAction:(UIButton *)sender
{
    if([_delegate respondsToSelector:@selector(buttonClickedAtIndex:withText:)]){
        [_delegate buttonClickedAtIndex:sender.tag withText:_textFiled.text];
    }
    
    [self dismiss];
}

-(void)textFiledEdingChanged
{
    [_textFiled sendActionsForControlEvents:UIControlEventValueChanged];
}

#define mark - UITouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self dismiss];
}

-(void)dealloc
{
    [_textFiled removeTarget:self action:@selector(textFiledEdingChanged) forControlEvents:UIControlEventEditingChanged];
}
@end
