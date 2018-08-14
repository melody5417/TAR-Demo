//
//  GLFeaturePoints.h
//  sdkDemo
//
//  Created by carmzhu on 2017/11/22.
//  Copyright © 2017年 kyzhan－mac. All rights reserved.
//

#ifndef GLFeaturePoints_h
#define GLFeaturePoints_h

@interface GLFeaturePoints : NSObject
-(void)glInit;
-(void)updateBuffer:(float*)pointsBuffer pointsCount:(int)pointsCount imageWidth:(int)imageWidth imageHeight:(int)imageHeight;
-(void)onViewportChanged:(int)x y:(int)y w:(int)w h:(int)h;
-(void)glDraw;
@property(nonatomic, assign) float* color;
@property(nonatomic, assign) float pointSize;
@end

#endif /* GLFeaturePoints_h */
