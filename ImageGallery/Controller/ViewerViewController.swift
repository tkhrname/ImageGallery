//
//  ViewerViewController.swift
//  ImageGallery
//
//  Created by 渡邊丈洋 on 2019/09/05.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import UIKit

class ViewerViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 5
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.tapped(_:)))
        self.baseView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        // 処理
        self.dismiss(animated: true, completion: nil)
    }
    
}
