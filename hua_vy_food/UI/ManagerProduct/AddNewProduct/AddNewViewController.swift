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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        hideKeyboardWhenTappedAround()

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
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as? UIImageView
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
}

extension AddNewViewController: UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage  {
            productImageView.image = image
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
