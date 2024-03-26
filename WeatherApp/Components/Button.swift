//
//  Button.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import Foundation

import UIKit

class WButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeAppearance()
    }

    private func customizeAppearance() {
        self.backgroundColor = UIColor.systemBlue
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 5
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
}
