//
//  GLCube.m
//  sdkDemo
//
//  Created by kyzhan－mac on 2017/11/10.
//  Copyright © 2017年 kyzhan－mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLCube.h"

@interface GLCube() {
    GLuint vbo;
    GLuint vao;
}

@end

@implementation GLCube

- (instancetype)init
{
    if (self = [super init]) {
        [self setupGLProgram];

        [self genVBO];
        [self genVAO];
        
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"texture" ofType:@"jpg"]];
        self.diffuseTexture = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:nil];
        
        self.modelMatrix = GLKMatrix4Identity;
        self.modelMatrix = GLKMatrix4Scale(self.modelMatrix, 0.5, 0.5, 0.5);
    }
    return self;
}

- (void)setupGLProgram
{
    NSString *vertFile = [[NSBundle bundleForClass:self.class] pathForResource:@"cube_vertex.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle bundleForClass:self.class] pathForResource:@"cube_frag.glsl" ofType:nil];
    
    self.program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
}

- (void)dealloc {
 //   glDeleteBuffers(1, &vbo);
 //   glDeleteBuffers(1, &vao);
}

- (GLfloat *)cubeData {
    static GLfloat cubeData[] = {
        -0.5f, -0.5f, -0.5f+0.5f, 1.0000f, 1.0000f,
        -0.5f, 0.5f,  -0.5f+0.5f,1.0000f, 0.0000f,
        0.5f,  0.5f,  -0.5f+0.5f, 0.0000f, 0.0000f,
        0.5f, 0.5f, -0.5f+0.5f,0.0000f, 0.0000f,
        0.5f, -0.5f, -0.5f+0.5f,0.0000f, 1.0000f,
        -0.5f, -0.5f, -0.5f+0.5f,1.0000f,1.0000f,
        
        -0.5f, -0.5f, 0.5f+0.5f,0.0000f, 1.0000f,
        0.5f, -0.5f, 0.5f+0.5f,1.0000f, 1.0000f,
        0.5f,0.5f, 0.5f+0.5f,1.0000f, 0.0000f,
        0.5f, 0.5f, 0.5f+0.5f,1.0000f, 0.0000f,
        -0.5f, 0.5f, 0.5f+0.5f,0.0000f, 0.0000f,
        -0.5f, -0.5f,0.5f+0.5f,0.0000f, 1.0000f,
        
        -0.5f, -0.5f, -0.5f+0.5f,0.0000f,1.0000f,
        0.5f, -0.5f, -0.5f+0.5f,1.0000f, 1.0000f,
        0.5f, -0.5f, 0.5f+0.5f,1.0000f, 0.0000f,
        0.5f, -0.5f, 0.5f+0.5f,1.0000f, 0.0000f ,
        -0.5f, -0.5f, 0.5f+0.5f,0.0000f, 0.0000f,
        -0.5f, -0.5f, -0.5f+0.5f,0.0000f, 1.0000f,
        
        0.5f,-0.5f, -0.5f+0.5f,0.0000f, 1.0000f,
        0.5f, 0.5f, -0.5f+0.5f,1.0000f,1.0000f,
        0.5f, 0.5f, 0.5f+0.5f,1.0000f, 0.0000f,
        0.5f, 0.5f,0.5f+0.5f,1.0000f, 0.0000f,
        0.5f, -0.5f, 0.5f+0.5f,0.0000f, 0.0000f,
        0.5f, -0.5f, -0.5f+0.5f,0.0000f, 1.0000f,
        
        0.5f, 0.5f, -0.5f+0.5f,0.0000f, 1.0000f,
        -0.5f, 0.5f, -0.5f+0.5f,1.0000f, 1.0000f,
        -0.5f, 0.5f, 0.5f+0.5f,1.0000f,0.0000f,
        -0.5f, 0.5f, 0.5f+0.5f,1.0000f, 0.0000f,
        0.5f,0.5f, 0.5f+0.5f,0.0000f, 0.0000f,
        0.5f, 0.5f, -0.5f+0.5f,0.0000f, 1.0000f,
        
        -0.5f, 0.5f, -0.5f+0.5f,0.0000f, 1.0000f,
        -0.5f, -0.5f,-0.5f+0.5f,1.0000f, 1.0000f,
        -0.5f, -0.5f, 0.5f+0.5f,1.0000f, 0.0000f,
        -0.5f, -0.5f, 0.5f+0.5f,1.0000f,0.0000f,
        -0.5f, 0.5f, 0.5f+0.5f,0.0000f, 0.0000f,
        -0.5f, 0.5f, -0.5f+0.5f,0.0000f, 1.0000f
    };
    return cubeData;
}

- (void)genVBO {
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 36 * 5 * sizeof(GLfloat), [self cubeData], GL_STATIC_DRAW);
}

- (void)genVAO {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    GLuint positionAttribLocation = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(positionAttribLocation);
    //GLuint colorAttribLocation = glGetAttribLocation(self.program, "normal");
    //glEnableVertexAttribArray(colorAttribLocation);
    GLuint uvAttribLocation = glGetAttribLocation(self.program, "uv");
    glEnableVertexAttribArray(uvAttribLocation);
    
    glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (char *)NULL);
    //glVertexAttribPointer(colorAttribLocation, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (char *)NULL + 3 * sizeof(GLfloat));
    glVertexAttribPointer(uvAttribLocation, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (char *)NULL + 3 * sizeof(GLfloat));
    
    glBindVertexArrayOES(0);
}

- (void)glDraw:(GLKMatrix4)projectMatrix viewM:(GLKMatrix4)cameraMatrix
{
    glEnable(GL_DEPTH_TEST);
    glUseProgram(self.program);
    
    
    
    glUniformMatrix4fv(glGetUniformLocation(self.program, "projectionMatrix"), 1, 0, projectMatrix.m);
    
    glUniformMatrix4fv(glGetUniformLocation(self.program, "cameraMatrix"), 1, 0, cameraMatrix.m);
    
    glUniformMatrix4fv(glGetUniformLocation(self.program, "modelMatrix"), 1, 0, self.modelMatrix.m);

    glUniform3fv(glGetUniformLocation(self.program, "lightDirection"), 1, GLKVector3Make(1, -1, 0).v);
    
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.modelMatrix, &canInvert);
    GLKMatrix4 norMatrix = canInvert ? normalMatrix : GLKMatrix4Identity;
    glUniformMatrix4fv(glGetUniformLocation(self.program, "normalMatrix"), 1, 0, norMatrix.m);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.diffuseTexture.name);
    glUniform1i(glGetUniformLocation(self.program, "diffuseMap"), 0);
    
    glBindVertexArrayOES(vao);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);

    glDisable(GL_DEPTH_TEST);

}

@end
