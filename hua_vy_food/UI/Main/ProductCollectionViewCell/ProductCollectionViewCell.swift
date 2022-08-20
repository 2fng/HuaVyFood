//
//  ProductCollectionViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 20/08/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class ProductCollectionViewCell: UICollectionViewCell, ReuseableCell {
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var category: UILabel!
    @IBOutlet private weak var price: UILabel!
    @IBOutlet private weak var addToCart: UIButton!

    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    private func setupView() {
        contentView.do {
            $0.backgroundColor = .white
        }

        image.do {
            $0.layer.cornerRadius = 5
        }

        addToCart.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, shadowRadius: 5, cornerRadius: 5)
        }

        addToCart.rx.tap
            .map { [unowned self] in
                self.addToCart.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func configCell(data: Product) {
        image.image = data.image
        title.text = data.name
        category.text = data.category.name
        price.text = String(Int(data.price)) + " đ"
    }
}
