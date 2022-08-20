//
//  CategoryCollectionViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 20/08/2022.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell, ReuseableCell {
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var selectedDot: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    private func setupView() {
        selectedDot.isHidden = true
    }

    func configCell(data: ProductCategory, isSelected: Bool) {
        selectedDot.isHidden = !isSelected
        selectedDot.layer.cornerRadius = 2.5
        title.text = data.name
        title.textColor = isSelected ? UIColor.logoPink : UIColor.systemGray4
    }
}
