//
//  GLRender
//  sdkDemo
//
//  Created by kyzhan－mac on 2017/11/6.
//  Copyright © 2017年 kyzhan－mac. All rights reserved.
//

#import "GLImage.h"
#import <GLKit/GLKit.h>
#import <tarengine/tarengine.h>

////////////////GLRender//////////////////////////
@interface GLImage()
{
    int _width;
    int _height;
}
@end
@implementation GLImage
- (void)setupGLProgram
{
}

- (void)setTexture:(GLImageTexture *)texture
{
}

- (void)prepareRender
{
}

-(id)initWithSize:(int)width height:(int)height
{
    if (self = [super init]) {
        _width = width;
        _height = height;
    }
    return self;
}
-(void)glDraw:(bool)isLandscape
{
    
}
@end

@interface GLImageRGB()
{
    uint8_t* _pixelCache;
}
@end
////////////////GLRenderRGB//////////////////////////
@implementation GLImageRGB

- (instancetype)initWithSize:(int)width height:(int)height {
    if (self = [super initWithSize:width height:height]) {
        [self setupGLProgram];
        
        // 这里宽高设置死了，但是可以动态设置
        _texture = createTexture2D(GL_RGBA, self.width, self.height, NULL);
        
        self.modelMatrix = GLKMatrix4Identity;
            }
    return self;
}

- (void)setupGLProgram {
    NSString *vertFile = [[NSBundle bundleForClass:self.class] pathForResource:@"rgb_vertex.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle bundleForClass:self.class] pathForResource:@"rgb_frag.glsl" ofType:nil];
    
    self.program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
}

- (void)setTexture:(GLImageTexture *)texture {
    if ([texture isMemberOfClass:[GLImageTextureRGB class]]) {
        
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        GLImageTextureRGB *rgbTexture = (GLImageTextureRGB *)texture;
        glBindTexture(GL_TEXTURE_2D, _texture);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texture.width, texture.height, GL_RGBA, GL_UNSIGNED_BYTE, rgbTexture.RGBA);
    }
}

- (void)glDraw {
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize size = UIScreen.mainScreen.bounds.size;
    glViewport(0, 0, size.width * scale, size.height * scale);

    glUseProgram(self.program);

    GLfloat vertices[] = {
        -0.5f, 0.5f, 1.0f,
        -0.5f, -0.5f, 1.0f,
        0.5f, 0.5f, 1.0f,
        0.5f, -0.5f, 1.0f,
    };
    // 创建VBO
    self.vertexVBO = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexVBO);

    // Position
    int position = glGetAttribLocation(self.program, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    glEnableVertexAttribArray(position);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)glDraw:(bool)isLandscape corners:(float *)corners projectionM:(GLKMatrix4)projectMatrix viewM:(GLKMatrix4)cameraMatrix {
    glUseProgram(self.program);

    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize size = UIScreen.mainScreen.bounds.size;
    glViewport(0, 0, size.width * scale, size.height * scale);

    glUseProgram(self.program);

    GLfloat vertices[] = {
        // x, y, z, u, v
        corners[0],  corners[1], 1.0f, 0.0f, 0.0f,
        corners[2], corners[3], 1.0f, 0.0f, 1.0f,
        corners[6],  corners[7], 1.0f, 1.0f, 0.0f,
        corners[4], corners[5], 1.0f, 1.0f, 1.0f,
    };
    // 创建VBO
    self.vertexVBO = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);

    glBindBuffer(GL_ARRAY_BUFFER, self.vertexVBO);
    glEnableVertexAttribArray(glGetAttribLocation(self.program, "position"));
    glVertexAttribPointer(glGetAttribLocation(self.program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);

    GLuint textCoor = glGetAttribLocation(self.program, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
    glEnableVertexAttribArray(textCoor);

//    glUniformMatrix4fv(glGetUniformLocation(self.program, "projectionMatrix"), 1, 0, projectMatrix.m);
//
//    glUniformMatrix4fv(glGetUniformLocation(self.program, "cameraMatrix"), 1, 0, cameraMatrix.m);

    glUniformMatrix4fv(glGetUniformLocation(self.program, "modelMatrix"), 1, 0, self.modelMatrix.m);

//    GLKMatrix4 matrix = GLKMatrix4Identity;
//    if (!isLandscape) {
//        matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(270), 0.0f, 0.0f, 1.0f);
//    }
//    glUniformMatrix4fv(glGetUniformLocation(self.program, "u_Matrix"), 1, 0, matrix.m);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(glGetUniformLocation(self.program, "image0"), 0);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc {
    if (_pixelCache != NULL) {
        free(_pixelCache);
        _pixelCache = NULL;
    }
}
@end

@interface GLImageYUV()
{
    uint8_t* _yPixels;
    uint8_t* _uPixels;
    uint8_t* _vPixels;
}
@end
////////////////GLRenderYUV//////////////////////////
@implementation GLImageYUV
- (instancetype)initWithSize:(int)width height:(int)height
{
    if (self = [super initWithSize:width height:height]) {
        [self setupGLProgram];
        [self setupVBO];
        
        // 这里宽高设置死了，但是可以动态设置
        _y = createTexture2D(GL_LUMINANCE, self.width, self.height, NULL);
        _u = createTexture2D(GL_LUMINANCE, self.width/2, self.height/2, NULL);
        _v = createTexture2D(GL_LUMINANCE, self.width/2, self.height/2, NULL);
    }
    return self;
}

- (void)setupGLProgram
{
    NSString *vertFile = [[NSBundle bundleForClass:self.class] pathForResource:@"yuv_vertex.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle bundleForClass:self.class] pathForResource:@"yuv_frag.glsl" ofType:nil];
    
    self.program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
    glUseProgram(self.program);
}

- (void)setupVBO
{
//    self.vertCount = 6;
//
//    GLfloat vertices[] = {
//        0.8f,  0.6f, 0.0f, 1.0f, 0.0f,   // 右上
//        0.8f, -0.6f, 0.0f, 1.0f, 1.0f,   // 右下
//        -0.8f, -0.6f, 0.0f, 0.0f, 1.0f,  // 左下
//        -0.8f, -0.6f, 0.0f, 0.0f, 1.0f,  // 左下
//        -0.8f,  0.6f, 0.0f, 0.0f, 0.0f,  // 左上
//        0.8f,  0.6f, 0.0f, 1.0f, 0.0f,   // 右上
//    };
    
    self.vertCount = 4;
    GLfloat vertices[] = {
        // x, y, z, u, v
        -1.0f,  1.0f, 1.0f, 0.0f, 0.0f,
        -1.0f, -1.0f, 1.0f, 0.0f, 1.0f,
        1.0f,  1.0f, 1.0f, 1.0f, 0.0f,
        1.0f, -1.0f, 1.0f, 1.0f, 1.0f,
    };

    // 创建VBO
    self.vertexVBO = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);
}

- (void)setTexture:(GLImageTexture *)texture
{
    if ([texture isMemberOfClass:[GLImageTextureYUV class]]) {
        GLImageTextureYUV *rgbTexture = (GLImageTextureYUV *)texture;
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        glBindTexture(GL_TEXTURE_2D, _y);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texture.width, texture.height, GL_LUMINANCE, GL_UNSIGNED_BYTE, rgbTexture.Y);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        
        glBindTexture(GL_TEXTURE_2D, _u);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texture.width/2, texture.height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, rgbTexture.U);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        glBindTexture(GL_TEXTURE_2D, _v);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texture.width/2, texture.height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, rgbTexture.V);
        glBindTexture(GL_TEXTURE_2D, 0);
        
    }
}

- (void)update:(ImageFrame*)image format:(int)format
{
    if (format == IMAGE_FORMAT_NV21) {
        CVPixelBufferRef pixelBuffer = image.data;
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        //yuv
        int pixelWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        int pixelHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        
        size_t y_size = pixelWidth * pixelHeight;
        if (_yPixels == NULL) {
            _yPixels = malloc(y_size);
        }
        uint8_t *y_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        memcpy(_yPixels, y_frame, y_size);
        
        uint8_t *uv_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        size_t uv_size = y_size/2;
        
        size_t u_size = y_size/4;
        if (_uPixels == NULL) {
            _uPixels = malloc(u_size);
        }
        for (int i = 0, j = 0; i < uv_size; i += 2, j++) {
            _uPixels[j] = uv_frame[i];
        }
        
        size_t v_size = y_size/4;
        if (_vPixels == NULL) {
            _vPixels = malloc(v_size);
        }
        for (int i = 1, j = 0; i < uv_size; i += 2, j++) {
            _vPixels[j] = uv_frame[i];
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        
        glBindTexture(GL_TEXTURE_2D, _y);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, pixelWidth, pixelHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, _yPixels);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        
        glBindTexture(GL_TEXTURE_2D, _u);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, pixelWidth/2, pixelHeight/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, _uPixels);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        glBindTexture(GL_TEXTURE_2D, _v);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, pixelWidth/2, pixelHeight/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, _vPixels);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

- (void)glDraw:(bool)isLandscape
{
    glUseProgram(self.program);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexVBO);
    glEnableVertexAttribArray(glGetAttribLocation(self.program, "position"));
    glVertexAttribPointer(glGetAttribLocation(self.program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    glEnableVertexAttribArray(glGetAttribLocation(self.program, "texcoord"));
    glVertexAttribPointer(glGetAttribLocation(self.program, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
    GLKMatrix4 matrix = GLKMatrix4Identity;
    if (!isLandscape) {
        matrix = GLKMatrix4Rotate(matrix, GLKMathDegreesToRadians(270), 0.0f, 0.0f, 1.0f);
    }
    glUniformMatrix4fv(glGetUniformLocation(self.program, "u_Matrix"), 1, 0, matrix.m);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _y);
    glUniform1i(glGetUniformLocation(self.program, "image0"), 0);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _u);
    glUniform1i(glGetUniformLocation(self.program, "image1"), 1);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, _v);
    glUniform1i(glGetUniformLocation(self.program, "image2"), 2);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.vertCount);
}

- (void)dealloc {
    if (_yPixels != NULL) {
        free(_yPixels);
        _yPixels = NULL;
    }
    
    if (_uPixels != NULL) {
        free(_uPixels);
        _uPixels = NULL;
    }
    
    if (_vPixels != NULL) {
        free(_vPixels);
        _vPixels = NULL;
    }
}
@end
