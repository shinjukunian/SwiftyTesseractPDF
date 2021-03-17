//
//  FontDataSource.swift
//  
//
//  Created by Morten Bertz on 2021/03/17.
//

import Foundation
import SwiftyTesseract

public struct FontDataSource: LanguageModelDataSource{
    public init(){}
    public var pathToTrainedData: String{
        return Bundle.module.resourceURL?.appendingPathComponent("fontdata", isDirectory: true).path ?? ""
    }
}
