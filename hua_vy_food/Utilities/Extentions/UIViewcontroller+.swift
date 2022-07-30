//
//  UIViewcontroller+.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/07/2022.
//

import Foundation
import UIKit

extension UIViewController {

    func showError(message: String, completion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: "Lỗi",
                                   message: message,
                                   preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Đồng ý", style: .cancel) { _ in
            completion?()
        }
        ac.addAction(okAction)
        present(ac, animated: true, completion: nil)
    }
}
