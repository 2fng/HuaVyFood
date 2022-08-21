//
//  ManagerProductViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 09/08/2022.
//

import UIKit
import Then
import RxSwift
import RxCocoa

final class ManagerProductViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var floatingButton: UIButton!

    private let disposeBag = DisposeBag()
    private let viewModel = ManagerProductViewModel(productRepository: ProductRepository())

    // Triggers
    private let reloadTrigger = PublishSubject<Void>()

    // Variables
    private var products = [Product]()
    private var categories = [ProductCategory]()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
        bindViewModel()
    }

    private func setUpView() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)

        let nav = navigationController
        nav?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav?.navigationBar.shadowImage = UIImage()
        nav?.navigationBar.isTranslucent = true

        tableView.do {
            $0.addSubview(refreshControl)
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = UITableView.automaticDimension
            $0.register(ProductTableViewCell.nib, forCellReuseIdentifier: ProductTableViewCell.identifier)
        }

        floatingButton.do {
            $0.layer.cornerRadius = 25
            $0.shadowView(color: .logoPink, cornerRadius: 25)
        }

        floatingButton.rx.tap
            .map { [unowned self] in
                floatingButton.animationSelect()
                navigationController?.pushViewController(AddNewViewController(), animated: true)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = ManagerProductViewModel.Input(getCategoriesTrigger: reloadTrigger.asDriverOnErrorJustComplete(),
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

    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        reloadTrigger.onNext(())
        refreshControl.endRefreshing()
    }
}

// MARK: Binder
extension ManagerProductViewController {
    private var returnProductCategories: Binder<[ProductCategory]> {
        return Binder(self) { vc, categories in
            vc.categories = categories
            vc.tableView.reloadData()
        }
    }

    private var returnProducts: Binder<[Product]> {
        return Binder(self) { vc, products in
            vc.products = products
            vc.tableView.reloadData()
        }
    }
}

extension ManagerProductViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier) as? ProductTableViewCell
        else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configCell(data: products[indexPath.row], isAdmin: true)
        return cell
    }
}

extension ManagerProductViewController: UITableViewDelegate {

}
