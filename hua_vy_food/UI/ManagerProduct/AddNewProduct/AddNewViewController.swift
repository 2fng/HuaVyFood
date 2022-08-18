//
//  AddNewViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 09/08/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import Photos

final class AddNewViewController: UIViewController {
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var categoryStackView: UIStackView!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var addNewCategoryButton: UIButton!
    @IBOutlet private weak var saveNewCategoryButton: UIButton!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var productImageLabelTopConstraints: NSLayoutConstraint!

    private let disposeBag = DisposeBag()
    private let viewModel = AddNewViewModel(productRepository: ProductRepository())
    private let submitTrigger = PublishSubject<Product>()

    // Variables
    private var product = Product()
    private var productCategories = [ProductCategory]()
    private var imageName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindViewModel()
        setupView()
    }

    private func bindViewModel() {
        let input = AddNewViewModel.Input(
            getProductCategories: Driver.just(()),
            addNewProductTextFieldTrigger: categoryTextField.rx.text.orEmpty.asDriver(),
            addNewCategoryTrigger: saveNewCategoryButton.rx.tap.asDriver(),
            submitTrigger: submitTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.productCategories
            .drive(returnProductCategories)
            .disposed(by: disposeBag)

        output.addNewCategory
            .drive(addnewCategoryMessage)
            .disposed(by: disposeBag)

        output.addNewProduct
            .drive()
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)
    }

    private func setupView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        hideKeyboardWhenTappedAround()
        nameTextField.delegate = self
        priceTextField.delegate = self
        categoryTextField.delegate = self
        let tappedOnCategoryTextField = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        categoryTextField.addGestureRecognizer(tappedOnCategoryTextField)

        saveNewCategoryButton.do {
            $0.isHidden = true
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, cornerRadius: 5)
        }

        productImageView.do {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(tapGestureRecognizer)
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        addNewCategoryButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, cornerRadius: 5)
        }

        saveButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, cornerRadius: 5)
        }

        addNewCategoryButton.rx.tap
            .map { [unowned self] in
                addNewCategoryButton.animationSelect()
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: { [unowned self] in
                    self.addNewCategoryButton.setImage(self.saveNewCategoryButton.isHidden ?
                                                       UIImage(systemName: "xmark") : UIImage(systemName: "plus"),
                                                       for: .normal)
                    self.saveNewCategoryButton.isHidden.toggle()
                    if saveNewCategoryButton.isHidden {
                        self.productImageLabelTopConstraints.constant = 85
                    }
                }) { _ in
                    self.productImageLabelTopConstraints.constant = 25
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .map { [unowned self] in
                saveButton.animationSelect()
            }
            .subscribe(onNext: { [unowned self] in
                // submitTrigger.onNext(self.product)
                print(self.product)
            })
            .disposed(by: disposeBag)
        
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let _ = tapGestureRecognizer.view as? UIImageView
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    @objc func categoryTapped() {
        let vc = PopupListViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)

        vc.getData(tableViewData: productCategories, selectedData: self.product.category)
        vc.handleDoneButton = { [unowned self] data in
            if let data = data as? ProductCategory {
                self.categoryTextField.text = data.name
                self.product.category = data
            }
        }
    }
}

extension AddNewViewController {
    private var returnProductCategories: Binder<[ProductCategory]> {
        return Binder(self) { vc, categories in
            vc.productCategories = categories
        }
    }
    private var addnewCategoryMessage: Binder<String> {
        return Binder(self) { vc, alertMessage in
            vc.showAlert(message: alertMessage, okButtonOnly: true)
        }
    }
}

extension AddNewViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            self.product.name = textField.text ?? ""
        case priceTextField:
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            let number = formatter.number(from: textField.text ?? "0.0")
            self.product.price = number as? Double ?? 0.0
        case categoryTextField:
            self.product.category.name = textField.text ?? ""
        default:
            return
        }
    }
}

extension AddNewViewController: UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage  {
            productImageView.image = image
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                guard let asset = result.firstObject else { return }
                imageName = asset.value(forKey: "filename") as? String ?? ""
                self.product.imageName = imageName
            }
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
