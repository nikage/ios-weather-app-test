//
//  OpenWeatherMap.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import Foundation

struct WeatherResponse: Codable {
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Weather: Codable {
    let main: String
    let icon: String
}

struct WeatherData: Codable {
    let temperature: Double
    let humidity: Int
    let condition: String
    let icon: String

}
