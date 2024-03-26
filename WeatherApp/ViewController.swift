//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import UIKit
import Foundation
import SnapKit



func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
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


            if let weatherCondition = decodedData.weather.first?.main {
                let weatherData = WeatherData(
                    temperature: temperature, humidity: humidity, condition: weatherCondition
                )
                completion(.success(weatherData))
            } else {

                completion(.failure(
                    NSError(domain: "WeatherDataError", code: -4, userInfo: [NSLocalizedDescriptionKey: "No weather conditions found in the response."]))
                )
            }
        } catch {
            completion(.failure(error))
        }

    }

    task.resume()
}




class ViewController: UIViewController {

    // Define labels for displaying weather data
    private let temperatureLabel = UILabel()
    private let humidityLabel = UILabel()
    private let conditionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()

        // Example fetch call
        fetchWeatherData(latitude: 34.923096, longitude: 33.634045) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let weatherData):
                    self?.displayWeatherData(weatherData)
                case .failure(let error):
                    print("Error fetching weather data: \(error)")
                }
            }
        }
    }

    private func setupViews() {
        // Configure labels (you might want to customize them further)
        [temperatureLabel, humidityLabel, conditionLabel].forEach { label in
            label.textColor = .black
            label.textAlignment = .center
            view.addSubview(label)
        }
    }

    private func layoutViews() {
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        

        humidityLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        conditionLabel.snp.makeConstraints { make in
            make.top.equalTo(humidityLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    private func displayWeatherData(_ data: WeatherData) {
        // Update UI with the fetched weather data
        temperatureLabel.text = "Temperature: \(data.temperature)°C"
        humidityLabel.text = "Humidity: \(data.humidity)%"
        conditionLabel.text = "Condition: \(data.condition)"
    }
}


