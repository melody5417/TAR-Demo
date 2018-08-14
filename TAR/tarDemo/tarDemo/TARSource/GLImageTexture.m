//
//  GLTexture
//  sdkDemo
//
//  Created by kyzhan－mac on 2017/11/6.
//  Copyright © 2017年 kyzhan－mac. All rights reserved.
//

#import "GLImageTexture.h"

@implementation GLImageTexture
@end

@implementation GLImageTextureRGB
- (void)dealloc
{
    if (_RGBA) {
        free(_RGBA);
        _RGBA = NULL;
    }
}
@end

@implementation GLImageTextureYUV
- (void)dealloc
{
    if (_Y) {
        free(_Y);
        _Y = NULL;
    }
    
    if (_U) {
        free(_U);
        _U = NULL;
    }
    
    if (_V) {
        free(_V);
        _V = NULL;
    }
}
@end
