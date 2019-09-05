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
    
    fileprivate var viewModel: ImageListViewModel!
    let feedUrl = URL(string: "https://www.flickr.com/services/feeds/photos_public.gne")!
    
    var elementMatch = false
    var CONTENT = "content"
    var linkArray = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let parser: XMLParser! = XMLParser(contentsOf: feedUrl)
        parser.delegate = self
        parser.parse()

//        self.viewModel = ImageListViewModel()
//        self.viewModel.stateDidUpdate = { [weak self] state in
//            switch state {
//            case .loading:
//                self?.collectionView.isUserInteractionEnabled = false
//            case .finish:
//                self?.collectionView.isUserInteractionEnabled = true
//                self?.collectionView.reloadData()
//            case .error(let error):
//                self?.collectionView.isUserInteractionEnabled = true
//                let alertController = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
//                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertController.addAction(alertAction)
//                self?.present(alertController, animated: true, completion: nil)
//            }
//        }
//        self.viewModel.getImages()
    }
}

extension ImageGalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.linkArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) // 表示するセルを登録(先程命名した"Cell")
        cell.backgroundColor = .red  // セルの色
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let width: CGFloat = UIScreen.main.bounds.width / 2 - 1
//        let height: CGFloat = width
//        return CGSize(width: width, height: height)
//    }
    
}


extension ImageGalleryViewController: UICollectionViewDelegate {
    
}

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = self.collectionView.frame.width / 2 - 1
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
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
        }
    }
    
    // 解析中に要素の終了タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    }
    
    // XML解析終了時に実行されるメソッド
    func parserDidEndDocument(_ parser: XMLParser) {
        self.collectionView.reloadData()
    }
}
