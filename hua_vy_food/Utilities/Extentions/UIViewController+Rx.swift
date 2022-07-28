////
////  UIViewController+Rx.swift
////  hua_vy_food
////
////  Created by Hua Son Tung on 28/07/2022.
////
//
//import Foundation
//import Alamofire
//import RxSwift
//
//extension Reactive where Base: UIViewController {
//    var error: Binder<Error> {
//        return Binder(base) { viewController, error in
//            switch error {
//            case let apiError as APIResponseError:
//                if !(viewController is SignInViewController)
//                    && apiError.statusCode == Constant.expiredTokenStatusCode {
//                    viewController.showError(message: apiError.errorDescription, completion: {
//                        viewController.navigationController?.setRootViewController(SignInViewController.instance())
//                    })
//                } else {
//                    viewController.showError(message: apiError.errorDescription)
//                }
//            case let requestError as APIHandleRequestError:
//                viewController.showError(message: requestError.errorDescription)
//            default:
//                var message = ""
//                if !NetworkReachabilityManager()!.isReachable {
//                    message = Localized.messageNoInternet
//                } else {
//                    message = Localized.deploySeverMessage
//                }
//
//                viewController.showAlertDefault(title: Localized.notification,
//                                                content: message,
//                                                rightTitle: Localized.close,
//                                                rightCompletion: {
//                                                    SVProgressHUD.dismiss()
//                                                })
//            }
//        }
//    }
//
//    var isLoading: Binder<Bool> {
//        return Binder(base) { _, isLoading in
//            if isLoading {
//                SVProgressHUD.setDefaultMaskType(.custom)
//                SVProgressHUD.setForegroundColor(.primaryDark)
//                SVProgressHUD.setBackgroundColor(.whiteTransparent50)
//                SVProgressHUD.setBackgroundLayerColor(UIColor.black.withAlphaComponent(0.3))
//                SVProgressHUD.show()
//            } else {
//                SVProgressHUD.dismiss()
//            }
//        }
//    }
//}
