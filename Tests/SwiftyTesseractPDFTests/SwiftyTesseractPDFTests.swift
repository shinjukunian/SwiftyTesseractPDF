import XCTest
import SwiftyTesseract
@testable import SwiftyTesseractPDF
import SwiftyTesseractPDFFont

struct DataSource:LanguageModelDataSource{
    let url:URL
    
    var pathToTrainedData: String{
        return url.path
    }
    
}

final class SwiftyTesseractPDFTests: XCTestCase {
    #if SWIFT_PACKAGE
    lazy var imageURLS:[URL]={
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent()
        let imageURL=currentURL.appendingPathComponent("testData", isDirectory: true)
        let imageURLs=try! FileManager.default.contentsOfDirectory(at: imageURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        XCTAssertGreaterThan(imageURLs.count, 0, "insufficient images loaded")
        return imageURLs
    }()
    
    lazy var dataSource : DataSource = {
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent()
        let tessURL=currentURL.appendingPathComponent("tessdata", isDirectory: true)
        return DataSource(url: tessURL)
    }()
    
    #else
    lazy var imageURLS:[URL]={
        guard let urls=Bundle(for: type(of: self)).urls(forResourcesWithExtension: nil, subdirectory: "testData") else{
            XCTFail("No Images Loaded")
            return [URL]()
        }
        XCTAssertGreaterThan(urls.count, 0, "insufficient images loaded")
        return urls
    }()
    #endif
    
    
    
    
    
    func testPDFSingle(){
        guard let firstImageURL = self.imageURLS.first,
              let data = try? Data(contentsOf: firstImageURL),
              let firstImage = UIImage(data: data) else{
            XCTFail()
            return
        }
        let tesseract=Tesseract(language: .japanese, dataSource: self.dataSource, engineMode: .lstmOnly, configure: {})
        do{
            let data = try tesseract.createPDF(from: [firstImage], dataSource: self.dataSource)
            XCTAssert(data.count > 0)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
        
        
    }
    
    func testPDF(){
        guard let datas = try? self.imageURLS.map({ try Data(contentsOf: $0) }) else{
            XCTFail()
            return
        }
        
        let images = datas.compactMap({UIImage(data: $0)})
        XCTAssertEqual(images.count, self.imageURLS.count)
        let fontDataSource=FontDataSource()
        let tesseract=Tesseract(language: .japanese, dataSource: self.dataSource, engineMode: .lstmOnly, configure: {})
        
        do{
            let data = try tesseract.createPDF(from: images, dataSource: fontDataSource)
            XCTAssert(data.count > 0)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
        
        
    }
}
