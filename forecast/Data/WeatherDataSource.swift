//
//  WeatherDataSource.swift
//  forecast
//
//  Created by Terry Lee on 2021/05/15.
//

import Foundation
import CoreLocation

class WeatherDataSource {
    static let shared = WeatherDataSource()
    private init() {}
    
    var summary: CurrentWeather?
//    var forecast: Forecast?
    var forecastList = [ForecastData]()
    
    let apiQueue = DispatchQueue(label: "ApiQueue", attributes: .concurrent)
    
    let group = DispatchGroup()
    
    func fetch(location: CLLocation, completion: @escaping () -> ()) {
        group.enter()
        apiQueue.async {
            self.fetchCurrentWeather(location: location) { (result) in
                switch result {
                case .success(let data):
                    self.summary = data
                default:
                    self.summary = nil
                }
                self.group.leave()
            }
        }
        
        group.enter()
        apiQueue.async {
            self.fetchForecast(location: location) { (result) in
                switch result {
                case .success(let data):
                    self.forecastList = data.list.map {
                        let dt = Date(timeIntervalSince1970: TimeInterval($0.dt))
                        let icon = $0.weather.first?.icon ?? ""

                        let weather = $0.weather.first?.description ?? "알 수 없음"
                        let temperature = $0.main.temp
                        
                        return ForecastData(date: dt, icon: icon, weather: weather, temperature: temperature)
                    }
                default:
                    self.forecastList = []
                }
                self.group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
}

extension WeatherDataSource {
    private func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping (Result<ParsingType, Error>) -> ()) {
        guard let url = URL(string: urlStr) else {
    //        fatalError("URL 생성 실패")
            completion(.failure(ApiError.invalidUrl(urlStr)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
    //            fatalError(error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
    //            fatalError("Invalid response")
                completion(.failure(ApiError.invalidResponse))
                return
            }

            guard httpResponse.statusCode == 200 else {
    //            fatalError("Failed code \(httpResponse.statusCode)")
                completion(.failure(ApiError.failed(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
    //            fatalError("Empty data")
                completion(.failure(ApiError.emptyData))
                return
            }
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(ParsingType.self, from: data)
                completion(.success(data))
            }catch {
    //            print(error)
    //            fatalError(error.localizedDescription)
                completion(.failure(error))
                
            }
        }

        task.resume()
    }


    private func fetchCurrentWeather(cityName: String, completion: @escaping (Result<CurrentWeather, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

        fetch(urlStr: urlStr, completion: completion)
    }
    private func fetchCurrentWeather(cityId: Int, completion: @escaping (Result<CurrentWeather, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?id=\(cityId)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

        fetch(urlStr: urlStr, completion: completion)
    }

    private func fetchCurrentWeather(location: CLLocation, completion: @escaping (Result<CurrentWeather, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

        fetch(urlStr: urlStr, completion: completion)
    }
}

extension WeatherDataSource {
    private func fetchForecast(cityName: String, completion: @escaping (Result<Forecast, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

        fetch(urlStr: urlStr, completion: completion)
    }
    private func fetchForecast(cityId: Int, completion: @escaping (Result<Forecast, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?id=\(cityId)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

        fetch(urlStr: urlStr, completion: completion)
    }

    private func fetchForecast(location: CLLocation, completion: @escaping (Result<Forecast, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

        fetch(urlStr: urlStr, completion: completion)
    }
}
