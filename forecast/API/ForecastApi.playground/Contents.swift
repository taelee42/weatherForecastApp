import UIKit
import CoreLocation

struct Forecast: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ListItem]
}

struct ListItem: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
}
struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}


enum ApiError: Error {
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}

func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping (Result<ParsingType, Error>) -> ()) {
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


func fetchForecast(cityName: String, completion: @escaping (Result<Forecast, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

    fetch(urlStr: urlStr, completion: completion)
}
func fetchForecast(cityId: Int, completion: @escaping (Result<Forecast, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/forecast?id=\(cityId)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

    fetch(urlStr: urlStr, completion: completion)
}

func fetchForecast(location: CLLocation, completion: @escaping (Result<Forecast, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=00332a5411d96468afa4900a4b664f3a&units=metric&lang=kr"

    fetch(urlStr: urlStr, completion: completion)
}

fetchForecast(cityName: "seoul"){ result in
    switch result {
    case .success(let data):
        print(data)
    case .failure(let error):
        print(error)
    }
}


fetchForecast(cityId: 1835847) { (result) in
    switch result {
    case .success(let data):
        dump(data)
    case .failure(let error):
        print(error)
    }
}
let location = CLLocation(latitude: 37.498206, longitude: 127.02761)
fetchForecast(location: location) { (result) in
    switch result {
    case .success(let data):
        dump(data)
    case .failure(let error):
        print(error)
    }
}
