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
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var paymentStatusTextField: UITextField!
    @IBOutlet private weak var reOrderButton: UIButton!
    @IBOutlet private weak var statusTextField: UITextField!
    @IBOutlet private weak var deleteOrderButton: UIButton!

    private let disposeBag = DisposeBag()
    private var isAdmin = false

    // Callbacks
    var handleChooseStatus: (() -> Void)?
    var handleChoosePaymentStatus: (() -> Void)?
    var handleDeleteOrder: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        // Initialization code
    }

    private func setupView() {
        statusContainerView.roundCorners(corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        let tappedOnStatusTextField = UITapGestureRecognizer(target: self, action: #selector(statusTapped))
        let tappedOnPaymentStatusTextField = UITapGestureRecognizer(target: self, action: #selector(paymentStatusTapped))
        statusTextField.addGestureRecognizer(tappedOnStatusTextField)
        paymentStatusTextField.addGestureRecognizer(tappedOnPaymentStatusTextField)

        reOrderButton.do {
            $0.layer.cornerRadius = 5
            $0.isHidden = true
        }

        viewContainer.do {
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .white
        }

        deleteOrderButton.rx.tap
            .map { [unowned self] in
                deleteOrderButton.animationSelect()
                handleDeleteOrder?()
            }
            .subscribe()
            .disposed(by: disposeBag)

        reOrderButton.rx.tap
            .map { [unowned self] in
                reOrderButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func configCell(order: Order, isAdmin: Bool = false) {
        self.isAdmin = isAdmin
        var cartQuantity = 0
        for item in order.cart.items {
            cartQuantity += item.quantity
        }
        statusTextField.isHidden = !isAdmin
        statusTextField.text = order.status
        dateLabel.text = "\(order.orderDate)"
        addressLabel.text = "\(order.userShippingInfo.address)"
        totalLabel.text = convertToPrice(value: Double(order.totalValue))
        quantityAndPaymentMethodLabel.text = "(\(cartQuantity) món) - \(order.paymentMethod.name)"
        paymentStatusTextField.text = order.paidDate != Date(timeIntervalSince1970: 0) ? "Đã thanh toán" : "Chưa thanh toán"
        nameLabel.text = order.userShippingInfo.fullName
        phoneNumberLabel.text = order.userShippingInfo.mobileNumber
        deleteOrderButton.setTitle(isAdmin ? "Xoá" : "Huỷ", for: .normal)
        if order.status != "Đang xử lý" && !isAdmin {
            deleteOrderButton.isHidden = true
        } else {
            deleteOrderButton.isHidden = false
        }
        switch order.status {
        case "Đang xử lý":
            statusContainerView.backgroundColor = UIColor.onGoing
            statusImage.image = UIImage(named: "pending")
        case "Đang giao hàng":
            statusContainerView.backgroundColor = UIColor.shipping
            statusImage.image = UIImage(named: "forward")
        case "Hoàn thành":
            statusContainerView.backgroundColor = UIColor.finish
            statusImage.image = UIImage(named: "approved")
        case "Huỷ":
            statusContainerView.backgroundColor = UIColor.cancel
            statusImage.image = UIImage(named: "cancel")
        case "Từ chối":
            statusContainerView.backgroundColor = UIColor.reject
            statusImage.image = UIImage(named: "rejected")
        default:
            break
        }
    }

    @objc private func statusTapped() {
        handleChooseStatus?()
    }

    @objc private func paymentStatusTapped() {
        if isAdmin {
            handleChoosePaymentStatus?()
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
