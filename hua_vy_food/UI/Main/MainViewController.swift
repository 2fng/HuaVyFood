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
    @IBOutlet private weak var adminModeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        setupView()
    }

    private var isAdminMode = false {
        didSet {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
                self.tableView.backgroundColor = isAdminMode ? .logoPink : .white
            }, completion: { _ in
                self.tableView.reloadData()
            })
        }
    }

    private func setupView() {
        self.navigationItem.backButtonTitle = "Quay lại"
        isAdminMode = UserManager.shared.getUserIsAdmin()
        if !isAdminMode {
            adminModeSegmentedControl.selectedSegmentIndex = 1
        }
        
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

        adminModeSegmentedControl.do {
            $0.isHidden = !UserManager.shared.getUserIsAdmin()
            $0.shadowView()
        }

        adminModeSegmentedControl.rx.selectedSegmentIndex.subscribe(onNext: { [unowned self] index in
            switch index {
            case 0:
                self.isAdminMode = true
            case 1:
                self.isAdminMode = false
            default:
                break
            }
        })
        .disposed(by: disposeBag)

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
