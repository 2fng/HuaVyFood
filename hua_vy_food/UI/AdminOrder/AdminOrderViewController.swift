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
    private var statuses = [String]()
    private var paymentStatuses = [String]()

    // Trigger
    private let getOrdersTrigger = PublishSubject<Void>()
    private let getOrderStatusTrigger = PublishSubject<Void>()
    private let getPaymentStatusTrigger = PublishSubject<Void>()
    private let updateOrderStatusTrigger = PublishSubject<Order>()
    private let updateOrderPaymentStatusTrigger = PublishSubject<Order>()

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
        let input = AdminOrderViewModel.Input(
            getOrdersTrigger: getOrdersTrigger.asDriverOnErrorJustComplete(),
            getOrderStatusTrigger: getOrderStatusTrigger.asDriverOnErrorJustComplete(),
            getPaymentStatusTrigger: getPaymentStatusTrigger.asDriverOnErrorJustComplete(),
            updateOrderStatusTrigger: updateOrderStatusTrigger.asDriverOnErrorJustComplete(),
            updateOrderPaymentStatusTrigger: updateOrderPaymentStatusTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.getOrders
            .drive(ordersBinder)
            .disposed(by: disposeBag)

        output.statuses
            .drive(orderStatusesBinder)
            .disposed(by: disposeBag)

        output.paymentStatus
            .drive(paymentStatusesBinder)
            .disposed(by: disposeBag)

        output.updateOrderStatus
            .drive(updateOrderStatusBinder)
            .disposed(by: disposeBag)

        output.updateOrderPaymentStatus
            .drive(updateOrderPaymentStatusBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)

        getOrdersTrigger.onNext(())
        getPaymentStatusTrigger.onNext(())
        getOrderStatusTrigger.onNext(())
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

    private var orderStatusesBinder: Binder<[OrderStatus]> {
        return Binder(self) { vc, statuses in
            vc.statuses = statuses
                .sorted(by: { order1, order2 in
                order1.id > order2.id
            })
                .map { $0.name }
            vc.tableView.reloadData()
        }
    }

    private var paymentStatusesBinder: Binder<[String]> {
        return Binder(self) { vc, statuses in
            vc.paymentStatuses = statuses
            vc.tableView.reloadData()
        }
    }

    private var updateOrderStatusBinder: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.getOrdersTrigger.onNext(())
        }
    }

    private var updateOrderPaymentStatusBinder: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.getOrdersTrigger.onNext(())
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
        cell.configCell(order: orders[indexPath.row], isAdmin: true)
        cell.handleChooseStatus = { [unowned self] in
            let vc = PopupListViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
            // Callbacks
            vc.getData(tableViewData: statuses, selectedData: orders[indexPath.row].status)
            vc.handleDoneButton = { [unowned self] data in
                if let data = data as? String {
                    orders[indexPath.row].status = data
                    updateOrderStatusTrigger.onNext(orders[indexPath.row])
                }
            }
        }
        cell.handleChoosePaymentStatus = { [unowned self] in
            let vc = PopupListViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
            // Callbacks
            let isPaid = orders[indexPath.row].paidDate != Date(timeIntervalSince1970: 0) ? "Đã thanh toán" : "Chưa thanh toán"
            vc.getData(tableViewData: paymentStatuses, selectedData: isPaid)
            vc.handleDoneButton = { [unowned self] data in
                if let data = data as? String {
                    orders[indexPath.row].paidDate = (data == "Đã thanh toán") ? Date() : nil
                    updateOrderPaymentStatusTrigger.onNext(orders[indexPath.row])
                }
            }
        }
        return cell
    }
}

extension AdminOrderViewController: UITableViewDelegate {

}
