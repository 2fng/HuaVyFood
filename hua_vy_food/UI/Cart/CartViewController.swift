//
//  CartViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 10/09/2022.
//

import UIKit

final class CartViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private var cart = Cart()

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    func configCart(cart: Cart) {
        self.cart = cart
    }

    private func configView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(ProductTableViewCell.nib, forCellReuseIdentifier: ProductTableViewCell.identifier)
        }
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
        cell.configCell(data: cart.items[indexPath.row])
        cell.handleAdjustItemQuantity = { [unowned self] product in
            if product.quantity < 1 {
                cart.items.removeAll { cartProduct in
                    cartProduct.id == product.id
                }
                tableView.reloadData()
            }
        }
        return cell
    }
}

extension CartViewController: UITableViewDelegate {

}
