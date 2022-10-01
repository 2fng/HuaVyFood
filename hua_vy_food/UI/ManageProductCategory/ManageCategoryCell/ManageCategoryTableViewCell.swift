//
//  ManageCategoryTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/09/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class ManageCategoryTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var nameTextField: CustomTextField!
    @IBOutlet private weak var updateButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!

    private let disposeBag = DisposeBag()
    private var category = ProductCategory()

    // Callback
    var handleUpdateCategory: ((ProductCategory) -> Void)?
    var handleDeleteCategory: ((ProductCategory) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    func configCell(category: ProductCategory) {
        self.category = category
        nameTextField.text = category.name
    }

    private func setupView() {
        updateButton.rx.tap
            .map { [unowned self] in
                updateButton.animationSelect()
                self.category.name = self.nameTextField.text ?? ""
                handleUpdateCategory?(self.category)
            }
            .subscribe()
            .disposed(by: disposeBag)

        deleteButton.rx.tap
            .map { [unowned self] in
                deleteButton.animationSelect()
                self.category.name = self.nameTextField.text ?? ""
                handleDeleteCategory?(self.category)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
