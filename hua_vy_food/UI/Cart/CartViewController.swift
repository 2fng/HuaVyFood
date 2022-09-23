//
//  CartViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 10/09/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class CartViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var checkoutButton: UIButton!

    private var cart = Cart()
    private var disposeBag = DisposeBag()
    private let viewModel = CartViewModel(cartRepository: CartRepository())

    // Triggers
    private let updateCartTrigger = PublishSubject<Cart>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configView()
    }

    func configCart(cart: Cart) {
        self.cart = cart
    }

    private func configView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = UITableView.automaticDimension
            $0.register(ProductTableViewCell.nib, forCellReuseIdentifier: ProductTableViewCell.identifier)
            $0.register(CartBottomTableViewCell.nib, forCellReuseIdentifier: CartBottomTableViewCell.identifier)
        }

        checkoutButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        checkoutButton.rx.tap
            .map { [unowned self] in
                checkoutButton.animationSelect()
                // navigationController?.pushViewController(CheckoutViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = CartViewModel.Input(updateCartTrigger: updateCartTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.updateCart
            .drive(updateCartMessage)
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
extension CartViewController {
    private var updateCartMessage: Binder<String> {
        return Binder(self) { vc, message in
            
        }
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < cart.items.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
            cell.configCell(data: cart.items[indexPath.row])
            cell.handleAdjustItemQuantity = { [unowned self] product in
                if product.quantity < 1 {
                    cart.items.removeAll { cartProduct in
                        cartProduct.id == product.id
                    }
                } else {
                    if let cartIndex = cart.items.firstIndex(where: { cartProduct in
                        cartProduct.id == product.id
                    }) {
                        cart.items[cartIndex] = product
                    } else {
                        cart.items.append(product)
                    }
                }
                cart.totalValue = 0
                for item in cart.items {
                    cart.totalValue += (item.price * Double(item.quantity))
                }
                updateCartTrigger.onNext(cart)
                tableView.reloadData()
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CartBottomTableViewCell.identifier) as? CartBottomTableViewCell else { return UITableViewCell() }
            cell.configCell(cart: cart)
            cell.handleNavigateToCreateShippingInfo = {
                self.navigationController?.pushViewController(AddNewShippingInfoViewController(), animated: true)
            }
            return cell
        }
    }
}

extension CartViewController: UITableViewDelegate {

}
