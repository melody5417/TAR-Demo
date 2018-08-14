//
//  GLFeaturePoints.m
//  sdkDemo
//
//  Created by carmzhu on 2017/11/22.
//  Copyright © 2017年 kyzhan－mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <vector>
#import "GLUtil.h"
#import "GLFeaturePoints.h"

@interface GLFeaturePoints()
    {
        NSLock* _bufferLock;
        NSLock* _viewportLock;
        int _numPoints;
        float _pointSize;
        std::vector<float> _vertexAttribBuffer;
        float* _color;
        bool _dirty;
        float _viewportSize[2];
        GLuint _vbo;
        int _program;
        int _positionHandle;
        int _colorHandle;
        int _pointSizeHandle;
    }
-(int)reloadVertexAttrib;
@end
static float POINT_COLOR[] = {
    // r, g, b
    1.0f, 1.0f, 0.0f
};
const static float POINT_SIZE = 5.0f;
const static int MAX_NUM_OF_POINTS = 1000;
const static int COORDINATE_COMPONENTS_NUM = 2;
const static int VERTEX_ATTRIB_STRIDE =COORDINATE_COMPONENTS_NUM * 4;
const static int COORDINATE_OFFSET = 0;
@implementation GLFeaturePoints

    
-(instancetype)init
{
    _color = POINT_COLOR;
    _pointSize = POINT_SIZE;
    _vertexAttribBuffer.reserve(MAX_NUM_OF_POINTS*COORDINATE_COMPONENTS_NUM);
    _bufferLock = [[NSLock alloc]init];
    _viewportLock = [[NSLock alloc]init];
    [self glInit];
    return self;
}
    
-(void)glInit
{
    NSString *vertFile = [[NSBundle bundleForClass:self.class] pathForResource:@"point2d_vertex.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle bundleForClass:self.class] pathForResource:@"point2d_frag.glsl" ofType:nil];
    
    _program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
    
    _positionHandle = glGetAttribLocation(_program, "vPosition");
    _colorHandle = glGetAttribLocation(_program, "vColor");
    _pointSizeHandle = glGetAttribLocation(_program, "sPointSize");
    glGenBuffers(1, &_vbo);
}

//FIXME: We only support portrait currently
-(void)updateBuffer:(float*)pointCloud pointsCount:(int)pointsCount imageWidth:(int)imageWidth imageHeight:(int)imageHeight
{
    if (pointsCount <= 0) return;
    float viewport_w;
    float viewport_h;
    [_viewportLock lock];
    viewport_w = _viewportSize[0];
    viewport_h = _viewportSize[1];
    [_viewportLock unlock];;
    
    if (viewport_h <= 0 || viewport_w <= 0) {
        return;
    }
    
    [_bufferLock lock];
    float img_w = imageWidth;
    float img_h = imageHeight;
    
    _numPoints = pointsCount;
    
    float dx = 0.0f;
    float dy = 0.0f;
    float r = viewport_h / viewport_w;
    if ((r * img_w) < img_h) {
        dy = (img_h - r * img_w) / 2.0f;
    } else {
        dx = (img_w - img_h / r) / 2.0f;
    }
    _vertexAttribBuffer.clear();
    for (int i = 0; i < _numPoints && i < MAX_NUM_OF_POINTS; ++i) {
        _vertexAttribBuffer.push_back(2.0f * (pointCloud[i*2] - dx) / (img_w - 2.0f * dx) - 1.0f);
        _vertexAttribBuffer.push_back(-2.0f * (pointCloud[i*2+1] - dy) / (img_h - 2.0f * dy) + 1.0f);
    }
    [_bufferLock unlock];
    _dirty = true;
}
    
-(void)onViewportChanged:(int)x y:(int)y w:(int)w h:(int)h
{
    [_viewportLock lock];
    _viewportSize[0] = w;
    _viewportSize[1] = h;
    [_viewportLock unlock];
}
    
-(void)glDraw
{
    int numPoints = _numPoints;
    if (_dirty) {
        numPoints = [self reloadVertexAttrib];
        _dirty = false;
    }
    
    glUseProgram(_program);
    
    // bind buffer object
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    // Prepare the cube coordinate data.
    glEnableVertexAttribArray(_positionHandle);
    glVertexAttribPointer(
                                 _positionHandle, COORDINATE_COMPONENTS_NUM, GL_FLOAT,
                                 GL_FALSE, VERTEX_ATTRIB_STRIDE, (const char*)NULL + COORDINATE_OFFSET*sizeof(GLfloat));
    
    glDisableVertexAttribArray(_colorHandle);
    glVertexAttrib3fv(_colorHandle, _color);
    
    glDisableVertexAttribArray(_pointSizeHandle);
    glVertexAttrib1f(_pointSizeHandle, POINT_SIZE);
    
    glDrawArrays(GL_POINTS, 0, numPoints);
    
    // Disable vertex arrays.
    glDisableVertexAttribArray(_positionHandle);
    
    // unbind buffer object
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}
    
-(int)reloadVertexAttrib
{
    [_bufferLock lock];
    // upload the vertex attributes
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    
    glBufferData(GL_ARRAY_BUFFER,_numPoints * COORDINATE_COMPONENTS_NUM * 4, &_vertexAttribBuffer[0], GL_DYNAMIC_DRAW);
    
    // unbind buffer object
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    [_bufferLock unlock];
    return _numPoints;
}
@end
