//
//  ProductTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 21/08/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import SDWebImage

final class ProductTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var productTitle: UILabel!
    @IBOutlet private weak var productCategory: UILabel!
    @IBOutlet private weak var productPrice: UILabel!
    @IBOutlet private weak var addItem: UIButton!
    @IBOutlet private weak var subtractItem: UIButton!
    @IBOutlet private weak var numberOfItemTextField: UITextField!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var updateButton: UIButton!

    private let disposeBag = DisposeBag()

    // Variables
    private var product = Product()
    private var isAdmin = false

    // Callbacks
    var handleRemoveButton: ((String) -> Void)?
    var handleUpdateButton: ((Product) -> Void)?
    var handleAdjustItemQuantity: ((Product) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupView() {
        viewContainer.do {
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 5
        }

        productImageView.do {
            $0.layer.cornerRadius = 5
        }

        addItem.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, shadowRadius: 5, shadowOpacity: 0.3, cornerRadius: 5)
        }

        subtractItem.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .gray, shadowRadius: 5, shadowOpacity: 0.1, cornerRadius: 5)
        }

        removeButton.do {
            $0.isHidden = !isAdmin
        }

        updateButton.do {
            $0.isHidden = !isAdmin
            $0.layer.cornerRadius = 5
            $0.shadowView(shadowRadius: 5, shadowOpacity: 0.3, cornerRadius: 5)
        }

        addItem.rx.tap
            .map { [unowned self] in
                self.addItem.animationSelect()
                product.quantity += 1
                numberOfItemTextField.text = String(product.quantity)
                UIView.animate(withDuration: 1.0, delay: 0.0) { [unowned self] in
                    subtractItem.isHidden = product.quantity >= 1 ? false : true
                    numberOfItemTextField.isHidden = product.quantity >= 1 ? false : true
                }
                handleAdjustItemQuantity?(product)
            }
            .subscribe()
            .disposed(by: disposeBag)

        subtractItem.rx.tap
            .map { [unowned self] in
                self.subtractItem.animationSelect()
                product.quantity -= 1
                numberOfItemTextField.text = String(product.quantity)
                UIView.animate(withDuration: 1.0, delay: 0.0) { [unowned self] in
                    subtractItem.isHidden = product.quantity >= 1 ? false : true
                    numberOfItemTextField.isHidden = product.quantity >= 1 ? false : true
                }
                handleAdjustItemQuantity?(product)
            }
            .subscribe()
            .disposed(by: disposeBag)

        removeButton.rx.tap
            .map { [unowned self] in
                self.removeButton.animationSelect()
                handleRemoveButton?(product.documentID)
            }
            .subscribe()
            .disposed(by: disposeBag)

        updateButton.rx.tap
            .map { [unowned self] in
                self.updateButton.animationSelect()
                handleUpdateButton?(product)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func configCell(data: Product, isAdmin: Bool = false) {
        self.isAdmin = isAdmin
        addItem.isHidden = isAdmin
        updateButton.isHidden = !isAdmin
        removeButton.isHidden = !isAdmin
        self.product = data
        productImageView.sd_setImage(with: URL(string: data.imageURL),
                          placeholderImage: UIImage(named: "imagePlaceholder"))
        productTitle.text = data.name
        productCategory.text = data.category.name

        numberOfItemTextField.do {
            $0.isHidden = product.quantity >= 1 ? false : true
            $0.text = String(product.quantity)
        }

        subtractItem.isHidden = product.quantity >= 1 ? false : true

        // Price's logic
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        if let string = formatter.string(from: data.price as NSNumber) {
            let priceString = String(string.dropFirst()) + "đ"
            productPrice.text = priceString
        } else {
            productPrice.text = "Không có giá trị"
        }
    }
}
