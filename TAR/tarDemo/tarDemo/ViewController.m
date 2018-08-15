//
//  ViewController.m
//  tarDemo
//
//  Created by carmzhu on 2018/4/18.
//  Copyright © 2018年 carmzhu. All rights reserved.
//

#import "ViewController.h"
#import <tarengine/Engine.h>
#import <tarengine/Config.h>
#import <tarengine/TARMarkerEngineHelper.h>
#import <tarengine/CloudHelper.h>
#import <tarengine/JSONDecoder.h>
#import <tarengine/CloudRetrievaMarkerInfo.h>
#import <tarengine/tarengine.h>
#import <tarengine/GLCube.h>
#import "GLImage.h"
#import "GLImageTexture.h"

@interface ViewController () <TAREngineMarkerDelegate, CloudResultDelegate,
TAREngineRenderDelegate, TAREngineStatusDelegate>
@property (nonatomic, strong) TAREngine *engine;
@property (nonatomic, strong) NSMutableArray *markerNames;
@property (nonatomic, assign) int currentVideoMarkerId;
@property (nonatomic, strong) GLCube *glCube;
@property (nonatomic, strong) GLImageRGB *glImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.engine = [[TAREngine alloc] initWithController:self];
    self.engine.useDefaultRender = NO;
    self.engine.renderDelegate = self;
    self.engine.statusDelegate = self;

    Config* config = _engine.config;
    [config enableMarker];

    //Attention: if you want to use marker function, you must set the appId and appKey
    //And only if you want to use a cloud marker function, you need to set image set id and userId
    //Attention, these parameters are examples, you should replace them with your own AppId and AppKey
    config.cloudAppId = @"27f82e9f59c31ea525d5419848269a06";
    config.cloudAppKey = @"d6d2d895d5d7cb25918d923a13786b63";

    [_engine configure];

    if ([config markerEnabled]) {
        TAREngineMarkerHelper* _helper = [_engine markerHelper];
        _helper.delegate = self;
    }

    [self setupTexture];

    [_engine resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_engine pause];

    //If you use no more, just call release
    [_engine releaseTAR];
    _engine = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //step8: release engine
}

- (void)setupTexture {
    self.glCube = [[GLCube alloc] init];

    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"dog" ofType:@"jpg"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    CGSize imageSize = image.size;

    GLImageTextureRGB *glTexture = [[GLImageTextureRGB alloc] init];
    glTexture.width = imageSize.width;
    glTexture.height = imageSize.height;
    glTexture.RGBA = [self getRGBAWithImage:image];

    self.glImage = [[GLImageRGB alloc] initWithSize:imageSize.width height:imageSize.height];
    [self.glImage setTexture:glTexture];
}

#pragma mark - Control Marker

- (void)addMarker {
    MarkerResource *marker = [[MarkerResource alloc] init];
    marker.mid = (int)self.markerNames.count + 1;
    marker.type = MARKER_TYPE_NFT;
    marker.name = @"cat";
    NSString *path = [[NSBundle mainBundle] pathForResource:marker.name ofType:@"jpg"];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    marker.jpegData = imageData;
    marker.jpegLength = (int)imageData.length;
    [_engine.markerHelper addMarker:marker];
}

- (void)deleteMarker {
    [self.engine.markerHelper deleteMarker:2];
}

#pragma mark - TAREngineMarkerDelegate

- (void)arFound:(int)mid {
    NSLog(@"%s mid = %d", __FUNCTION__, mid);
    if (mid == _currentVideoMarkerId) {
        [_engine resumeVideo];
    } else {
        //TODO: reset the video
    }
}

- (void)arLost:(int)mid {
    NSLog(@"%s arLost mid = %d", __FUNCTION__, mid);
    if (mid == _currentVideoMarkerId) {
        [_engine pauseVideo];
    }
}

- (void)onMarkerAdded:(MarkerResource*)markerResource succeed:(BOOL)succeed {
}

- (void)onMarkerDeleted:(int)mid succeed:(BOOL)succeed {
}

#pragma mark - TAREngineRenderDelegate

- (void)onDrawRect:(CGRect)rect frame:(id)frame projectionMatrix:(float*)projectionMatrix {

    if (frame == nil) { return; }
//    [self.glImage glDraw];

    if ([frame isKindOfClass:[Frame class]]) {
        Frame *resFrame = (Frame *)frame;
        if ([resFrame.image isKindOfClass:[ImageFrame class]]) {
            // 每帧的图片数据
//            ImageFrame *image = (ImageFrame *)resFrame.image;
//            UIImage *backgroudImage = [self imageFromPixelBuffer:image.data];
        }
        for (MarkerRecognition *marker in resFrame.recognitions) {
            int markerId = marker.mid;
            GLKMatrix4 modelViewMatrix = marker.modelViewMatrix;
            float *corners = marker.corners;
            ImageFrame *imageFrame = (ImageFrame *)resFrame.image;
            GLKMatrix4 markerProjectionMatrix = GLKMatrix4Make(projectionMatrix[0], projectionMatrix[1], projectionMatrix[2], projectionMatrix[3], projectionMatrix[4], projectionMatrix[5], projectionMatrix[6], projectionMatrix[7], projectionMatrix[8], projectionMatrix[9], projectionMatrix[10], projectionMatrix[11], projectionMatrix[12], projectionMatrix[13], projectionMatrix[14], projectionMatrix[15]);

//                        [self.glCube glDraw:markerProjectionMatrix viewM:modelViewMatrix];
            float *cornersInOpenGL = [self convertOpenGL:resFrame cornors:corners];
            [self.glImage glDraw:YES corners:cornersInOpenGL projectionM:markerProjectionMatrix viewM:modelViewMatrix];
        }
    }
}

#pragma mark - TAREngineStatusDelegate

- (void)onStarted {
    [self addMarker];
}

- (void)onPaused {
}

#pragma mark - Util

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    CVImageBufferRef imageBuffer =  pixelBufferRef;

    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);

    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);

    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}

- (unsigned char *)getRGBAWithImage:(UIImage *)image {
    int RGBA = 4;

    CGImageRef imageRef = [image CGImage];

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *) malloc(width * height * sizeof(unsigned char) * RGBA);
    NSUInteger bytesPerPixel = RGBA;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    return rawData;
}

- (float *)convertOpenGL:(Frame *)f cornors:(float *)mCornor {
    float squareCoords[8];
    float tmp[8];
    float xR = 0.0F;
    float yR = 0.0F;
    float img_w = (float)[(ImageFrame *)f.image width];
    float img_h = (float)[(ImageFrame *)f.image height];
    float screenW = 0.0F;
    float screenH = 0.0F;
    screenW = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    screenH = MIN(self.view.bounds.size.width, self.view.bounds.size.height);

    float rScreen = screenW / screenH;
    float rImage = img_w / img_h;
    float diffy;
    float tmp0[8];
    if (rScreen >= rImage) {
        xR = screenW / img_w;
        yR = screenW / img_w;
        diffy = (img_h - screenH * img_w / screenW) / 2.0F;
        tmp0[0] = mCornor[6] * xR;
        tmp0[1] = (mCornor[7] - diffy) * yR;
        tmp0[2] = mCornor[0] * xR;
        tmp0[3] = (mCornor[1] - diffy) * yR;
        tmp0[4] = mCornor[2] * xR;
        tmp0[5] = (mCornor[3] - diffy) * yR;
        tmp0[6] = mCornor[4] * xR;
        tmp0[7] = (mCornor[5] - diffy) * yR;
    } else {
        xR = screenH / img_h;
        yR = screenH / img_h;
        diffy = (img_w - screenW * img_h / screenH) / 2.0F;
        tmp0[0] = (mCornor[6] - diffy) * xR;
        tmp0[1] = mCornor[7] * yR;
        tmp0[2] = (mCornor[0] - diffy) * xR;
        tmp0[3] = mCornor[1] * yR;
        tmp0[4] = (mCornor[2] - diffy) * xR;
        tmp0[5] = mCornor[3] * yR;
        tmp0[6] = (mCornor[4] - diffy) * xR;
        tmp0[7] = mCornor[5] * yR;

    }

    if (self.view.bounds.size.width > self.view.bounds.size.height) {
        tmp[0] = 2.0F * tmp0[0] / screenW - 1.0F;
        tmp[1] = 1.0F - 2.0F * tmp0[1] / screenH;
        tmp[2] = 2.0F * tmp0[2] / screenW - 1.0F;
        tmp[3] = 1.0F - 2.0F * tmp0[3] / screenH;
        tmp[4] = 2.0F * tmp0[4] / screenW - 1.0F;
        tmp[5] = 1.0F - 2.0F * tmp0[5] / screenH;
        tmp[6] = 2.0F * tmp0[6] / screenW - 1.0F;
        tmp[7] = 1.0F - 2.0F * tmp0[7] / screenH;
    } else {
        tmp[0] = 1.0F - 2.0F * tmp0[1] / screenH;
        tmp[1] = 1.0F - 2.0F * tmp0[0] / screenW;
        tmp[2] = 1.0F - 2.0F * tmp0[3] / screenH;
        tmp[3] = 1.0F - 2.0F * tmp0[2] / screenW;
        tmp[4] = 1.0F - 2.0F * tmp0[5] / screenH;
        tmp[5] = 1.0F - 2.0F * tmp0[4] / screenW;
        tmp[6] = 1.0F - 2.0F * tmp0[7] / screenH;
        tmp[7] = 1.0F - 2.0F * tmp0[6] / screenW;
    }

    squareCoords[0] = tmp[0];
    squareCoords[1] = tmp[1];
    squareCoords[2] = tmp[2];
    squareCoords[3] = tmp[3];
    squareCoords[4] = tmp[4];
    squareCoords[5] = tmp[5];
    squareCoords[6] = tmp[6];
    squareCoords[7] = tmp[7];

    return squareCoords;
}

@end
