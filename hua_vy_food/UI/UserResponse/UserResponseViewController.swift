//
//  UserResponseViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 03/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class UserResponseViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var submitButton: UIButton!

    private let disposeBag = DisposeBag()
    private let viewModel = UserResponseViewModel(userRepository: UserRepository())

    private let submitTrigger = PublishSubject<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        hideKeyboardWhenTappedAround()

        textView.do {
            $0.delegate = self
            $0.shadowView(cornerRadius: 5)
        }

        submitButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        submitButton.rx.tap
            .map { [unowned self] in
                submitButton.animationSelect()
                if textView.text.count > 10 {
                    submitTrigger.onNext(textView.text)
                } else {
                    showAlert(message: "Phản hồi phải có ít nhất 11 ký tự", okButtonOnly: true)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = UserResponseViewModel.Input(
            submitResponseTrigger: submitTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.response
            .drive(responseBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)
    }
}

extension UserResponseViewController {
    private var responseBinder: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.showAlert(message: "Cảm ơn phản hồi của bạn ^^\n Hứa Vy Food sẽ cố gắng không ngừng để cải thiện để đem lại dịch vụ tốt nhất!", okButtonOnly: true,
                         okCompletion: {
                vc.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
}

extension UserResponseViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Hãy nhập phản hồi của bạn tại đây nhé... Nếu muốn phản ánh về chất lượng dịch vụ, bạn hãy để lại số điện thoại để chúng mình dễ liên lạc nha ^^" {
            textView.text = nil
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Hãy nhập phản hồi của bạn tại đây nhé... Nếu muốn phản ánh về chất lượng dịch vụ, bạn hãy để lại số điện thoại để chúng mình dễ liên lạc nha ^^"
        }
    }
}
