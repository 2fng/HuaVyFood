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
import SVProgressHUD

final class LoginViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var seePasswordButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var loginWithGoogleButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!

    private let viewModel = LoginViewModel(userRepository: UserRepository())
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        setUpView()
    }

    private func bindViewModel() {
        let input = LoginViewModel.Input(
            emailTrigger: emailTextField.rx.text.orEmpty.asDriver(),
            passwordTrigger: passwordTextField.rx.text.orEmpty.asDriver(),
            loginTrigger: loginButton.rx.tap.asDriver())

        let output = viewModel.transform(input)

        output.login
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.setViewControllers([MainViewController()], animated: true)
            })
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)
    }

    private func setUpView() {
        self.navigationItem.backButtonTitle = "Quay lại"
        self.navigationController?.navigationBar.tintColor = UIColor.logoPink
        hideKeyboardWhenTappedAround()
        passwordTextField.isSecureTextEntry = true

        seePasswordButton.rx.tap
            .map { [unowned self] in
                seePasswordButton.animationSelect()
            }
            .subscribe(onNext: { [unowned self] in
                self.passwordTextField.isSecureTextEntry.toggle()
            })
            .disposed(by: disposeBag)

        loginButton.do {
            $0.layer.cornerRadius = 5
        }

        loginWithGoogleButton.do {
            $0.layer.cornerRadius = 5
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }

        loginButton.rx.tap
            .map { [unowned self] in
                self.loginButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)

        loginWithGoogleButton.rx.tap
            .map { [unowned self] in
                self.loginWithGoogleButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)

        registerButton.rx.tap
            .map { [unowned self] in
                self.registerButton.animationSelect()
            }
            .subscribe(onNext: { [unowned self] in
                self.navigationController?.pushViewController(RegisterViewController(), animated: true)
            })
            .disposed(by: disposeBag)

        forgotPasswordButton.rx.tap
            .map { [unowned self] in
                self.forgotPasswordButton.animationSelect()
            }
            .subscribe(onNext: { [unowned self] in
                self.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
}
