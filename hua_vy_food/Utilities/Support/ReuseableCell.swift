//
//  ReuseableCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 18/08/2022.
//

import Foundation
import UIKit

protocol ReuseableCell {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension ReuseableCell {
    static var identifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
