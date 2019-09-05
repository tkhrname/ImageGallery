//
//  ImageCellViewModel.swift
//  ImageGallery
//
//  Created by 渡邊丈洋 on 2019/09/04.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import Foundation
import UIKit

// 通信状態
enum ImageDownloadProgress {
    case loading(UIImage) // ダウンロード中
    case finish(UIImage) // 終了
    case error // エラー
}

final class ImageCellViewModel {
    
    // URL
    private var urlString: String
    
    private let imageDownloader = ImageDownloder()
    
    // ダウンロードステータス
    private var isLoading = false
    
    // Cellを選択したときに必要なURL
    var webURL: URL {
        return URL(string: urlString)!
    }
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func downloadImage(progress: @escaping (ImageDownloadProgress) -> Void) {
        if self.isLoading {
            return
        }
        self.isLoading = true
        // 仮のUIImageを作成
        let loadingImage = UIImage(color: .gray, size: CGSize(width: 45, height: 45))!
        // loadingをClosureで返す
        progress(.loading(loadingImage))
        
        // 画像をダウンロード
        imageDownloader.downloadImage(imageUrl: urlString, success: { image in
            progress(.finish(image))
            self.isLoading = false
        }, failure: { error in
            progress(.error)
            self.isLoading = false
        })
    }
}
