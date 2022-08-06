//
//  ForgotPasswordViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 27/07/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class ForgotPasswordViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var confirmButton: UIButton!

    private let disposeBag = DisposeBag()
    private let viewModel = ForgotPasswordViewModel(userRepository: UserRepository())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
        bindViewModel()
    }

    private func bindViewModel() {
        let input = ForgotPasswordViewModel.Input(
            emailTrigger: emailTextField.rx.text.orEmpty.asDriver(),
            submitTrigger: confirmButton.rx.tap.asDriver())

        let output = viewModel.transform(input)

        output.submit
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.setViewControllers([LoginViewController()], animated: true)
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
        confirmButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        confirmButton.rx.tap
            .map { [unowned self] in
                self.confirmButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
