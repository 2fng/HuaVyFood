//
//  ManagerProductViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 09/08/2022.
//

import UIKit
import Then
import RxSwift
import RxCocoa

final class ManagerProductViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var floatingButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
    }

    private func setUpView() {
        floatingButton.do {
            $0.layer.cornerRadius = 25
            $0.shadowView(color: .logoPink, cornerRadius: 25)
        }

        floatingButton.rx.tap
            .map { [unowned self] in
                floatingButton.animationSelect()
                navigationController?.pushViewController(AddNewViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
