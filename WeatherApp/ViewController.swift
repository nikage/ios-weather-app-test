//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import UIKit
import Foundation
import SnapKit


class ViewController: UIViewController {

    private let longitudeInput = WTextField()
    private let laitudeInput = WTextField()
    private let temperatureLabel = WLabel()
    private let humidityLabel = WLabel()
    private let conditionLabel = WLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()


        WeatherService.shared.fetchWeatherData(latitude: 34.923096, 
                                               longitude: 33.634045) { result in
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

        [

            longitudeInput,
            laitudeInput,
            temperatureLabel,
            humidityLabel,
            conditionLabel
        ].forEach { label in
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
        temperatureLabel.text = "Temperature: \(data.temperature)°C"
        humidityLabel.text = "Humidity: \(data.humidity)%"
        conditionLabel.text = "Condition: \(data.condition)"
    }
}


