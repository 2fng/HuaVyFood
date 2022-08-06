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
        ac.view.tintColor = UIColor.logoPink
        let okAction = UIAlertAction(title: "Đóng", style: .cancel) { _ in
            completion?()
        }
        ac.addAction(okAction)
        present(ac, animated: true, completion: nil)
    }

    func showAlert(message: String,
                   leftCompletion: (() -> Void)? = nil,
                   rightCompletion: (() -> Void)? = nil) {
        let ac = UIAlertController(title: nil,
                                   message: message,
                                   preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Đồng ý", style: .destructive) { _ in
            rightCompletion?()
        }
        let closeAction = UIAlertAction(title: "Huỷ", style: .cancel)
        ac.addAction(closeAction)
        ac.addAction(okAction)
        present(ac, animated: true, completion: nil)
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
