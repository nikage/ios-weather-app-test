//
//  TextField.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import Foundation
import UIKit

class WTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeAppearance()
    }

    private func customizeAppearance() {
        self.borderStyle = .roundedRect
        self.backgroundColor = .white
        self.textColor = .black
        self.font = UIFont.systemFont(ofSize: 14)
        self.placeholder = "Enter value"
    }
}
