//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import UIKit
import Foundation
import SnapKit
import CoreLocation

class ViewController: UIViewController {

    private let longitudeInput = WTextField()
    private let latitudeInput = WTextField()
    private let temperatureLabel = WLabel()
    private let humidityLabel = WLabel()
    private let conditionLabel = WLabel()
    private let submitButton = WButton()
    private let tempFormatSegmentedControl = WSegmentedControl(items: ["Celsius", "Fahrenheit"])
    private let switchLabel = WLabel()
    private var cachedWeatherData: WeatherData? = nil
    private let locationManager = CLLocationManager()
    private let weatherIconImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
        setupCurrentLocation()
    }

    private func updateLabelWithAnimation(_ label: UILabel, newText: String, delay: TimeInterval) {
        UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseOut, animations: {
            label.alpha = 0.0
        }) { (finished) in

            label.text = newText


            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: {
                label.alpha = 1.0
            }, completion: nil)
        }
    }



    func download(from url: URL, completion: @escaping (_ data: Data)-> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            completion(data)

        }.resume()
    }


    private func setupCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    private func setupViews() {
        weatherIconImageView.contentMode = .scaleAspectFit

        setupInputs()

        [
            longitudeInput,
            latitudeInput,
            temperatureLabel,
            humidityLabel,
            conditionLabel,
            submitButton,
            tempFormatSegmentedControl,
            switchLabel,
            weatherIconImageView
        ].forEach { subView in
            view.addSubview(subView)
        }
        setupSubmitButton()
        setupTempFormatSwitch()
    }

    private func setupTempFormatSwitch() {
        tempFormatSegmentedControl.addTarget(self, action: #selector(formatChanged), for: .valueChanged)

        tempFormatSegmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }

    @objc func formatChanged() {
        guard let lastFetchedWeatherData = self.cachedWeatherData else { return }
        displayWeatherData(lastFetchedWeatherData)
    }


    private func setupInputs() {
        longitudeInput.placeholder = "Longitude"
        longitudeInput.keyboardType = .decimalPad
        longitudeInput.clearButtonMode = .whileEditing


        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace, target: nil, action: nil
        )
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard)
        )

        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        longitudeInput.inputAccessoryView = toolbar
        latitudeInput.inputAccessoryView = toolbar

        latitudeInput.placeholder = "Latitude"
        latitudeInput.keyboardType = .decimalPad
        latitudeInput.clearButtonMode = .whileEditing

    }


    @objc func dismissKeyboard() {
        self.resignFirstResponder()
        view.endEditing(true)
    }

    private func setupSubmitButton() {

        submitButton.setTitle("Check Weather", for: .normal)

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(longitudeInput.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        submitButton.addTarget(
            self, action: #selector(onSubmitButtonTapped), for: .touchUpInside
        )

    }

    @objc private func onSubmitButtonTapped() {
        dismissKeyboard()

        // Validate inputs for double
        let latitudeText = self.latitudeInput.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"
        let longitudeText = self.longitudeInput.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0"

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        let latitude = formatter.number(from: latitudeText)?.doubleValue
        let longitude = formatter.number(from: longitudeText)?.doubleValue


        guard let latitude = latitude, let longitude = longitude else {

            showAlert(title: "Input error", message: "Invalid input format for latitude or longitude")
            return
        }

        print("Latitude: \(latitudeText), Longitude: \(longitudeText)")

        WeatherService.shared.fetchData(
            latitude: latitude, longitude: longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self?.displayWeatherData(weatherData)
                case .failure(let error):

                    self?.showAlert(
                        title: "Error",
                        message: "Failed to fetch weather data: \(error.localizedDescription)"
                    )
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
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        conditionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        humidityLabel.snp.makeConstraints { make in
            make.top.equalTo(conditionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        weatherIconImageView.snp.makeConstraints { make in
            make.top.equalTo(humidityLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }


    private func displayWeatherData(_ data: WeatherData) {
        self.cachedWeatherData = data
        let selectedFormat = tempFormatSegmentedControl.selectedSegmentIndex == 0
        ? "Celsius"
        : "Fahrenheit"

        let formattedTemperature = convertTemperature(
            data.temperature, to: selectedFormat
        )

        updateLabelWithAnimation(
            temperatureLabel,
            newText: "Temperature: \(formattedTemperature)°\(selectedFormat.prefix(1))",
            delay: 0.3
        )
        updateLabelWithAnimation(
            humidityLabel,
            newText: "Humidity: \(data.humidity)%",
            delay: 0.6
        )
        updateLabelWithAnimation(
            conditionLabel,
            newText: "Condition: \(data.condition)",
            delay: 0.9
        )

        if let iconURL = WeatherService.shared.getIconURL(forIconCode: data.icon) {
            download(from: iconURL) { data in
                DispatchQueue.main.async {
                    UIView.animate(
                        withDuration: 0.4,
                        delay: 1.3,
                        options: .curveEaseIn,
                        animations: {
                            self.weatherIconImageView.alpha = 0
                        }) { _ in
                            self.weatherIconImageView.image = UIImage(data: data)

                            UIView.animate(withDuration: 0.4, animations: {
                                self.weatherIconImageView.alpha = 1
                            })
                        }
                }
            }
        }
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 8

            latitudeInput.text = formatter.string(from: NSNumber(value: latitude))
            longitudeInput.text = formatter.string(from: NSNumber(value: longitude))
            onSubmitButtonTapped()

            // Update location only once
            locationManager.stopUpdatingLocation()
            print("Current location: \(latitude), \(longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

func convertTemperature(_ temperature: Double, to format: String) -> Double {
    switch format {
    case "Celsius":
        return temperature
    case "Fahrenheit":
        return (temperature * 9/5) + 32
    default:
        return temperature
    }
}
