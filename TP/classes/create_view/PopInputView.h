//
//  YLPopInputPasswordView.h
//  YouLanAgents
//
//  Created by lqcjdx on 15/5/27.
//  Copyright (c) 2015年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PopInputViewDelegate <NSObject>

-(void)buttonClickedAtIndex:(NSUInteger)index withText:(NSString *)text;

@end

@interface PopInputView : UIView
@property(nonatomic,assign)id<PopInputViewDelegate>delegate;

-(void)pop;

-(void)dismiss;

@end
