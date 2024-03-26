//
//  SegmentControl.swift
//  WeatherApp
//
//  Created by Mykola Mikhno on 26.03.2024.
//

import Foundation
import UIKit

class WSegmentedControl: UISegmentedControl {
    init(items: [String], defaultIndex: Int = 0) {
        super.init(frame: .zero)

        for item in items {
            self.insertSegment(withTitle: item, at: self.numberOfSegments, animated: false)
        }

        self.selectedSegmentIndex = defaultIndex

        setupControl()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupControl() {
        
    }
}
