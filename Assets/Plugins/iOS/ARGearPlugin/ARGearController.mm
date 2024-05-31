//
//  ARGearController.m
//  ARGearPlugin
//
//  Copyright © 2019 Seerslab. All rights reserved.
//

#import "ARGearController.h"
#import <ARGear/ARGear.h>
#import "ARGCamera.h"

//#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>


@interface ARGearController () <ARGCameraDelegate, ARGSessionDelegate>
{
    int renderBuffer_width;
    int renderBuffer_height;
}
@property (nonatomic, strong) ARGSession *argSession;       // ARGear Session (ARGear main handler)
@property (nonatomic, strong) ARGMedia *argMedia;           // ARGear Media (ARGear Video / Photo)
@property (nonatomic, strong) ARGCamera *camera;            // ARGear Camera
@property (nonatomic, strong) ARGFrame *argFrame;            // ARGear Frame

@property(nonatomic, assign, nullable) CVPixelBufferRef renderBuffer;
@end


@implementation ARGearController

- (id)init {
    self = [super init];
    if ( self ) {
        renderBuffer_width = 0;
        renderBuffer_height = 0;
    }
    return self;
}

- (void)initialize:(char *)apiHost :(char *)apiKey :(char *)apiSecretKey :(char *)apiAuthKey :(int *)config
{
    ApiHost = [NSString stringWithUTF8String:apiHost];
    ApiKey = [NSString stringWithUTF8String:apiKey];
    ApiSecretKey = [NSString stringWithUTF8String:apiSecretKey];
    ApiAuthKey = [NSString stringWithUTF8String:apiAuthKey];
    ApiConfig = config;

    [self setupConfig];
    [self setupCamera];
}

// MARK: - ARGearSDK setup & run
- (void)setupConfig {
    ARGConfig *argConfig = [[ARGConfig alloc] initWithApiURL:ApiHost apiKey:ApiKey secretKey:ApiSecretKey authKey:ApiAuthKey];

    ARGInferenceFeature inferenceFeature = 0;
    if (ApiConfig != nil) {
        int configLength = sizeof(ApiConfig) / sizeof(*ApiConfig);
        for (int i = 0; i < configLength; i++) {
            if (ApiConfig[i] == 0) {
                inferenceFeature |= ARGInferenceFeatureFaceLowTracking;
            }
        }
    }

    NSError * error;
    _argSession = [[ARGSession alloc] initWithARGConfig:argConfig feature:inferenceFeature error:&error];
    _argSession.delegate = self;
}

- (void)runARGSession {
    [_argSession run];
}

- (void)resume {
    if (_argSession) {
        [_argSession run];
    }
}

- (void)pause {
    if (_argSession) {
        [_argSession pause];
    }
}

- (void)destroy {
    if (_argSession) {
        [_argSession destroy];
    }
}

// MARK: - Camera , Scene, Media setup & run
- (void)setupCamera {
    _camera = [[ARGCamera alloc] init];

    [_camera setDelegate:self];
    [_camera startCamera];

    _argMedia = [[ARGMedia alloc] init];
    [self setupARGMedia];
}

- (void)setupARGMedia {
    [_argMedia setVideoConnection:[_camera videoConnection]];
    [_argMedia setVideoDevice:[_camera device]];
    [_argMedia setMediaRatio:ARGMediaRatio_16x9];
    [_argMedia setVideoDeviceOrientation:[_camera videoOrientation]];
}

// MARK: - ARGCamera Delegate
- (void)didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {

//    CVPixelBufferRef sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    int width = (int)CVPixelBufferGetWidthOfPlane(sourcePixelBuffer, 0);
//    int height = (int)CVPixelBufferGetHeightOfPlane(sourcePixelBuffer, 0);
//    NSLog(@"didOutputSampleBuffer = %d, %d", width, height);

    [_argSession updateSampleBuffer:sampleBuffer fromConnection:connection];
}

- (void)didOutputMetadataObjects:(nonnull NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(nonnull AVCaptureConnection *)connection {

    [_argSession updateMetadataObjects:metadataObjects fromConnection:connection];
}

// MARK: - ARGearARGSession delegate
- (void)didUpdateFrame:(nonnull ARGFrame *)frame {
//    ARGFaces *faces = frame.faces;
//    NSArray *faceList = faces.faceList;
//    for (ARGFace *face in faceList) {
//        if(face.isValid) {
////            NSLog(@"landmarkcount = %d", (int)face.landmark.landmarkCount);
//        }
//    }

    _argFrame = frame;
    if ([frame renderedPixelBuffer]) {
        if (_renderBuffer) {
            CVPixelBufferRelease(_renderBuffer);
            _renderBuffer = nil;
        }

        _renderBuffer = [frame renderedPixelBuffer];
        CVPixelBufferRetain(_renderBuffer);
    }
}

-(int)getRenderOutputWidth {
//    NSLog(@"getRenderOutputWidth = %d", renderBuffer_width);
    return renderBuffer_width;
}

-(int)getRenderOutputHeight {
//    NSLog(@"getRenderOutputHeight = %d", renderBuffer_height);
    return renderBuffer_height;
}

-(void*)getRenderOutputMTLTextureId {
    if (metalDevice == nil) {
        CVReturn err;
        metalDevice = MTLCreateSystemDefaultDevice();
        err =
                CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, metalDevice, NULL, &metalTextureCache);

        if ( err ) {
            NSLog( @"Error at CVMetalTextureCacheCreate %d", err );
        }
    }

    CVPixelBufferRef renderedPixelBuffer = _renderBuffer;
    if (renderedPixelBuffer == NULL) {
        return nil;
    }

    id<MTLTexture> textureBGRA = nil;
    renderBuffer_width = (int)CVPixelBufferGetWidthOfPlane(renderedPixelBuffer, 0);
    renderBuffer_height = (int)CVPixelBufferGetHeightOfPlane(renderedPixelBuffer, 0);
    MTLPixelFormat pixelFormat = MTLPixelFormatBGRA8Unorm;

    CVMetalTextureRef texture = NULL;

    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
            metalTextureCache,
            renderedPixelBuffer,
            NULL,
            pixelFormat,
            renderBuffer_width,
            renderBuffer_height,
            0,
            &texture);
    if (status == kCVReturnSuccess) {
//        NSLog(@"CVMetalTextureCacheCreateTextureFromImage success(%d)", status);
        textureBGRA = CVMetalTextureGetTexture(texture);
        CFRelease(texture);
    } else {
        NSLog(@"CVMetalTextureCacheCreateTextureFromImage failed(%d)", status);
    }

//    NSLog(@"getRenderOutputMTLTextureId : %@", (__bridge_retained void*)textureBGRA);

    return (__bridge_retained void*)textureBGRA;
}

-(int)getRenderOutputGLTextureId {
    EAGLContext *context = [EAGLContext currentContext];
    if (context == nil) {
        return 0;
    }

    if (eaglContext == nil || eaglContext != context) {
        CVReturn err;
        eaglContext = context;
        err =  CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,nil,eaglContext,nil,&glTextureCache);
        if ( err ) {
            NSLog( @"Error at CVOpenGLESTextureCacheCreate %d", err );
        }
    }

    CVPixelBufferRef renderedPixelBuffer = _renderBuffer;
    if (renderedPixelBuffer == NULL) {
        return 0;
    }

    // Create a CVOpenGLESTexture from a CVPixelBufferRef
    renderBuffer_width = (int)CVPixelBufferGetWidthOfPlane(renderedPixelBuffer, 0);
    renderBuffer_height = (int)CVPixelBufferGetHeightOfPlane(renderedPixelBuffer, 0);

    if (renderBuffer_width * renderBuffer_height == 0) return 0;

    CVOpenGLESTextureRef texture = NULL;
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage( kCFAllocatorDefault,
            glTextureCache,
            renderedPixelBuffer,
            NULL,
            GL_TEXTURE_2D,
            GL_RGBA,
            (GLsizei)renderBuffer_width,
            (GLsizei)renderBuffer_height,
            GL_BGRA,
            GL_UNSIGNED_BYTE,
            0,
            &texture );

    if ( ! texture || err ) {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);
        return 0;
    }

    NSLog(@"getRenderOutputGLTextureId : %d", (int)CVOpenGLESTextureGetName( texture ));

    return (int)CVOpenGLESTextureGetName( texture );
}

-(int)getSegmentationTextureId {
    return -1;
}

-(void)setDrawLandmark:(BOOL)isVisible {
    if (isVisible) {
        ARGInferenceDebugOption debugOption = ARGInferenceOptionDebugFaceLandmark2D;
        [_argSession setInferenceDebugOption:debugOption];
    } else {
        ARGInferenceDebugOption debugOption = ARGInferenceOptionDebugNON;
        [_argSession setInferenceDebugOption:debugOption];
    }
}

-(int)getTackedFaceNum {
    NSArray *fList = [[_argFrame faces] faceList];
    return (int)fList.count;
}

-(BOOL)trackedFaceValidation:(int)index {
    NSArray *fList = [[_argFrame faces] faceList];
    return [fList[index] isValid];
}

-(double*)getRotationMatrix:(int)index {
    NSArray *fList = [[_argFrame faces] faceList];
    simd_double3x3 matrix = [fList[index] rotation_matrix];

    double* returnValue = new double[9];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            returnValue[i * j] = matrix.columns[i][j];
        }
    }
    return returnValue;
}

-(double*)getTranslationVector:(int)index {
    NSArray *fList = [[_argFrame faces] faceList];
    simd_double3 vector = [fList[index] translation_vector];

    double* returnValue = new double[3];
    for (int i = 0; i < 3; i++) {
        returnValue[i] = vector[i];
    }
    return returnValue;
}

-(float*)getBlendShapeWeight:(int)index {
    return nil;
}

-(void)changeCameraFacing {
    [_argSession pause];

    __weak ARGearController *weakSelf = self;
    [_camera toggleCamera:^{
        [self setupARGMedia];
        
        [[weakSelf argSession] run];
    }];
}

-(char*)requestSignedUrl :(char*)fileUrl :(char*)title :(char*)type {
    __block NSString* callbackString = nil;
    
    ARGAuthCallback callback = ^(NSString *url, ARGStatusCode code) {
        if (code == ARGStatusCode_SUCCESS) {
            callbackString = url;
        } else {
            callbackString = [NSString stringWithFormat:@"%d", (int)code];
        }
    };

    [[_argSession auth] requestSignedUrlWithUrl:[NSString stringWithUTF8String:fileUrl]
                                      itemTitle:[NSString stringWithUTF8String:title]
                                       itemType:[NSString stringWithUTF8String:type]
                                     completion:callback];
    return strdup([callbackString UTF8String]);
}

-(void)setItem:(int)itemType
              :(char*)filePath
              :(char*)uuid
       success:(void (^)(void))successBlock
          fail:(void (^)(NSString* msg))failBlock{
    
    ARGContentsCallback callback = ^(BOOL success, NSString* _Nullable msg) {
        if (success == YES) {
            successBlock();
        } else {
            failBlock(msg);
        }
    };
    
    [[_argSession contents] setItemWithType:(ARGContentItemType)itemType
                           withItemFilePath:[NSString stringWithUTF8String:filePath]
                                 withItemID:[NSString stringWithUTF8String:uuid]
                                 completion:callback];
}

-(void)setFilterLevel:(float)level {
    [[_argSession contents] setFilterLevel:level];
}

-(void)setBeauty:(float *)values {
    [[_argSession contents] setBeautyValues:values];
}

-(void)setBulge:(int)type {
    [[_argSession contents] setBulge:(ARGContentItemBulge)type];
}

-(void)clearContents:(int)type {
    [[_argSession contents] clear:(ARGContentItemType)type];
}

@end
