//
//  MainViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 25/07/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class MainViewController: UIViewController {
    @IBOutlet private weak var burgerMenuButton: UIButton!
    @IBOutlet private weak var shoppingCartButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        setupView()
    }

    private func setupView() {
        self.navigationItem.backButtonTitle = "Quay lại"
        
        burgerMenuButton.do {
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .white
            $0.shadowView(color: .lightGray, cornerRadius: 15)
        }

        shoppingCartButton.do {
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .white
            $0.shadowView(color: .lightGray, cornerRadius: 15)
        }

        burgerMenuButton.rx.tap
            .map { [unowned self] in
                burgerMenuButton.animationSelect()
                let vc = UserSettingViewController(nibName: "UserSettingViewController", bundle: nil)
                navigationController?.pushViewController(vc, animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        shoppingCartButton.rx.tap
            .map { [unowned self] in
                shoppingCartButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
