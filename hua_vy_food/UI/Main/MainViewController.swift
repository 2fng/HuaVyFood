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
    @IBOutlet private weak var productTableView: UITableView!

    private var disposeBag = DisposeBag()
    private let viewModel = MainViewModel(productRepository: ProductRepository())

    // Triggers
    private let reloadTrigger = PublishSubject<Void>()

    // Variables
    private let refreshControl = UIRefreshControl()
    private var searchContent = [Product]()
    private var products = [Product]()
    private var categories = [ProductCategory]()
    private var categorySelectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        bindViewModel()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func bindViewModel() {
        let input = MainViewModel.Input(getCategoriesTrigger: reloadTrigger.asDriverOnErrorJustComplete(),
                                        getProductsTrigger: reloadTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.categories
            .drive(returnProductCategories)
            .disposed(by: disposeBag)

        output.products
            .drive(returnProducts)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)

        reloadTrigger.onNext(())
    }

    private func setupView() {
        self.navigationItem.backButtonTitle = "Quay lại"
        hideKeyboardWhenTappedAround()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)

        productTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        productTableView.do {
            $0.addSubview(refreshControl)
            $0.rowHeight = UITableView.automaticDimension
            $0.delegate = self
            $0.dataSource = self
            $0.separatorStyle = .none
            $0.register(HeaderTableViewCell.nib, forCellReuseIdentifier: HeaderTableViewCell.identifier)
            $0.register(ProductTableViewCell.nib, forCellReuseIdentifier: ProductTableViewCell.identifier)
        }
    }

    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        reloadTrigger.onNext(())
        refreshControl.endRefreshing()
    }
}

// MARK: Binder
extension MainViewController {
    private var returnProductCategories: Binder<[ProductCategory]> {
        return Binder(self) { vc, categories in
            vc.categories = categories
            vc.categories.append(ProductCategory(id: "", name: "Tất cả"))
            vc.categorySelectedIndex = vc.categories.count - 1
            vc.productTableView.reloadData()
        }
    }

    private var returnProducts: Binder<[Product]> {
        return Binder(self) { vc, products in
            vc.products = products
            vc.searchContent = products
            vc.productTableView.reloadData()
        }
    }
}

// MARK: TableView
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchContent.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.identifier) as? HeaderTableViewCell
            else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.configCell(category: categories, categorySelectedIndex: categorySelectedIndex)
            cell.handleBurgerMenuTapped = {
                let vc = UserSettingViewController(nibName: "UserSettingViewController", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.handleCategoryTapped = { [unowned self] categoryID, selectedCategoryIndex in
                self.categorySelectedIndex = selectedCategoryIndex
                if categoryID.isEmpty {
                    self.searchContent = self.products
                } else {
                    self.searchContent = self.products.filter { product in
                        product.category.id == categoryID
                    }
                }
                self.productTableView.reloadData()
                cell.configCell(category: self.categories,
                                categorySelectedIndex: self.categorySelectedIndex)
            }
            cell.handleSearch = { [unowned self] searchText in
                if searchText.isEmpty {
                    self.searchContent = self.products
                } else {
                    self.searchContent = self.products.filter { product in
                        product.name.uppercased().contains(searchText) ||
                        product.category.name.uppercased().contains(searchText)
                    }
                }
                self.productTableView.reloadData()
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier) as? ProductTableViewCell
            else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.configCell(data: searchContent[indexPath.row - 1])
            return cell
        }
    }
}

extension MainViewController: UITableViewDelegate {
    
}
