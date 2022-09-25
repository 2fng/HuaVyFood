//
//  AddNewShippingInfoViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 22/09/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class AddNewShippingInfoViewController: UIViewController {
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var numberTextField: UITextField!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!

    private let viewModel = AddNewShippingInfoViewModel(userRepository: UserRepository())
    private let disposeBag = DisposeBag()
    private var userShippingInfo = UserShippingInfo()

    private let submitTrigger = PublishSubject<UserShippingInfo>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupView()
    }

    private func setupView() {
        submitButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        submitButton.rx.tap
            .map { [unowned self] in
                self.submitButton.animationSelect()
            }
            .subscribe(onNext: { [unowned self] in
                userShippingInfo.uid = UserManager.shared.getUserID()
                userShippingInfo.profileName = titleTextField.text ?? ""
                userShippingInfo.fullName = nameTextField.text ?? ""
                userShippingInfo.mobileNumber = numberTextField.text ?? ""
                userShippingInfo.address = addressTextField.text ?? ""
                if userShippingInfo.profileName.isEmpty ||
                    userShippingInfo.fullName.isEmpty ||
                    userShippingInfo.mobileNumber.isEmpty ||
                    userShippingInfo.address.isEmpty {
                    showError(message: "Vui lòng điền đủ các trường thông tin!")
                } else {
                    self.submitTrigger.onNext(userShippingInfo)
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = AddNewShippingInfoViewModel.Input(updateUserShippingInfoTrigger: submitTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.updateUserShippingInfo
            .drive(addNewShippingInfoBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)
    }
}

// MARK: Binder
extension AddNewShippingInfoViewController {
    private var addNewShippingInfoBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.showAlert(message: message,
                      okButtonOnly: true,
                      okCompletion: {
                vc.navigationController?.popViewController(animated: true)
            })
        }
    }
}
