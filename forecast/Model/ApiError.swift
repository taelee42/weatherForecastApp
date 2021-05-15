//
//  ApiError.swift
//  forecast
//
//  Created by Terry Lee on 2021/05/15.
//

import Foundation

enum ApiError: Error {
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}
