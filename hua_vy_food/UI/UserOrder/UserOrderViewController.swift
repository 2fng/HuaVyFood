//
//  UserOrderViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 01/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class UserOrderViewController: UIViewController {
    @IBOutlet weak var orderTableView: UITableView!

    private let disposeBag = DisposeBag()
    private let viewModel = UserOrderViewModel(cartRepository: CartRepository(),
                                               userRepository: UserRepository())

    // Variables
    private var orders = [Order]()
    private var userShippingInfo = UserShippingInfo()

    // Trigger
    private let getOrdersTrigger = PublishSubject<Void>()
    private let getUserShippingInfo = PublishSubject<Void>()
    private let deleteOrderTrigger = PublishSubject<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        orderTableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(UserOrderTableViewCell.nib, forCellReuseIdentifier: UserOrderTableViewCell.identifier)
        }
    }

    private func bindViewModel() {
        let input = UserOrderViewModel.Input(getOrdersTrigger: getOrdersTrigger.asDriverOnErrorJustComplete(),
                                             userShippingInfoTrigger: getUserShippingInfo.asDriverOnErrorJustComplete(),
                                             deleteOrderTrigger: deleteOrderTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.getOrders
            .drive(ordersBinder)
            .disposed(by: disposeBag)

        output.userShippingInfo
            .drive(userShippingInfoBinder)
            .disposed(by: disposeBag)

        output.deleteOrder
            .drive(deleteOrderBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)

        getOrdersTrigger.onNext(())
        getUserShippingInfo.onNext(())
    }
}

extension UserOrderViewController {
    private var userShippingInfoBinder: Binder<UserShippingInfo> {
        return Binder(self) { vc, returnUserShippingInfo in
            vc.userShippingInfo = returnUserShippingInfo
            vc.orderTableView.reloadData()
        }
    }

    private var ordersBinder: Binder<[Order]> {
        return Binder(self) { vc, orders in
            vc.orders = orders.sorted(by: { order1, order2 in
                order1.orderDate > order2.orderDate
            })
            vc.orderTableView.reloadData()
        }
    }

    private var deleteOrderBinder: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.getOrdersTrigger.onNext(())
        }
    }
}

extension UserOrderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserOrderTableViewCell.identifier) as? UserOrderTableViewCell else {
            return UITableViewCell()
        }
        cell.configCell(order: orders[indexPath.row])
        cell.handleDeleteOrder = { [unowned self] in
            showAlert(message: "Bạn có chắc chắn muốn xoá đơn hàng này không?",
                      rightCompletion: { [unowned self] in
                deleteOrderTrigger.onNext(orders[indexPath.row].documentID)
            })
        }
        return cell
    }
}

extension UserOrderViewController: UITableViewDelegate {
    
}
