//
//  UIViewController+Rx.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/07/2022.
//

import Foundation
import Alamofire
import RxSwift
import SVProgressHUD

extension Reactive where Base: UIViewController {
    var error: Binder<Error> {
        return Binder(base) { viewController, error in
            viewController.showError(message: "\(error.localizedDescription)", completion: {
                SVProgressHUD.dismiss()
            })
        }
    }

    var isLoading: Binder<Bool> {
        return Binder(base) { _, isLoading in
            if isLoading {
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.logoPink)
                SVProgressHUD.setBackgroundColor(.whiteTransparent50)
                SVProgressHUD.setBackgroundLayerColor(UIColor.black.withAlphaComponent(0.3))
                SVProgressHUD.show()
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
}
