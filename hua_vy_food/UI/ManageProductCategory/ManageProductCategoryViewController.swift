//
//  ManageProductCategoryViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/09/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class ManageProductCategoryViewController: UIViewController {
    @IBOutlet private weak var categoryTableView: UITableView!
    @IBOutlet private weak var addNewButton: UIButton!
    @IBOutlet private weak var addNewContainer: UIView!
    @IBOutlet private weak var addNewTextField: CustomTextField!
    @IBOutlet private weak var saveButton: UIButton!

    private let disposeBag = DisposeBag()
    private let viewModel = ManageProductCategoryViewModel(productRepository: ProductRepository())
    private var categories = [ProductCategory]()
    private var isCreatingCategory = false

    private let getCategoryTrigger = PublishSubject<Void>()
    private let addNewCategoryTrigger = PublishSubject<String>()
    private let updateTrigger = PublishSubject<ProductCategory>()
    private let deleteTrigger = PublishSubject<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func bindViewModel() {
        let input = ManageProductCategoryViewModel.Input(
            getProductCategoryTrigger: getCategoryTrigger.asDriverOnErrorJustComplete(),
            addNewCategoryTrigger: addNewCategoryTrigger.asDriverOnErrorJustComplete(),
            updateCategoryTrigger: updateTrigger.asDriverOnErrorJustComplete(),
            deleteCategoryTrigger: deleteTrigger.asDriverOnErrorJustComplete()
        )

        let output = viewModel.transform(input)

        output.productCategories
            .drive(categoriesBinder)
            .disposed(by: disposeBag)

        output.addNewProductCategory
            .drive(addNewCategoryBinder)
            .disposed(by: disposeBag)

        output.updateCategory
            .drive(updateCategoryBinder)
            .disposed(by: disposeBag)

        output.deleteCategory
            .drive(deleteCategoryBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)

        getCategoryTrigger.onNext(())
    }

    private func setupView() {
        hideKeyboardWhenTappedAround()
        categoryTableView.do {
            $0.dataSource = self
            $0.delegate = self
            $0.rowHeight = UITableView.automaticDimension
            $0.register(ManageCategoryTableViewCell.nib, forCellReuseIdentifier: ManageCategoryTableViewCell.identifier)
        }

        addNewButton.do {
            $0.layer.cornerRadius = 25
            $0.shadowView(color: .logoPink, cornerRadius: 25)
        }

        saveButton.do {
            $0.layer.cornerRadius = 5
        }

        addNewContainer.do {
            $0.shadowView(shadowOpacity: 0.3, cornerRadius: 5)
            $0.isHidden = !isCreatingCategory
        }

        saveButton.rx.tap
            .map { [unowned self] in
                saveButton.animationSelect()
                if let categoryName = addNewTextField.text {
                    addNewCategoryTrigger.onNext(categoryName)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        addNewButton.rx.tap
            .map { [unowned self] in
                addNewButton.animationSelect()
                isCreatingCategory = !isCreatingCategory
                UIView.animate(withDuration: 1,
                               delay: 0.0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 0.2,
                               options: .curveEaseInOut, animations: {
                    self.addNewContainer.isHidden = !self.isCreatingCategory
                })
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension ManageProductCategoryViewController {
    private var categoriesBinder: Binder<[ProductCategory]> {
        return Binder(self) { vc, categories in
            vc.categories = categories
            vc.categoryTableView.reloadData()
        }
    }

    private var addNewCategoryBinder: Binder<String> {
        return Binder(self) { vc, _ in
            vc.getCategoryTrigger.onNext(())
        }
    }

    private var updateCategoryBinder: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.getCategoryTrigger.onNext(())
        }
    }

    private var deleteCategoryBinder: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.getCategoryTrigger.onNext(())
        }
    }
}

extension ManageProductCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ManageCategoryTableViewCell.identifier) as? ManageCategoryTableViewCell else {
            return UITableViewCell()
        }
        cell.configCell(category: categories[indexPath.row])
        cell.handleUpdateCategory = { [unowned self] category in
            self.updateTrigger.onNext(category)
        }
        cell.handleDeleteCategory = { [unowned self] category in
            self.deleteTrigger.onNext(category.documentID)
        }
        return cell
    }
}

extension ManageProductCategoryViewController: UITableViewDelegate {

}
