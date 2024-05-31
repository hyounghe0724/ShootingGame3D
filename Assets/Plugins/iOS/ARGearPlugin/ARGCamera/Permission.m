//
//  Permission.m
//  ARGEARSample
//
//  Created by Jihye on 19/08/2019.
//  Copyright © 2019 Seerslab. All rights reserved.
//

#import "Permission.h"
#import <Photos/Photos.h>

@implementation Permission

// 카메라 권한
- (void)allowCameraAction:(void(^)(void))completionHandler {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoStatus == AVAuthorizationStatusDenied) {
        // 거부했다면 설정 화면으로 이동해서 허용해줘야만 함.
        dispatch_async( dispatch_get_main_queue(), ^{
//            [self openSettingsWithMessage:NSLocalizedString( @"permission_msg", @"계속하시려면 카메라, 마이크 및 사진 접근 권한을 허용해 주세요.")];
            completionHandler();
        });
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async( dispatch_get_main_queue(), ^{
                completionHandler();
            });
        }];
    }
}

// 라이브러리 권한
- (void)allowLibraryAction:(void(^)(void))completionHandler {
    PHAuthorizationStatus libraryStatus = [PHPhotoLibrary authorizationStatus];
    if (libraryStatus == PHAuthorizationStatusDenied) {
        // 거부했다면 설정 화면으로 이동해서 허용해줘야만 함.
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler();
        });
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async( dispatch_get_main_queue(), ^{
                BOOL authorizeStatus = (status == PHAuthorizationStatusAuthorized) ? YES : NO;
                completionHandler();
            });
        }];
    }
}

// 오디오 권한
- (void)allowMicAction:(void(^)(void))completionHandler {
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioStatus == AVAuthorizationStatusDenied) {
        // 거부했다면 설정 화면으로 이동해서 허용해줘야만 함.
        dispatch_async( dispatch_get_main_queue(), ^{
            completionHandler();
        });
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async( dispatch_get_main_queue(), ^{
                completionHandler();
            });
        }];
    }
}

// 전체 동의
- (void)permissionAllAllowAction:(PermissionEndBlock)endedBlock {

    // 확인 버튼 누르면 차례대로 확인
    [self allowCameraAction:^{
        [self allowLibraryAction:^{
            [self allowMicAction:^{
                [endedBlock invoke];
            }];
        }];
    }];
}

// 권한 허용이 어느정도 진행되어 있는지 판별
- (PermissionLevel)getPermissionLevel {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    PHAuthorizationStatus libraryStatus = [PHPhotoLibrary authorizationStatus];
    
    BOOL videoDetermined = (videoStatus == AVAuthorizationStatusNotDetermined) ? YES : NO;
    BOOL audioDetermined = (audioStatus == AVAuthorizationStatusNotDetermined) ? YES : NO;
    BOOL libraryDetermined = (libraryStatus == AVAuthorizationStatusNotDetermined) ? YES : NO;
    
    BOOL videoAuthorized = (videoStatus == AVAuthorizationStatusAuthorized) ? YES : NO;
    BOOL audioAuthorized = (audioStatus == AVAuthorizationStatusAuthorized) ? YES : NO;
    BOOL libraryAuthorized = (libraryStatus == AVAuthorizationStatusAuthorized) ? YES : NO;
    
    if (videoDetermined || audioDetermined || libraryDetermined) {
        // 하나라도 권한묻기가 실행이 안되어 있으면 None
        return PermissionLevelNone;
    }
    
    if (videoAuthorized && audioAuthorized && libraryAuthorized) {
        // 전부 허용시 granted
        return PermissionLevelGranted;
    }
    
    // 나머지는 다음 화면으로 넘어갈 수 없으므로 권한을 허용해주세요 화면 띄운다. (Restricted)
    return PermissionLevelRestricted;
}



@end
