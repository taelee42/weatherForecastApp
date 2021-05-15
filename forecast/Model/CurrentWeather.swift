//
//  CurrentWeather.swift
//  forecast
//
//  Created by Terry Lee on 2021/05/15.
//

import Foundation

struct CurrentWeather: Codable {
    let dt:Int
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
    
    let main: Main
}
