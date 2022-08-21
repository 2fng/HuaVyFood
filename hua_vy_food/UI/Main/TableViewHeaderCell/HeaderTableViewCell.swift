//
//  HeaderTableViewCell.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 21/08/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class HeaderTableViewCell: UITableViewCell, ReuseableCell {
    @IBOutlet private weak var burgerMenuButton: UIButton!
    @IBOutlet private weak var cartButton: UIButton!
    @IBOutlet private weak var searchTextField: CustomTextField!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!

    private var disposeBag = DisposeBag()

    // Variables
    private var categories = [ProductCategory]()
    private var categorySelectedIndex = 0

    // Callbacks
    var handleBurgerMenuTapped: (() -> Void)?
    var handleCartTapped: (() -> Void)?
    var handleCategoryTapped: ((String, Int) -> Void)?
    var handleSearch: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    private func setupView() {
        categoryCollectionView.do {
            $0.semanticContentAttribute = .forceRightToLeft
            $0.delegate = self
            $0.dataSource = self
            $0.register(CategoryCollectionViewCell.nib, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        }

        burgerMenuButton.do {
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .white
            $0.shadowView(color: .lightGray, cornerRadius: 15)
        }

        cartButton.do {
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .white
            $0.shadowView(color: .lightGray, cornerRadius: 15)
        }

        searchTextField.do {
            $0.delegate = self
        }

        burgerMenuButton.rx.tap
            .map { [unowned self] in
                burgerMenuButton.animationSelect()
                handleBurgerMenuTapped?()
            }
            .subscribe()
            .disposed(by: disposeBag)

        cartButton.rx.tap
            .map { [unowned self] in
                cartButton.animationSelect()
                handleCartTapped?()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func configCell(category: [ProductCategory], categorySelectedIndex: Int) {
        self.categories = category
        self.categorySelectedIndex = categorySelectedIndex
        categoryCollectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension HeaderTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldText = textField.text else { return }
        handleSearch?(textFieldText.uppercased())
    }
}

// MARK: CollectionView
extension HeaderTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        cell.configCell(data: categories[indexPath.item], isSelected: indexPath.item == categorySelectedIndex)
        return cell
    }
}

extension HeaderTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categorySelectedIndex = indexPath.item
        handleCategoryTapped?(categories[indexPath.item].id, categorySelectedIndex)
        categoryCollectionView.reloadData()
    }
}

extension HeaderTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = categoryCollectionView.bounds.width / 6
        let height = categoryCollectionView.bounds.height
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
}
