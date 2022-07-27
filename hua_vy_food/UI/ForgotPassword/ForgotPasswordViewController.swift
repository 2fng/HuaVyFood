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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
    }

    private func setUpView() {
        confirmButton.do {
            $0.layer.cornerRadius = 5
        }

        confirmButton.rx.tap
            .subscribe(onNext: {
                print("Reset password!")
            })
            .disposed(by: disposeBag)
    }
}
