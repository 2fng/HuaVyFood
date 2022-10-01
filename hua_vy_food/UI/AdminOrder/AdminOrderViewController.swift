//
//  AdminOrderViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 01/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class AdminOrderViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private let viewModel = AdminOrderViewModel(cartRepository: CartRepository(),
                                               userRepository: UserRepository())

    // Variables
    private var orders = [Order]()

    // Trigger
    private let getOrdersTrigger = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(UserOrderTableViewCell.nib, forCellReuseIdentifier: UserOrderTableViewCell.identifier)
        }
    }

    private func bindViewModel() {
        let input = AdminOrderViewModel.Input(getOrdersTrigger: getOrdersTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.getOrders
            .drive(ordersBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)

        getOrdersTrigger.onNext(())
    }
}

extension AdminOrderViewController {
    private var ordersBinder: Binder<[Order]> {
        return Binder(self) { vc, orders in
            vc.orders = orders.sorted(by: { order1, order2 in
                order1.orderDate > order2.orderDate
            })
            vc.tableView.reloadData()
        }
    }
}

extension AdminOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserOrderTableViewCell.identifier) as? UserOrderTableViewCell else {
            return UITableViewCell()
        }
        cell.configCell(order: orders[indexPath.row])
        return cell
    }
}

extension AdminOrderViewController: UITableViewDelegate {

}
