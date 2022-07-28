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
}
