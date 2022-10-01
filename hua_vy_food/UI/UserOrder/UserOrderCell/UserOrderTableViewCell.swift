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
        viewContainer.do {
            $0.layer.cornerRadius = 5
            $0.backgroundColor = .white
        }

        reOrderButton.rx.tap
            .map { [unowned self] in
                reOrderButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
