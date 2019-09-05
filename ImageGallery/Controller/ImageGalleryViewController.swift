//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by 渡邊丈洋 on 2019/09/04.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var refreshControl: UIRefreshControl!
    
    let feedUrl = URL(string: "https://www.flickr.com/services/feeds/photos_public.gne")!
    
    var elementMatch = false
    var CONTENT = "content"
    var linkArray = Array<String>()
    var cellViewModels = Array<ImageCellViewModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIRefreshControl生成
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refreshControlValueDidChanged(sender:)), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        self.getImagesFromFlickr()

    }
    
    @objc func refreshControlValueDidChanged(sender: UIRefreshControl) {
        // リフレッシュ処理
        self.getImagesFromFlickr()
    }
    
    private func getImagesFromFlickr() {
        guard let parser = XMLParser(contentsOf: feedUrl) else { return }
        parser.delegate = self
        parser.parse()
    }
}

extension ImageGalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.linkArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        let cellViewModel = self.cellViewModels[indexPath.row]
        cellViewModel.downloadImage() { progress in
            switch progress {
            case .loading(let image):
                cell.setImage(image: image)
            case .finish(let image):
                cell.setImage(image: image)
            case .error:
                break
            }
        }
        return cell
    }
    
}

extension ImageGalleryViewController: UICollectionViewDelegate {
    
}

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = self.collectionView.frame.width / 2 - 1
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}


extension ImageGalleryViewController: XMLParserDelegate {
    
    // 解析中に要素の開始タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.elementMatch = false
        if elementName == self.CONTENT {
            self.elementMatch = true
        }
    }
    
    // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.elementMatch && string.pregMatchLink() != nil {
            self.linkArray.append(string)
            let cellViewModel = ImageCellViewModel(urlString: string)
            self.cellViewModels.append(cellViewModel)
        }
    }
    
    // XML解析開始時に実行されるメソッド
    func parserDidStartDocument(_ parser: XMLParser) {
        self.linkArray.removeAll()
        self.cellViewModels.removeAll()
    }
    
    // XML解析終了時に実行されるメソッド
    func parserDidEndDocument(_ parser: XMLParser) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        self.collectionView.reloadData()
    }
}
