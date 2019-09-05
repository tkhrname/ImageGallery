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
    
    var elementMatch = false // 読み込んだデータのタグマッチに使用
    var CONTENT = "content" // contentタグを指定
    var linkArray = Array<String>() // 画像リンク用配列
    var cellViewModels = Array<ImageCellViewModel>() // UICollectionViewCell用ViewModel配列
    
    let ENDPOINT = "https://www.flickr.com/services/feeds/photos_public.gne"
    
    var searchText: String? // タグ検索用文字列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        
        // UIRefreshControl生成
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(refreshControlValueDidChanged(sender:)), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
        
        // UICollectionViewの初期設定
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        // イメージ取得処理
        self.getImagesFromFlickr()

    }
    
    @objc func refreshControlValueDidChanged(sender: UIRefreshControl) {
        // リフレッシュ処理
        self.getImagesFromFlickr()
    }
    
    fileprivate func getImagesFromFlickr(query: String? = nil) {
        let feedURLString = query == nil ? ENDPOINT : ENDPOINT + "?tags=" + query!
        guard let feedUrl = URL(string: feedURLString) else { return }
        guard let parser = XMLParser(contentsOf: feedUrl) else { return }
        parser.delegate = self
        self.refreshControl.beginRefreshing()
        parser.parse()
    }
    
}

// MARK: - UICollectionViewDataSource
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

// MARK: - UICollectionViewDelegate
extension ImageGalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.endEditing(true)
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "vierwer") as? ViewerViewController else { return }
        vc.modalTransitionStyle = .crossDissolve
        let cellViewModel = self.cellViewModels[indexPath.row]
        cellViewModel.downloadImage() { progress in
            switch progress {
            case .loading(let image):
                vc.image = image
            case .finish(let image):
                vc.image = image
                self.present(vc, animated: true, completion: nil)
            case .error:
                break
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
    
    // UICollectionViewのサイズを指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = self.collectionView.frame.width / 2 - 1
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    // UICollectionViewの行間サイズを指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // UICollectionViewの列間サイズを指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

// MARK: - XMLParserDelegate
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

        self.refreshControl.endRefreshing()

        self.collectionView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension ImageGalleryViewController: UISearchBarDelegate {
    //サーチバー更新時
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    //キャンセルクリック時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = nil
        self.searchBar.text = ""
        self.searchBar.endEditing(true)
    }
    
    //サーチボタンクリック時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        if let searchText = self.searchText {
            self.getImagesFromFlickr(query: searchText)
        }
    }
}
