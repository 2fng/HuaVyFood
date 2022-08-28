//
//  UIColor+.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 27/07/2022.
//

import Foundation
import UIKit

extension UIColor {

    static func hex(_ hexStr: String, alpha: CGFloat = 1) -> UIColor {
        let scanner = Scanner(string: hexStr.replacingOccurrences(of: "#", with: ""))
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let redColor = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let greenColor = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let blueColor = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: alpha)
        } else {
            return .white
        }
    }

    static func rgba(_ red: Int?, green: Int?, blue: Int?, alpha: CGFloat = 1.0) -> UIColor {

        guard let redColor = red, let greenColor = green, let blueColor = blue else {
            return .white
        }

        let denominator: CGFloat = 255.0
        let color = UIColor(red: CGFloat(redColor) / denominator,
                            green: CGFloat(greenColor) / denominator,
                            blue: CGFloat(blueColor) / denominator,
                            alpha: alpha)
        return color
    }

    static let logoPink = UIColor.hex("#FC8C84")
    static let primaryDark = UIColor.hex("#DF3A2D")
    static let whiteTransparent50 = UIColor.hex("#8Cffffff")
}
