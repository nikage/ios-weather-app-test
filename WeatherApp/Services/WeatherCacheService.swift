//
//  WeatherCacheService.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 27.03.2024.
//

import Foundation

class CacheService {
    static let shared = CacheService()
    private let kWeatherDataKey = "cachedWeatherDataKey"

    func cacheWeatherData(_ weatherData: WeatherData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherData) {
            UserDefaults.standard.set(encoded, forKey: kWeatherDataKey)
        }
    }

    func getCachedWeatherData() -> WeatherData? {
        if let data = UserDefaults.standard.data(forKey: kWeatherDataKey) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(WeatherData.self, from: data) {
                return decoded
            }
        }
        return nil
    }
}

