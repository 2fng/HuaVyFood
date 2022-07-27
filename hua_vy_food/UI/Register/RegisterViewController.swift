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

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        setUpView()
    }

    private func setUpView() {
        signUpButton.do {
            $0.layer.cornerRadius = 5
        }

        signUpButton.rx.tap
            .subscribe(onNext: {
                print("Sign Up!")
            })
            .disposed(by: disposeBag)
    }
}
