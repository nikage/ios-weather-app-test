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
    private let latitudeInput = WTextField()
    private let submitButton = WButton()
    private let temperatureLabel = WLabel()
    private let humidityLabel = WLabel()
    private let conditionLabel = WLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()


        WeatherService.shared.fetchWeatherData(
            latitude: 34.923096,
            longitude: 33.634045
        ) { result in
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
        setupInputs()

        [
            longitudeInput,
            latitudeInput,
            temperatureLabel,
            humidityLabel,
            conditionLabel,
            submitButton
        ].forEach { label in
            view.addSubview(label)
        }
        setupSubmitButton()
    }
    private func setupInputs() {
        longitudeInput.placeholder = "Longitude"
        longitudeInput.keyboardType = .decimalPad
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard)
        )
        toolbar.setItems([doneButton], animated: false)
        longitudeInput.inputAccessoryView = toolbar
        latitudeInput.inputAccessoryView = toolbar

        latitudeInput.placeholder = "Latitude"
        latitudeInput.keyboardType = .decimalPad
    }

    @objc func dismissKeyboard() {
        self.resignFirstResponder()
        view.endEditing(true)
    }

    private func setupSubmitButton() {

        submitButton.setTitle("Submit", for: .normal)

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(conditionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        submitButton.addTarget(self, action: #selector(onSubmitButtonTapped), for: .touchUpInside)

    }

    @objc private func onSubmitButtonTapped() {
        dismissKeyboard()

        // Validate inputs for double
        let latitudeText = self.latitudeInput.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
        let longitudeText = self.longitudeInput.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let latitude = formatter.number(from: latitudeText)?.doubleValue
        let longitude = formatter.number(from: longitudeText)?.doubleValue


        guard let latitude = latitude, let longitude = longitude else {

            print("Invalid input format for latitude or longitude")
            return
        }

        print("Latitude: \(latitudeText), Longitude: \(longitudeText)")

        WeatherService.shared.fetchWeatherData(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self?.displayWeatherData(weatherData)
                case .failure(let error):
                    print ("Failed to fetch weather data: \(error.localizedDescription)")
                }
            }
        }
    }

    private func layoutViews() {
        latitudeInput.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width - 40)
            make.height.equalTo(40)
        }

        longitudeInput.snp.makeConstraints { make in
            make.top.equalTo(latitudeInput.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(latitudeInput.snp.width)
            make.height.equalTo(latitudeInput.snp.height)
        }

        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(longitudeInput.snp.bottom).offset(20)
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


