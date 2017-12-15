//
//  CustomPinAnnotationView.h
//  appNYB2
//
//  Created by Facebook on 2017/11/16.
//  Copyright © 2017年 leetcode. All rights reserved.
//

#import "NYBAnnotation.h"

@interface NYBCustomPinAnnotationView : BMKAnnotationView

@property(nonatomic,copy)NSString           *titleText;


-(void)InitDataBaiDuWithModel:(NYBAnnotationUserInfo *)model;
@end
