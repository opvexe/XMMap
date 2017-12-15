//
//  CustomPinAnnotationView.m
//  appNYB2
//
//  Created by Facebook on 2017/11/16.
//  Copyright © 2017年 leetcode. All rights reserved.
//

#import "NYBCustomPinAnnotationView.h"

@interface NYBCustomPinAnnotationView()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *subTitleLabel;
@property(nonatomic,strong)UIView *contentView;
@end
@implementation NYBCustomPinAnnotationView

- (instancetype)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView *contentView=[[ UIView alloc] init];
        [contentView setBackgroundColor:[ UIColor clearColor]];
        _contentView=contentView;
        
        UILabel *lable=[[ UILabel alloc] init];
        lable.textColor=[ UIColor blackColor];
        lable.font=[ UIFont systemFontOfSize:13];
        _titleLabel=lable;
        [contentView addSubview:lable];
        [self addSubview:contentView];
        
        UILabel *subLable=[[ UILabel alloc] init];
        subLable.textColor=[ UIColor blackColor];
        subLable.font=[ UIFont systemFontOfSize:13];
        _subTitleLabel=subLable;
        [contentView addSubview:subLable];
        [self addSubview:contentView];
        
    }
    return self;
    
}

-(void)InitDataBaiDuWithModel:(NYBAnnotationUserInfo *)model{
    
    _titleLabel.text= model.gname;
    _subTitleLabel.text = [NSString stringWithFormat:@"%@ kg",model.countweight];
    //计算高度
    CGFloat Width = [_titleLabel.text sizeWithFont:[UIFont systemFontOfSize: 13] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 21) lineBreakMode:NSLineBreakByWordWrapping].width;
    CGFloat w_wight = [_subTitleLabel.text sizeWithFont:[UIFont systemFontOfSize: 13] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 21) lineBreakMode:NSLineBreakByWordWrapping].width;
    
    [_titleLabel setFrame:CGRectMake(15,5, Width, 20)];
    [_subTitleLabel setFrame:CGRectMake(CGRectGetMidX(_titleLabel.frame)-w_wight/2, CGRectGetMidY(_titleLabel.frame)+10, w_wight, 20)];

    if (Width >w_wight) {
          [_contentView setFrame:CGRectMake(0, 0, Width+30, 50)];
    }else{
         [_contentView setFrame:CGRectMake(0, 0, w_wight+30, 50)];
    }
    
    //创建Path
    CGRect rect = _contentView.bounds;
    CGMutablePathRef layerpath = CGPathCreateMutable();
    CGPathMoveToPoint(layerpath, NULL, 0, 0);
    CGPathAddLineToPoint(layerpath, NULL, CGRectGetMaxX(rect), 0);
    CGPathAddLineToPoint(layerpath, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    CGPathAddLineToPoint(layerpath, NULL, 45, CGRectGetMaxY(rect));
    CGPathAddLineToPoint(layerpath, NULL, 37.5, CGRectGetMaxY(rect)+5);
    CGPathAddLineToPoint(layerpath, NULL, 30, CGRectGetMaxY(rect));
    CGPathAddLineToPoint(layerpath, NULL, 0, CGRectGetMaxY(rect));
    CGPathAddLineToPoint(layerpath, NULL, 0, 0);

    CAShapeLayer *shapelayer=[CAShapeLayer  layer];
    UIBezierPath *path=[ UIBezierPath  bezierPathWithCGPath:layerpath];
    shapelayer.path=path.CGPath;
    shapelayer.fillColor=UIColorFromRGB(0xE6F3BD).CGColor;
    shapelayer.strokeColor = UIColorFromRGB(0x17BAEF).CGColor;
    shapelayer.cornerRadius= 10.0;
    [_contentView.layer addSublayer:shapelayer];
    [_contentView bringSubviewToFront:_titleLabel];
    [_contentView bringSubviewToFront:_subTitleLabel];
    self.bounds=_contentView.bounds;
    
    CGPathRelease(layerpath);
    
    [self layoutIfNeeded];
    [self setNeedsDisplay];
}


-(void)layoutSubviews{
    
    [ super layoutSubviews];
}
@end
