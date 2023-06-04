//
//  UIColor+Extensions.swift
//  Reefslab
//
//  Created by Tim Bornholdt on 6/4/23.
//

import UIKit
import Foundation

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
