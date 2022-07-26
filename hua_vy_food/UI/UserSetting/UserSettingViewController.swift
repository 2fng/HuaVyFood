//
//  UserSettingViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 06/08/2022.
//

import UIKit
import Then
import RxCocoa
import RxSwift

final class UserSettingViewController: UIViewController {
    // Admin
    @IBOutlet private weak var logOutButton: UIButton!
    @IBOutlet private weak var adminViewContainer: UIView!
    @IBOutlet private weak var adminOrderButton: UIButton!
    @IBOutlet private weak var adminProductButton: UIButton!
    @IBOutlet private weak var adminResponseButton: UIButton!
    // User
    @IBOutlet private weak var userViewContainer: UIView!
    @IBOutlet private weak var userOrderButton: UIButton!
    @IBOutlet weak var userResponseButton: UIButton!

    private let disposeBag = DisposeBag()
    private let viewModel = UserSettingViewModel(userRepository: UserRepository())

    private let logOutTrigger = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func bindViewModel() {
        let input = UserSettingViewModel.Input(logoutTrigger: logOutTrigger.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input)

        output.logout
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

    private func setupView() {
        self.navigationItem.backButtonTitle = "Quay lại"
        self.navigationController?.navigationBar.tintColor = UIColor.logoPink
        let adminButtons = [adminOrderButton, adminProductButton, adminResponseButton]
        let userButtons = [userOrderButton, userResponseButton]
        adminViewContainer.isHidden = !UserManager.shared.getUserIsAdmin()
        
        logOutButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        adminButtons.forEach { adminButton in
            adminButton?.do {
                $0.layer.cornerRadius = 5
                $0.shadowView(cornerRadius: 5)
            }
        }

        userButtons.forEach { adminButton in
            adminButton?.do {
                $0.layer.cornerRadius = 5
                $0.shadowView(cornerRadius: 5)
            }
        }

        // Admin
        adminProductButton.rx.tap
            .map { [unowned self] in
                adminProductButton.animationSelect()
                navigationController?.pushViewController(ManagerProductViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        adminOrderButton.rx.tap
            .map { [unowned self] in
                adminOrderButton.animationSelect()
                navigationController?.pushViewController(AdminOrderViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        adminResponseButton.rx.tap
            .map { [unowned self] in
                adminResponseButton.animationSelect()
                navigationController?.pushViewController(ManagerResponseViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        // User
        userOrderButton.rx.tap
            .map { [unowned self] in
                userOrderButton.animationSelect()
                navigationController?.pushViewController(UserOrderViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        userResponseButton.rx.tap
            .map { [unowned self] in
                userResponseButton.animationSelect()
                navigationController?.pushViewController(UserResponseListViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        logOutButton.rx.tap
            .map { [unowned self] in
                logOutButton.animationSelect()
                showAlert(message: "Bạn có chắc chắn muốn đăng xuất không? :(",
                          rightCompletion: {
                    self.logOutTrigger.onNext(())
                })
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
