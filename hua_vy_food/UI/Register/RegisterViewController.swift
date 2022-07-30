//
//  RegisterViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 27/07/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class RegisterViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!

    var viewModel = RegisterViewModel(userRepository: UserRepository())
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        setUpView()
    }

    func bindViewModel() {
        let input = RegisterViewModel.Input(
            emailTrigger: emailTextField.rx.text.orEmpty.asDriver(),
            passwordTrigger: passwordTextField.rx.text.orEmpty.asDriver(),
            confirmPasswordTrigger: confirmPasswordTextField.rx.text.orEmpty.asDriver(),
            registerTrigger: signUpButton.rx.tap.asDriver())

        let output = viewModel.transform(input)

        signUpButton.rx.tap
            .map { [unowned self] in
                self.signUpButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)

        output.register
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
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        signUpButton.do {
            $0.layer.cornerRadius = 5
        }
    }
}
