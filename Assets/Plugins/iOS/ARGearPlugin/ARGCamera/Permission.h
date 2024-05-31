//
//  Permission.h
//  ARGEARSample
//
//  Created by Jihye on 19/08/2019.
//  Copyright © 2019 Seerslab. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PermissionGrantedBlock)(void);
typedef void (^PermissionEndBlock) (void);

typedef NS_ENUM(NSInteger, PermissionActionType) {
    PermissionActionTypeCamera          = 0,
    PermissionActionTypeLibrary         = 1,
    PermissionActionTypeMic             = 2,
};

typedef NS_ENUM(NSInteger, PermissionLevel) {
    PermissionLevelGranted      = 0,            // 필수권한이 모두 허용되어 있는 상태
    PermissionLevelRestricted   = 1,            // 필수권한이 일부 허용되어 있는 상태
    PermissionLevelNone         = 2,            // 권한허용이 하나도 안되어 있음 (PermissionView 띄워줌)
};

@interface Permission : NSObject

@property (copy, nonatomic) PermissionEndBlock permissionGrantedBlock;
@property (copy, nonatomic) PermissionEndBlock permissionRestrictedBlock;

@property (copy, nonatomic) PermissionGrantedBlock granted;

- (void)permissionAllAllowAction:(PermissionEndBlock)endedBlock;
- (void)openSettings;
- (PermissionLevel)getPermissionLevel;

@end

NS_ASSUME_NONNULL_END
