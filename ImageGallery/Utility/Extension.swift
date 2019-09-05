//
//  Extension.swift
//  ImageGallery
//
//  Created by 渡邊丈洋 on 2019/09/04.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIImage
extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

// MARK: - String
extension String {
    
    /// URL抽出
    func pregMatch(options: NSRegularExpression.MatchingOptions = []) -> String? {
        
        guard self.count > 0 else { return nil }
        
        let detect = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        
        let targetsLength = NSRange(location: 0, length: self.count)
        
        let links = detect.matches(
            in: self,
            options: options,
            range: targetsLength)
        
        let  urlString = links.compactMap { $0.url?.absoluteString }
        return urlString.isEmpty == true ? nil : urlString[0]
    }
    
    // ".jpg"にマッチする文字列を取得する
    func pregMatchLink() -> String? {
        guard let urlString = self.pregMatch() else { return nil }
        if ".jpg" == urlString.suffix(4) {
            return urlString
        }
        return nil
    }
    
}
