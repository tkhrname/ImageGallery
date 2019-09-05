//
//  APIError.swift
//  ImageGallery
//
//  Created by 渡邊丈洋 on 2019/09/04.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case unknown
    case invalidURL
    case invalidResponse
    
    var description: String {
        switch self {
        case .unknown:
            return "不明なエラーです。"
        case .invalidURL:
            return "URLが不正です。"
        case .invalidResponse:
            return "レスポンスデータが不正です。"
        }
    }
}
