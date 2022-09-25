//
//  CartBottomTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 19/09/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class CartBottomTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var couponTextField: CustomTextField!
    @IBOutlet private weak var couponSubmitButton: UIButton!
    @IBOutlet private weak var totalPriceBeforeLabel: UILabel!
    @IBOutlet private weak var totalPriceBeforeValue: UILabel!
    @IBOutlet private weak var couponLabel: UILabel!
    @IBOutlet private weak var couponValue: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var totalValue: UILabel!
    @IBOutlet private weak var shippingInfoViewContainer: UIView!
    @IBOutlet private weak var shippingInfoNameLabel: UILabel!
    @IBOutlet private weak var shippingInfoPhoneLabel: UILabel!
    @IBOutlet private weak var shippingInfoAddressLabel: UILabel!

    private let disposeBag = DisposeBag()
    private var couponPrice: Double = 0

    var handleNavigateToCreateShippingInfo: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }

    private func configView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shippingInfoTapped))

        couponTextField.do {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.hex("#EEEEEE").cgColor
            $0.layer.cornerRadius = 5
        }

        couponSubmitButton.do {
            $0.layer.cornerRadius = 5
        }

        shippingInfoViewContainer.do {
            $0.layer.cornerRadius = 15
            $0.addGestureRecognizer(tapGestureRecognizer)
        }

        couponSubmitButton.rx.tap
            .map { [unowned self] in
                couponSubmitButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func configCell(cart: Cart, userShippingInfo: UserShippingInfo) {
        totalPriceBeforeValue.text = convertToPrice(value: cart.totalValue)
        totalValue.text = convertToPrice(value: cart.totalValue - couponPrice)
        shippingInfoNameLabel.text = userShippingInfo.fullName.isEmpty ? "Không có dữ liệu tên" : userShippingInfo.fullName
        shippingInfoPhoneLabel.text = userShippingInfo.mobileNumber.isEmpty ? "Không có dữ liệu số điện thoại" : userShippingInfo.mobileNumber
        shippingInfoAddressLabel.text = userShippingInfo.address.isEmpty ? "Không có dữ liệu địa chỉ" : userShippingInfo.address
    }

    @objc private func shippingInfoTapped() {
        handleNavigateToCreateShippingInfo?()
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
