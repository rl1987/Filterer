// Credits: João Pedro de Matos Neves 
// https://www.coursera.org/learn/ios-app-development-basics/module/tqosy/discussions/SGWj6432EeWH0w7fQkp2-w/replies/_uwJTpYGEeWB8gqILqx0tQ

import UIKit

public struct Pixel {
    public var value: UInt32
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}

public struct RGBAImage {
    fileprivate var orientation: UIImageOrientation
    fileprivate var scale: CGFloat
    
    public var pixels: UnsafeMutableBufferPointer<Pixel>
    
    public var width: Int
    public var height: Int
    
    public init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }
        
        // Redraw image for correct pixel format
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        var imageSize:CGSize
        if (image.imageOrientation != .up && image.imageOrientation != .down) {
            imageSize = CGSize(width: image.size.height, height: image.size.width)
        } else {
            imageSize=image.size
        }
        
        width = Int(imageSize.width)
        height = Int(imageSize.height)
        orientation = image.imageOrientation
        scale = image.scale
        let bytesPerRow = width * 4
        
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: imageSize))
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        let bytesPerRow = width * 4
        let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        guard let cgImage = imageContext?.makeImage() else {return nil}
        let image = UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
        
        return image
    }
}
