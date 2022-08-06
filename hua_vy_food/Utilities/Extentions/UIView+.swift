//
//  UIView+.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/07/2022.
//

import Foundation
import UIKit

extension UIView {
    func animationSelect(duration: Double = 0.08, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration, animations: {
                self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            },
            completion: { _ in
                completion?()
                UIView.animate(withDuration: duration) {
                    self.transform = CGAffineTransform.identity
                }
            })
    }

    func shadowView(
        color: UIColor = UIColor.lightGray,
        shadowRadius: CGFloat = 8,
        height: CGFloat = 6.0,
        cornerRadius: Double = 0) {
        layer.do {
            $0.cornerRadius = cornerRadius
            $0.shadowColor = color.cgColor
            $0.shadowOffset = CGSize(width: 0.0, height: height)
            $0.shadowOpacity = 0.4
            $0.shadowRadius = shadowRadius
            $0.masksToBounds = false
        }
    }
}
