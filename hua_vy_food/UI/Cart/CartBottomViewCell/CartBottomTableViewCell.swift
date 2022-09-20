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

    private var couponPrice: Double = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configView()
    }

    private func configView() {
        couponTextField.do {
            let textFieldHeight = $0.frame.height / 2
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.hex("#EEEEEE").cgColor
            $0.layer.cornerRadius = textFieldHeight
        }

        couponSubmitButton.do {
            let textFieldHeight = $0.frame.height / 2
            $0.layer.cornerRadius = textFieldHeight
        }
    }

    func configCell(cart: Cart) {
        totalPriceBeforeValue.text = convertToPrice(value: cart.totalValue)
        totalValue.text = convertToPrice(value: cart.totalValue - couponPrice)
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
