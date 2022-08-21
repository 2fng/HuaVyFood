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

    private let disposeBag = DisposeBag()
    private var product = Product()

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
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .black, shadowRadius: 5, shadowOpacity: 0.1, cornerRadius: 5)
        }

        productImageView.do {
            $0.layer.cornerRadius = 5
        }

        addItem.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, shadowRadius: 5, shadowOpacity: 0.05, cornerRadius: 5)
        }

        subtractItem.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .gray, shadowRadius: 5, shadowOpacity: 0.05, cornerRadius: 5)
            $0.isHidden = product.quantity >= 1 ? false : true
        }

        numberOfItemTextField.do {
            $0.isHidden = product.quantity >= 1 ? false : true
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
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func configCell(data: Product, isAdmin: Bool = false) {
        addItem.isHidden = isAdmin
        subtractItem.isHidden = isAdmin ? true : product.quantity >= 1 ? false : true
        numberOfItemTextField.isHidden = isAdmin ? true : product.quantity >= 1 ? false : true
        self.product = data
        productImageView.sd_setImage(with: URL(string: data.imageURL),
                          placeholderImage: UIImage(named: "imagePlaceholder"))
        productTitle.text = data.name
        productCategory.text = data.category.name

        // Price's logic
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        if let string = formatter.string(from: data.price as NSNumber) {
            productPrice.text = string
        } else {
            productPrice.text = "Không có giá trị"
        }
    }
}
