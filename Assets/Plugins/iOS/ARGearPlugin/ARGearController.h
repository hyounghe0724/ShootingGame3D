//
//  ARGearController.h
//  ARGearPlugin
//
//  Copyright © 2019 Seerslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <GLKit/GLKit.h>
//#import <CoreImage/CoreImage.h>

#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

@class ARGSession,ARGFrame;
@interface ARGearController : NSObject
{
    id <MTLDevice> metalDevice;
    CVMetalTextureCacheRef metalTextureCache;

    EAGLContext *eaglContext;
    CVOpenGLESTextureCacheRef glTextureCache;

    NSString* ApiHost;
    NSString* ApiKey;
    NSString* ApiSecretKey;
    NSString* ApiAuthKey;
    int*      ApiConfig;
}

- (void)initialize:(char*)apiHost :(char*)apiKey :(char*)apiSecretKey :(char*)apiAuthKey :(int*)config;
- (void)runARGSession;
- (void)resume;
- (void)pause;
- (void)destroy;

-(int)getRenderOutputWidth;
-(int)getRenderOutputHeight;
-(void* __nullable)getRenderOutputMTLTextureId;
-(int)getRenderOutputGLTextureId;
-(int)getSegmentationTextureId;

-(void)changeCameraFacing;
-(char*)requestSignedUrl:(char*)fileUrl :(char*)title :(char*)type;
-(void)setItem:(int)type
              :(char*)filePath
              :(char*)uuid
       success:(nullable void (^)(void))successBlock
          fail:(nullable void (^)(NSString* _Nullable msg))failBlock;
-(void)setFilterLevel:(float)level;
-(void)setBulge:(int)type;
-(void)setBeauty:(float*)values;
-(void)clearContents:(int)type;

-(void)setDrawLandmark:(BOOL)isVisible;
-(BOOL)trackedFaceValidation:(int)index;
-(double*)getRotationMatrix:(int)index;
-(double*)getTranslationVector:(int)index;
-(float*)getBlendShapeWeight:(int)index;


@end

NS_ASSUME_NONNULL_END
