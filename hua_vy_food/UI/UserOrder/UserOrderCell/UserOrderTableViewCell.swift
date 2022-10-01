//
//  UserOrderTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 01/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class UserOrderTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var statusContainerView: UIView!
    @IBOutlet private weak var statusImage: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var quantityAndPaymentMethodLabel: UILabel!
    @IBOutlet private weak var paymentStatusLabel: UILabel!
    @IBOutlet private weak var reOrderButton: UIButton!

    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        // Initialization code
    }

    private func setupView() {
        reOrderButton.layer.cornerRadius = 5
        statusContainerView.roundCorners(corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        viewContainer.do {
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .white
        }

        reOrderButton.rx.tap
            .map { [unowned self] in
                reOrderButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func configCell(order: Order, shippingInfo: UserShippingInfo) {
        var cartQuantity = 0
        for item in order.cart.items {
            cartQuantity += item.quantity
        }
        dateLabel.text = "\(order.orderDate)"
        addressLabel.text = "\(shippingInfo.address)"
        totalLabel.text = convertToPrice(value: Double(order.totalValue))
        quantityAndPaymentMethodLabel.text = "(\(cartQuantity) món) - \(order.paymentMethod.name)"
        paymentStatusLabel.text = order.paidDate != nil ? "Đã thanh toán" : "Chưa thanh toán"
        switch order.status {
        case "Đang xử lý":
            statusContainerView.backgroundColor = UIColor.onGoing
            statusImage.image = UIImage(named: "pending")
        default:
            break
        }
    }

    private func convertToPrice(value: Double) -> String {
        // Price's logic
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        if let string = formatter.string(from: value as NSNumber) {
            let priceString = String(string.dropFirst()) + "đ"
            return priceString
        } else {
            return "Không có giá trị"
        }
    }
}
