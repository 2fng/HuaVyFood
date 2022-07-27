//
//  LoginViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 25/07/2022.
//

import UIKit
import Then
import RxCocoa
import RxSwift

final class LoginViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var seePasswordTextField: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var loginWithGoogleButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        setUpView()
    }

    private func setUpView() {
        self.navigationItem.backButtonTitle = "Quay lại"
        self.navigationController?.navigationBar.tintColor = UIColor.logoPink
        loginButton.do {
            $0.layer.cornerRadius = 5
        }

        loginWithGoogleButton.do {
            $0.layer.cornerRadius = 5
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }

        registerButton.rx.tap
            .subscribe(onNext: {
                self.navigationController?.pushViewController(RegisterViewController(), animated: true)
            })
            .disposed(by: disposeBag)

        forgotPasswordButton.rx.tap
            .subscribe(onNext: {
                self.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
}
