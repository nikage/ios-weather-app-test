//
//  Label.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import Foundation
import UIKit

class WLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeBackground()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeBackground()
    }

    private func customizeBackground() {

    }
}
