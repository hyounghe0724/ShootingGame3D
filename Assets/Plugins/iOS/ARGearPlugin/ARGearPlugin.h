
#import <Foundation/Foundation.h>

////! Project version number for ARGearPlugin.
//FOUNDATION_EXPORT double ARGearPluginVersionNumber;
//
////! Project version string for ARGearPlugin.
//FOUNDATION_EXPORT const unsigned char ARGearPluginVersionString[];
//
//// In this header, you should import all the public headers of your framework using statements like #import <ARGearPlugin/PublicHeader.h>


#ifdef __cplusplus
extern "C" {
#endif

typedef void (CONTENTS_LOADING_RESULT_CALLBACK)(bool success, char* msg);

// ARGear Unity Plugin
void ARGearInit(char* apiUrl, char* apiKey, char* apiSecretKey, char* authKey, int* config);
void ARGearResume(void);
void ARGearPause(void);
void ARGearDestroy(void);

int ARGearGetRenderWidth(void);
int ARGearGetRenderHeight(void);
float ARGearGetHorizontalViewAngle(void);
void* ARGearGetRenderedMTLTexID(void);
int ARGearGetRenderedGLTexID(void);
int ARGearGetSegmentationTextureId(void);

void ARGearSetDrawLandmark(bool isVisible);
bool ARGearTrackedFaceValidation(int index);
double* ARGearGetRotationMatrix(int index);
double* ARGearGetTranslationVector(int index);
float* ARGearGetBlendShapeWeight(int index);
float* ARGearGetLandmark(int index);
float* ARGearGetMesh(int index);

void ARGearChangeCameraFacing(void);
char* ARGearRequestSignedUrl(char* url, char* title, char* uuid);
void ARGearSetItem(int type, char* path, char* uuid, CONTENTS_LOADING_RESULT_CALLBACK callback);
void ARGearSetFilterLevel(float level);
void ARGearSetBeauty(float* values);
void ARGearSetBulge(int type);
void ARGearClearContents(int type);

#ifdef __cplusplus
}
#endif
