//
//  Base.metal
//  MetalYUV
//
//  Created by Patrick Lin on 7/1/16.
//  Copyright © 2016 Patrick Lin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


#define YUV_SHADER_ARGS  VertexOut      inFrag    [[ stage_in ]],\
texture2d<float>  lumaTex     [[ texture(0) ]],\
texture2d<float>  chromaTex     [[ texture(1) ]],\
sampler bilinear [[ sampler(1) ]], \
constant ColorParameters *colorParameters [[ buffer(0) ]]

struct VertexIn
{
    float2 m_Position [[ attribute(0) ]];
    float2 m_TexCoord [[ attribute(1) ]];
};

struct VertexOut
{
    float4 m_Position [[ position ]];
    float2 m_TexCoord [[ user(texturecoord) ]];
};

struct ColorParameters
{
    float3x3 yuvToRGB;
};

vertex VertexOut defaultVertex( VertexIn vert [[ stage_in ]], unsigned int vid [[ vertex_id ]])
{
    VertexOut outVertices;
    outVertices.m_Position = float4(vert.m_Position,0.0,1.0);
    outVertices.m_TexCoord = vert.m_TexCoord;
    return outVertices;
}

fragment half4 yuv_rgb(YUV_SHADER_ARGS)
{
    float3 yuv;
    yuv.x = lumaTex.sample(bilinear, inFrag.m_TexCoord).r;
    yuv.yz = chromaTex.sample(bilinear,inFrag.m_TexCoord).rg - float2(0.5);
    return half4(half3(colorParameters->yuvToRGB * yuv),yuv.x);
}