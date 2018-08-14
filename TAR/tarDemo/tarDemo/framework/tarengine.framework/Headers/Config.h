//
//  Config.h
//  tarengine
//
//  Created by carmzhu on 2018/4/18.
//  Copyright © 2018年 carmzhu. All rights reserved.
//

#ifndef Config_h
#define Config_h


//Common BOOLEAN settings
#define ENABLE_CAMERA   0x1001
#define NEED_IMU        0x1002
#define NEED_IMAGE      0x1003
//#define ENABLE_DUMP     0x1003
//#define ENABLE_RAW_DUMP 0x1004
#define ENABLE_EXTERNAL_SOURCE      0x1005
#define ENABLE_LOGGER   0x1006
#define EANBLE_PERMISSION_VERIFY    0x1007

#define SCREEN_ORIENTATION  0x1101
#define CAMERA_FRAME_WIDTH  0x1102
#define CAMERA_FRAME_HEIGHT 0x1103
#define INPUT_IMAGE_FORMAT  0x1104
#define CAMERA_FACE         0x1105
//#define EXTERNAL_SOURCE_TYPE    0x1106

#define APP_ID      0x1201
#define APP_KEY     0x1202

//marker setting
#define ENABLE_CLOUD_MARKER 0x2003
#define MAX_MARKER_NUMBER   0x2101
#define NTF_CONF_FILE_PATH  0x2201

//cloud setting
#define ENABLE_MOTION_DETECT 0x3001
#define ENABLE_FEATURE_DETECT   0x3002
#define ENABLE_CLOUD_JPG_SAVING 0x3003

#define CLOUD_REQUEST_INTERVAL_MS   0x3101
#define CLOUD_REQUEST_RETRY_INTERVAL_MS 0x3102
#define CLOUD_DETECT_FEATURE_MIN_NUM    0x3103
#define CLOUD_DETECT_MAX_POINT_NUM      0x3104
#define CLOUD_REQUEST_TYPE              0x3105

#define CLOUD_URL                       0x3201
#define CLOUD_APP_ID                    0x3202
#define CLOUD_APP_KEY                   0x3203
#define CLOUD_IMAGE_SET_IDS             0x3204

#define CLOUD_REQUEST_TYPE_ALL          0
#define CLOUD_REQUEST_TYPE_RECOGNISE_AND_LOCATION   1
#define CLOUD_REQUEST_TYPE_SEARCH       2

#define CAMERA_FACE_FRONT               0
#define CAMERA_FACE_BACK                1

#define SCREEN_ORIENTATION_LANDSCAPE    0
#define SCREEN_ORIENTATION_PORTRAIT     1

#define INPUT_IMAGE_FORMAT_IOS_BGRA      0

#define MARKER_APPLICATION_ID 1
#define MARKERLESS_APPLICATION_ID 2
#define FACE_APPLICATION_ID 3

typedef NS_ENUM(NSInteger, ARType) {
    MARKER,
    FACE,
    LOCATION_2D,
    MARKERLESS_WITH_OBJECT_RECOGNITION
};

@interface Config : NSObject
@property(nonatomic,readwrite) int screenOrientation;
@property(nonatomic,readwrite) int frameWidth;
@property(nonatomic,readwrite) int frameHeight;
@property(nonatomic,readwrite) int inputImageFormat;
@property(nonatomic,readonly) int cameraFace;
@property(nonatomic,readonly) int maxMarkerNumber;
@property(nonatomic,readwrite) NSString* ntfConfigFilePath;
@property(nonatomic,readwrite) int cloudRequestType;
@property(nonatomic,readwrite) int cloudRequestIntervalMs;
@property(nonatomic,readwrite) int cloudRequestRetryIntervalMs;
@property(nonatomic,readwrite) int cloudDetectFeatureMinNum;
@property(nonatomic,readwrite) int cloudDetectMaxPointNum;
@property(nonatomic,readwrite) NSString* cloudAppId;
@property(nonatomic,readwrite) NSString* cloudAppKey;
@property(nonatomic,readwrite) NSString* cloudImageSetId;
@property(nonatomic,readwrite) NSString* cloudUrl;
@property(nonatomic,readwrite) NSString* cloudUserId;
@property(nonatomic,readwrite) NSString* faceConfFilePath;
@property(nonatomic,readwrite) OSType videoOutputFormat;

@property(nonatomic,readwrite) BOOL enableCamera;
@property(nonatomic,readwrite) BOOL needImu;
@property(nonatomic,readwrite) BOOL needImage;
@property(nonatomic,readwrite) BOOL enableDump;
@property(nonatomic,readwrite) BOOL enableRawDump;
@property(nonatomic,readwrite) BOOL enableExternalSource;
@property(nonatomic,readwrite) BOOL enableLogger;
@property(nonatomic,readwrite) BOOL enableCloud;
@property(nonatomic,readwrite) BOOL enableCloudMarker;
@property(nonatomic,readwrite) BOOL enableMotionDetect;
@property(nonatomic,readwrite) BOOL enableFeatureDetect;
@property(nonatomic,readwrite) BOOL enableCloudImageSaving;
@property(nonatomic,readonly) BOOL enablePermissionVerify;

-(void)enableMarker;
-(BOOL)markerEnabled;
-(void)enableMarkerless;
-(BOOL)markerlessEnabled;
-(void)enableFace;
-(BOOL)faceEnabled;
-(instancetype)init;
//-(void)enable:(int)code;
//-(void)disable:(int)code;
//-(BOOL)isEnabled:(int)code;
//-(void)setIntegerValue:(int)code;
//-(int)getIntegerValue:(int)code;
//-(void)setStringValue:(int)code;
//-(NSString*)getStringValue:(int)code;
@end


#endif /* Config_h */
