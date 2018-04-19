//
//  DownLoadModel.h
//  DownLoad
//
//  Created by 卿伟 on 2018/4/17.
//  Copyright © 2018年 卿伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadModel : NSObject
@property (nonatomic, assign) float progess;
@property (nonatomic, assign) float totalUnitCount;//MB
@property (nonatomic, assign) float currentUnitCount;//MB
@end
