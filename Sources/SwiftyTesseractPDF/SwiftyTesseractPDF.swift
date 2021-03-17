//
//  SwiftyTesseractPDF.swift
//  
//
//  Created by Morten Bertz on 2021/03/12.
//

import Foundation
import SwiftyTesseract
import libtesseract

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
public typealias UIImage = NSImage

extension NSImage{
    func pngData()->Data?{
        if let tiff=self.tiffRepresentation, let bitmap=NSBitmapImageRep(data: tiff){
            return bitmap.representation(using: .png, properties: [:])
        }
        return nil
    }
}


#else
import UIKit
#endif

extension Tesseract.Error{
    public static let PDFCreationError = Tesseract.Error("")
    public static let unableToCreateRenderer = Tesseract.Error("PDF Renderer could not be initialized")
    public static let unableToBeginDocument = Tesseract.Error("PDF Renderer could not begin document")
    public static let unableToEndDocument = Tesseract.Error("PDF Renderer could not finish document")
    public static let unableToProcessPage = Tesseract.Error("PDF Renderer could not process page")
}

extension Tesseract{
    
    public func createPDF(from images:[UIImage], dataSource:LanguageModelDataSource = Bundle.main)throws->Data{
        if let data=perform(action: {ptr->Data? in
            do{
                let PDF=try processPDF(images: images, tesseract: ptr, dataSource: dataSource)
                return try Data(contentsOf: PDF)
            }
            catch let error{
                print(error)
                return nil
            }
        }){
            return data
        }
        else{
            throw Tesseract.Error.PDFCreationError
        }
    }
    
    
    fileprivate func processPDF(images: [UIImage], tesseract:TessBaseAPI, dataSource:LanguageModelDataSource) throws -> URL {
        
        let filepath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        guard let renderer = TessPDFRendererCreate(filepath.path, dataSource.pathToTrainedData, 0) else {
            throw Tesseract.Error.unableToCreateRenderer
        }
        
        guard TessResultRendererBeginDocument(renderer, "Unkown Title") == 1 else {
          TessDeleteResultRenderer(renderer)
          throw Tesseract.Error.unableToBeginDocument
        }
        
        defer { TessDeleteResultRenderer(renderer) }

        try render(images, with: renderer, tesseract: tesseract)

        return filepath.appendingPathExtension("pdf")
    }
    
    fileprivate func render(_ images: [UIImage], with renderer: OpaquePointer, tesseract:TessBaseAPI) throws {
        // create pix is internal so we replicate this here
        
        for (idx,image) in images.enumerated(){
            guard let png=image.pngData()
            else{
                continue
            }
            
            var pix=createPix(from: png)
            defer {
                pixDestroy(&pix)
            }
            
            guard TessBaseAPIProcessPage(tesseract, pix, Int32(idx), "page.\(idx)", nil, 30000, renderer) == 1 else {
              throw Tesseract.Error.unableToProcessPage
            }
            
        }
        
        guard TessResultRendererEndDocument(renderer) == 1 else { throw Tesseract.Error.unableToEndDocument }
    }
    
    
    fileprivate func createPix(from data: Data) -> UnsafeMutablePointer<PIX>? {
        data.withUnsafeBytes { bytePointer in
            let uint8Pointer = bytePointer.bindMemory(to: UInt8.self)
            return pixReadMem(uint8Pointer.baseAddress, data.count)
        }
    }
 
}
