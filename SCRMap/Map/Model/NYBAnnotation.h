//
//  NYBAnnotation.h
//  appNYB2
//
//  Created by Facebook on 2017/11/16.
//  Copyright © 2017年 leetcode. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,NYBBatteryStatusType) {
    /**
     * 未抢单
     */
    NYBBatteryStatusTypeGreenColor = 0,
    /**
     * 已抢单
     */
    NYBBatteryStatusTypeRedColor  = 1,
};

@class NYBAnnotationUserInfo;
#pragma mark     ----------   自定义大头针  -----------
@interface NYBAnnotation : NSObject<BMKAnnotation>

/**
 * 编码信息
 */
@property(nonatomic,assign) CLLocationCoordinate2D coordinate;

/**
 *  大头针用户信息
 */
@property(nonatomic,strong) NYBAnnotationUserInfo *userInfoModel;
@end



#pragma mark   ----------    大头针里用户信息   ------------------

@interface NYBAnnotationUserInfo : NSObject

/**
 *  电池状态 - 红色已取 ， 绿色未取
 */
@property (nonatomic,assign) NYBBatteryStatusType type;

/**
 * 地址
 */
@property(nonatomic,copy)NSString *address;

/**
 * Description
 */
@property (nonatomic,copy) NSString *area_id;

/**
 * Description
 */
@property (nonatomic,copy) NSString *area_x;


/**
 Description
 */
@property (nonatomic,copy) NSString *area_y;


/**
 * 数量
 */
@property (nonatomic,copy) NSString *countnum;


/**
 * 重量
 */
@property (nonatomic,copy) NSString *countweight;


/**
 *
 */
@property (nonatomic,copy) NSString *gname;

/**
 Description
 */
@property (nonatomic,copy) NSString *ID;


/**
 * 用户头像
 */
@property (nonatomic,copy) NSString *img_url;

/**
 Description
 */
@property (nonatomic,copy) NSString *phone;

/**
 Description
 */
@property (nonatomic,copy) NSString *uid;

/**
 Description
 */
@property (nonatomic,copy) NSString *uname;
@end
