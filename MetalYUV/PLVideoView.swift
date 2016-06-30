//
//  PLVideoView.swift
//  MetalYUV
//
//  Created by Patrick Lin on 7/1/16.
//  Copyright © 2016 Patrick Lin. All rights reserved.
//

import MetalKit

class PLVideoView: MTKView {
    
    var textureCache: Unmanaged<CVMetalTextureCache>?
    
    var textures: [CVMetalTexture] = [CVMetalTexture]()
    
    var commandQueue: MTLCommandQueue!
    
    // MARK: Internal Methods
    
    override func drawRect(rect: CGRect) {
        
        let commandBuffer = self.commandQueue.commandBuffer()
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(self.currentRenderPassDescriptor!)
        
        renderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(self.currentDrawable!)
        
        commandBuffer.commit()
        
    }
    
    func render(dataY: NSData, dataU: NSData, dataV: NSData, size: CGSize) {
        
        let pixelBuffer = self.pixelBufferWithData(dataY, dataU: dataU, dataV: dataV, size: size)!
        
        for index in 0...2 {
            
            var texture: Unmanaged<CVMetalTexture>?
            
            CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache!.takeUnretainedValue(), pixelBuffer, nil, .R8Unorm, CVPixelBufferGetWidthOfPlane(pixelBuffer, index), CVPixelBufferGetHeightOfPlane(pixelBuffer, index), index, &texture)
            
            if self.textures.count > index {
                
                self.textures[index] = texture!.takeUnretainedValue()
                
            }
            
            else {
                
                self.textures.append(texture!.takeUnretainedValue())
                
            }
            
        }
        
    }
    
    func pixelBufferWithData(dataY: NSData, dataU: NSData, dataV: NSData, size: CGSize) -> CVPixelBuffer? {
        
        var pixelBuffer: CVPixelBuffer?
        
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_420YpCbCr8Planar, [
            String(kCVPixelBufferIOSurfacePropertiesKey): NSDictionary(),
            String(kCVPixelBufferMetalCompatibilityKey): true,
            ], &pixelBuffer)
        
        let dataYUV = [dataY, dataU, dataV]
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, 0)
        
        for index in 0...2 {
            
            memcpy(CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, index), dataYUV[index].bytes, dataYUV[index].length)
            
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, 0)
        
        return pixelBuffer
        
    }
    
    func common_init() {
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.commandQueue = self.device?.newCommandQueue()
        
        self.clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, self.device!, nil, &self.textureCache)
        
    }
    
    // MARK: Init Methods
    
    required init(coder: NSCoder) {
        
        super.init(coder: coder)
        
        self.common_init()
        
    }

}
