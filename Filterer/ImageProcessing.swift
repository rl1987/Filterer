//
//  ImageProcessing.swift
//  Filterer
//
//  Created by Rimantas Lukosevicius on 05/12/15.
//  Copyright © 2015 UofT. All rights reserved.
//

import Foundation

open class Filter {
    open func processImage(_ image: RGBAImage) -> RGBAImage {
        // Subclasses must implement this.
        return image
    }
}

open class MonochromeFilter : Filter {
    open override func processImage(_ image: RGBAImage) -> RGBAImage {
        let rgbaImage = RGBAImage.init(image: image.toUIImage()!)
        
        for i in 0..<rgbaImage!.pixels.count {
            var pixel = rgbaImage!.pixels[i]
            
            let red = pixel.red
            let green = pixel.green
            let blue = pixel.blue
            
            let average = UInt8((Int(red) + Int(green) + Int(blue)) / 3)
            
            pixel.red = average
            pixel.blue = average
            pixel.green = average
            
            rgbaImage!.pixels[i] = pixel
        }
        
        return rgbaImage!
    }
}

open class BrightnessFilter : Filter {
    open var brightnessChangeFactor: Float
    
    public override init() {
        brightnessChangeFactor = 1.5
    }
    
    public init?(factor: Float) {
        brightnessChangeFactor = abs(factor)
    }
    
    open override func processImage(_ image: RGBAImage) -> RGBAImage {
        let rgbaImage = RGBAImage.init(image: image.toUIImage()!)
        
        for i in 0..<rgbaImage!.pixels.count {
            var pixel = rgbaImage!.pixels[i]
            
            let red = pixel.red
            let green = pixel.green
            let blue = pixel.blue
            
            pixel.red = UInt8(round(min(255.0, Float(red) * brightnessChangeFactor)))
            pixel.blue = UInt8(round(min(255.0, Float(blue) * brightnessChangeFactor)))
            pixel.green = UInt8(round(min(255.0, Float(green) * brightnessChangeFactor)))
            
            rgbaImage!.pixels[i] = pixel
        }
        
        return rgbaImage!
    }
}

open class ContrastFilter : Filter {
    open var contrastChangeFactor : Float
    
    public override init() {
        contrastChangeFactor = 0.5
    }
    
    public init?(factor : Float) {
        contrastChangeFactor = factor
    }
    
    
    open override func processImage(_ image: RGBAImage) -> RGBAImage {
        let rgbaImage = RGBAImage.init(image: image.toUIImage()!)
        
        var avgRed : Float
        var avgGreen : Float
        var avgBlue : Float
        
        avgRed = 0.0
        avgGreen = 0.0
        avgBlue = 0.0
        
        for i in 0..<rgbaImage!.pixels.count {
            let pixel = rgbaImage!.pixels[i]
            
            avgRed += Float(pixel.red) / Float(rgbaImage!.pixels.count)
            avgGreen += Float(pixel.green) / Float(rgbaImage!.pixels.count)
            avgBlue += Float(pixel.blue) / Float(rgbaImage!.pixels.count)
        }
        
        avgRed = round(avgRed)
        avgGreen = round(avgGreen)
        avgBlue = round(avgBlue)
        
        for i in 0..<rgbaImage!.pixels.count {
            var pixel = rgbaImage!.pixels[i]
            
            var redDelta = Int(pixel.red) - Int(avgRed)
            var greenDelta = Int(pixel.green) - Int(avgGreen)
            var blueDelta = Int(pixel.blue) - Int(avgBlue)
            
            redDelta = Int(round(Float(redDelta) * contrastChangeFactor))
            greenDelta = Int(round(Float(greenDelta) * contrastChangeFactor))
            blueDelta = Int(round(Float(blueDelta) * contrastChangeFactor))
            
            let red = max(0, min(avgRed + Float(redDelta), 255.0) )
            let green = max(0, min(avgGreen + Float(greenDelta), 255.0) )
            let blue = max(0, min(avgBlue + Float(blueDelta), 255.0) )
            
            pixel.red = UInt8(red)
            pixel.green = UInt8(green)
            pixel.blue = UInt8(blue)
            
            rgbaImage!.pixels[i] = pixel
        }
        
        return rgbaImage!
    }
}

open class ImageProcessor {
    open var imageFilters: Array<Filter>
    
    public init?(filters : Array<Filter>) {
        imageFilters = filters
    }
    
    open func processImage(_ image: RGBAImage) -> RGBAImage {
        var processedImage = image
        
        for f in imageFilters {
            processedImage = f.processImage(processedImage)
        }
        
        return processedImage
    }
    
}
