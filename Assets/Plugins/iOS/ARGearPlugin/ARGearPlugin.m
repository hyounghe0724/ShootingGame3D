
#import "ARGearPlugin.h"
#import "ARGearController.h"


static ARGearController *argearController = nil;

void ARGearInit(char* apiUrl, char* apiKey, char* apiSecretKey, char* authKey, int* config) {
    argearController = [[ARGearController alloc] init];
    [argearController initialize :apiUrl :apiKey :apiSecretKey :authKey :config];
    [argearController runARGSession];
}

void ARGearResume() {
    [argearController resume];
}

void ARGearPause() {
    [argearController pause];
}

void ARGearDestroy() {
    [argearController destroy];
}

int ARGearGetRenderWidth() {
    return [argearController getRenderOutputWidth];
}

int ARGearGetRenderHeight() {
    return [argearController getRenderOutputHeight];
}

float ARGearGetHorizontalViewAngle() {
    return 30;
}

void* ARGearGetRenderedMTLTexID() {
    return [argearController getRenderOutputMTLTextureId];
}

int ARGearGetRenderedGLTexID() {
    return [argearController getRenderOutputGLTextureId];
}

int ARGearGetSegmentationTextureId() {
    return -1;
}

void ARGearSetDrawLandmark(bool isVisible) {
    [argearController setDrawLandmark:isVisible];
}

bool ARGearTrackedFaceValidation(int index) {
    return [argearController trackedFaceValidation:index];
}

double* ARGearGetRotationMatrix(int index) {
    return [argearController getRotationMatrix:index];
}

double* ARGearGetTranslationVector(int index) {
    return [argearController getTranslationVector:index];
}

float* ARGearGetBlendShapeWeight(int index) {
    return [argearController getBlendShapeWeight:index];
}

float* ARGearGetLandmark(int index) {
    return nil;
}

float* ARGearGetMesh(int index) {
    return nil;
}

void ARGearChangeCameraFacing() {
    [argearController changeCameraFacing];
}

char* ARGearRequestSignedUrl(char* url, char* title, char* uuid) {
    return [argearController requestSignedUrl:url :title :uuid];
}

void ARGearSetItem(int type, char* path, char* uuid, CONTENTS_LOADING_RESULT_CALLBACK callback) {
    if (argearController == nil) return;
    [argearController setItem:type :path :uuid success:^{
        callback(true, "success");
    } fail:^(NSString * _Nullable msg) {
        callback(false, "fail");
    }];
}

void ARGearSetFilterLevel(float level) {
    [argearController setFilterLevel:level];
}

void ARGearSetBeauty(float* values) {
    [argearController setBeauty:values];
}

void ARGearSetBulge(int type) {
    [argearController setBulge :type];
}

void ARGearClearContents(int type) {
    [argearController clearContents :type];
}
