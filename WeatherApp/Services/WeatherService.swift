//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()

    private init() {}
    func fetchData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        if ConnectivityService.shared.isNetworkAvailable {
            fetchNetworkData(
                latitude: latitude, longitude: longitude, completion: completion
            )
        } else {

            if let cachedData = CacheService.shared.getCachedWeatherData() {
                completion(.success(cachedData))
            } else {
                completion(.failure(NSError(domain: "NoConnectivity", code: -3, userInfo: [NSLocalizedDescriptionKey: "Offline mode: No cached data available."])))
            }
        }
    }


    func fetchNetworkData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let apiKey = "fe5fb82498da92150991ef75ef8119ce"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            completion(.failure(
                NSError(domain: "InvalidURL", code: -1, userInfo: nil))
            )
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))

            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -2, userInfo: nil)))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let temperature = decodedData.main.temp
                let humidity = decodedData.main.humidity
                if let weatherCondition = decodedData.weather.first?.main, let iconCode = decodedData.weather.first?.icon {
                    let weatherData = WeatherData(
                        temperature: temperature,
                        humidity: humidity,
                        condition: weatherCondition,
                        icon: iconCode
                    )
                    completion(.success(weatherData))
                    CacheService.shared.cacheWeatherData(weatherData)
                } else {
                    completion(.failure(
                        NSError(
                            domain: "WeatherDataError",
                            code: -4,
                            userInfo: [NSLocalizedDescriptionKey: "No weather conditions found in the response."]
                        )
                    ))
                }
            } catch {
                completion(.failure(error))
            }


        }

        task.resume()
    }
}


extension WeatherService {
    func getIconURL(forIconCode iconCode: String) -> URL? {
        let baseURL = "https://openweathermap.org/img/wn/"
        let iconURLString = "\(baseURL)\(iconCode)@2x.png" // @2x for higher resolution
        return URL(string: iconURLString)
    }
}
