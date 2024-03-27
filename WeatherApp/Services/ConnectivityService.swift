//
//  ConnectivityService.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 27.03.2024.
//

import Foundation
import Network

class ConnectivityService {
    static let shared = ConnectivityService()
    private let monitor = NWPathMonitor()
    private var isConnected: Bool = true

    var isNetworkAvailable: Bool {
        return isConnected
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}

