//
//  MainViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 25/07/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class MainViewController: UIViewController {
    @IBOutlet private weak var burgerMenuButton: UIButton!
    @IBOutlet private weak var shoppingCartButton: UIButton!
    @IBOutlet private weak var productCollectionView: UICollectionView!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var searchtextField: CustomTextField!

    private let disposeBag = DisposeBag()

    // Variables
    private var searchContent = [Product]()
    private var products = [Product]()
    private var categories = [ProductCategory]()
    private var categorySelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        categories = [ProductCategory(id: "", name: "Đồ mặn"),
                      ProductCategory(id: "", name: "Đồ ngọt"),
                      ProductCategory(id: "", name: "Tất cả")]
        categorySelectedIndex = categories.count - 1
        setupView()
    }

    private var isAdminMode = false {
        didSet {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
                self.productCollectionView.backgroundColor = isAdminMode ? .logoPink : .white
            }, completion: { _ in
                self.productCollectionView.reloadData()
            })
        }
    }

    private func setupView() {
        self.navigationItem.backButtonTitle = "Quay lại"
        hideKeyboardWhenTappedAround()

        productCollectionView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(ProductCollectionViewCell.nib, forCellWithReuseIdentifier: ProductCollectionViewCell.identifier)
        }

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

        shoppingCartButton.do {
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .white
            $0.shadowView(color: .lightGray, cornerRadius: 15)
        }

        burgerMenuButton.rx.tap
            .map { [unowned self] in
                burgerMenuButton.animationSelect()
                let vc = UserSettingViewController(nibName: "UserSettingViewController", bundle: nil)
                navigationController?.pushViewController(vc, animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)

        shoppingCartButton.rx.tap
            .map { [unowned self] in
                shoppingCartButton.animationSelect()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case productCollectionView:
            return 10
        case categoryCollectionView:
            return categories.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case productCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
            cell.configCell(data: Product(id: "", name: "Nem chua", price: 120000, category: ProductCategory(id: "", name: "Đồ mặn"), image: UIImage(named: "imagePlaceholder") ?? UIImage(), imageName: "", imageURL: ""))
            cell.layer.cornerRadius = 5
            cell.shadowView()
            return cell
        case categoryCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
            cell.configCell(data: categories[indexPath.item], isSelected: indexPath.item == categorySelectedIndex)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.categorySelectedIndex = indexPath.item
        categoryCollectionView.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case productCollectionView:
            let width = productCollectionView.bounds.width / 2.2
            let height = CGFloat(300)
            return CGSize(width: width, height: height)
        case categoryCollectionView:
            let width = categoryCollectionView.bounds.width / 6
            let height = categoryCollectionView.bounds.height
            return CGSize(width: width, height: height)
        default:
            return CGSize()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView {
        case productCollectionView:
            return UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 10)
        case categoryCollectionView:
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}
