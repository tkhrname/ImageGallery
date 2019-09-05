//
//  ImageListViewModel.swift
//  ImageGallery
//
//  Created by 渡邊丈洋 on 2019/09/04.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import Foundation
import UIKit


// 通信状態
enum ImageListViewModelState {
    case loading
    case finish
    case error(Error)
}

final class ImageListViewModel {
    // ViewModelStateをclosureとしてpropertyで保持
    // この変数がViewControllerに対して通知を送る役割を果たす
    var stateDidUpdate: ((ImageListViewModelState) -> Void)?
    
    let api = ImageGalleryAPIClient()
    
    var imageLinkArray = Array<String>()
    
    // Imageの配列を取得する
    func getImages() {
        self.stateDidUpdate?(.loading)
        self.imageLinkArray.removeAll()
        api.getImage(success: { data in
            self.stateDidUpdate?(.finish)
        }, failure: { error in
            self.stateDidUpdate?(.error(error))
        })
    }
    
    func imageLinkCount() -> Int {
        return self.imageLinkArray.count
    }
    
}
