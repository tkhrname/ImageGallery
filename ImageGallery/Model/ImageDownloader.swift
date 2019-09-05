//
//  ImageDownloader.swift
//  ImageGallery
//
//  Created by 渡邊丈洋 on 2019/09/04.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import Foundation
import UIKit

final class ImageDownloder {
    // UIImageをキャッシュするための変数
    var cacheImage: UIImage?
    
    func downloadImage(imageUrl: String, success: @escaping (UIImage) -> Void, failure: @escaping (Error) -> Void) {
        // キャッシュされたUIImageがあればそれをclosureで返す
        if let cacheImage = cacheImage {
            success(cacheImage)
        }
        
        guard let url = URL(string: imageUrl) else {
            failure(APIError.invalidURL)
            return
        }
        do {
            let data = try Data(contentsOf: url)
            guard let imageFromData = UIImage(data: data) else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }
            DispatchQueue.main.async {
                success(imageFromData)
            }
        } catch {
            DispatchQueue.main.async {
                failure(APIError.invalidResponse)
            }
        }
    }
}
