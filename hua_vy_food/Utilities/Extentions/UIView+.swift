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
        shadowOpacity: Float = 0.4,
        height: CGFloat = 6.0,
        cornerRadius: Double = 0) {
        layer.do {
            $0.cornerRadius = cornerRadius
            $0.shadowColor = color.cgColor
            $0.shadowOffset = CGSize(width: 0.0, height: height)
            $0.shadowOpacity = shadowOpacity
            $0.shadowRadius = shadowRadius
            $0.masksToBounds = false
        }
    }

    func isVisible() -> Bool {
        func isVisible(inView: UIView?) -> Bool {
            guard let inView = inView else { return true }
            let viewFrame = inView.convert(self.bounds, from: self)
            if viewFrame.intersects(inView.bounds) {
                return isVisible(inView: inView.superview)
            }
            return false
        }
        return isVisible(inView: self.superview)
    }

    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}
