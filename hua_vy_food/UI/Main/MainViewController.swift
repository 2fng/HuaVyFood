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
import CoreMIDI

final class MainViewController: UIViewController {
    @IBOutlet private weak var productTableView: UITableView!
    @IBOutlet private weak var bottomCartViewContainer: UIView!
    @IBOutlet private weak var cartQuantityLabel: UILabel!
    @IBOutlet private weak var cartTotalPriceLabel: UILabel!
    @IBOutlet private weak var checkoutButton: UIButton!

    private var disposeBag = DisposeBag()
    private let viewModel = MainViewModel(productRepository: ProductRepository(),
                                          cartRepository: CartRepository())

    // Triggers
    private let reloadTrigger = PublishSubject<Void>()
    private let updateCartTrigger = PublishSubject<Cart>()

    // Variables
    private let refreshControl = UIRefreshControl()
    private var searchContent = [Product]()
    private var products = [Product]()
    private var categories = [ProductCategory]()
    private var categorySelectedIndex = 0
    private var cart = Cart()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        bindViewModel()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadTrigger.onNext(())
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func bindViewModel() {
        let input = MainViewModel.Input(getCategoriesTrigger: reloadTrigger.asDriverOnErrorJustComplete(),
                                        getProductsTrigger: reloadTrigger.asDriverOnErrorJustComplete(),
                                        getCart: reloadTrigger.asDriverOnErrorJustComplete(),
                                        updateCartTrigger: updateCartTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.categories
            .drive(returnProductCategories)
            .disposed(by: disposeBag)

        output.products
            .drive(returnProducts)
            .disposed(by: disposeBag)

        output.cart
            .drive(returnCart)
            .disposed(by: disposeBag)

        output.updateCart
            .drive(updateCartMessage)
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
        self.navigationController?.navigationBar.tintColor = UIColor.logoPink
        bottomCartViewContainer.isHidden = true
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

        cartQuantityLabel.do {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
        }

        checkoutButton.rx.tap
            .map { [unowned self] in
                checkoutButton.animationSelect()
                let vc = CartViewController(nibName: "CartViewController", bundle: nil)
                vc.awakeFromNib()
                vc.configCart(cart: cart)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)
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
            vc.categories.insert(ProductCategory(id: "", name: "Tất cả"), at: 0)
            vc.categorySelectedIndex = 0
            vc.productTableView.reloadData()
        }
    }

    private var returnProducts: Binder<[Product]> {
        return Binder(self) { vc, products in
            vc.products = products
            vc.searchContent = vc.products
            for item in vc.cart.items {
                if let index = vc.searchContent.firstIndex(where: { product in
                    return item.id == product.id
                }) {
                    vc.searchContent[index].quantity = item.quantity
                    vc.products[index].quantity = item.quantity
                }
            }
            vc.cartTotalPriceLabel.text = vc.cart.totalValue > 0 ? String(vc.cart.totalValue) : ""
            var cartQuantity = 0
            for item in vc.cart.items {
                cartQuantity += item.quantity
            }
            vc.cartQuantityLabel.text = String(cartQuantity)
            vc.productTableView.reloadData()
        }
    }

    private var returnCart: Binder<Cart> {
        return Binder(self) { vc, cart in
            vc.cart = cart
            vc.cart.uid = UserManager.shared.getUserID()
            for item in vc.cart.items {
                if let index = vc.searchContent.firstIndex(where: { product in
                    return item.id == product.id
                }) {
                    vc.searchContent[index].quantity = item.quantity
                    vc.products[index].quantity = item.quantity
                }
            }
            vc.cartTotalPriceLabel.text = vc.cart.totalValue > 0 ? String(vc.cart.totalValue) : ""
            vc.cart.totalValue = 0
            var cartQuantity = 0
            for item in vc.cart.items {
                cartQuantity += item.quantity
                vc.cart.totalValue += (item.price * Double(item.quantity))
            }
            vc.cartQuantityLabel.text = String(cartQuantity)
            vc.productTableView.reloadData()
        }
    }

    private var updateCartMessage: Binder<String> {
        return Binder(self) { vc, message in
            
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
            cell.handleCartTapped = { [unowned self] in
                let vc = CartViewController(nibName: "CartViewController", bundle: nil)
                vc.awakeFromNib()
                vc.configCart(cart: cart)
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
            cell.handleAdjustItemQuantity = { [unowned self] product in
                if let index = searchContent.firstIndex(where: { cartProduct in
                    return cartProduct.id == product.id
                }) {
                    if product.quantity > 0 {
                        if let cartIndex = cart.items.firstIndex(where: { cartProduct in
                            cartProduct.id == product.id
                        }) {
                            cart.items[cartIndex] = product
                        } else {
                            cart.items.append(product)
                        }
                    } else {
                        if let cartIndex = cart.items.firstIndex(where: { cartProduct in
                            cartProduct.id == product.id
                        }) {
                            cart.items.remove(at: cartIndex)
                        }
                    }
                    cart.totalValue = 0
                    for item in cart.items {
                        cart.totalValue += (item.price * Double(item.quantity))
                    }
                    searchContent[index] = product
                    if let productsIndex = products.firstIndex(where: { productContent in
                        productContent.id == product.id
                    }) {
                        products[productsIndex] = product
                    }
                }

                cartTotalPriceLabel.text = cart.totalValue > 0 ? String(cart.totalValue) : ""
                var cartQuantity = 0
                for item in cart.items {
                    cartQuantity += item.quantity
                }
                cartQuantityLabel.text = String(cartQuantity)
                updateCartTrigger.onNext(cart)
                tableView.reloadData()
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let vc = DetailProductViewController(nibName: "DetailProductViewController", bundle: nil)
            vc.awakeFromNib()
            vc.configProduct(product: searchContent[indexPath.row - 1], cart: cart)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MainViewController: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.0) { [unowned self] in
            self.bottomCartViewContainer.isHidden = scrollView.contentOffset.y >= 50 ? false : true
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        UIView.animate(withDuration: 0.0) { [unowned self] in
            self.bottomCartViewContainer.isHidden = scrollView.contentOffset.y >= 50 ? false : true
        }
    }
}
