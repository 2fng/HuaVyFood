//
//  DetailProductViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 02/12/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class DetailProductViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var categoryButton: UIButton!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var subtractButton: UIButton!
    @IBOutlet private weak var numberOfItemTextField: UITextField!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var submitCommentButton: UIButton!
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var disLikeButton: UIButton!

    private let disposeBag = DisposeBag()

    private var product = Product()
    private var isLiked = false
    private var isDisLiked = false
    private var totalLike = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 1000)
    }

    func configProduct(product: Product) {
        self.product = product
    }

    private func bindViewModel() {
        addButton.rx.tap
            .map { [unowned self] in
                self.addButton.animationSelect()
                product.quantity += 1
                numberOfItemTextField.text = String(product.quantity)
                UIView.animate(withDuration: 1.0, delay: 0.0) { [unowned self] in
                    subtractButton.isHidden = product.quantity >= 1 ? false : true
                    numberOfItemTextField.isHidden = product.quantity >= 1 ? false : true
                }
                // handleAdjustItemQuantity?(product)
            }
            .subscribe()
            .disposed(by: disposeBag)

        subtractButton.rx.tap
            .map { [unowned self] in
                self.subtractButton.animationSelect()
                product.quantity -= 1
                numberOfItemTextField.text = String(product.quantity)
                UIView.animate(withDuration: 1.0, delay: 0.0) { [unowned self] in
                    subtractButton.isHidden = product.quantity >= 1 ? false : true
                    numberOfItemTextField.isHidden = product.quantity >= 1 ? false : true
                }
                // handleAdjustItemQuantity?(product)
            }
            .subscribe()
            .disposed(by: disposeBag)

        likeButton.rx.tap
            .map { [unowned self] in
                isLiked = !isLiked
                if isLiked {
                    isDisLiked = false
                    totalLike += 1
                } else {
                    totalLike -= 1
                }
                updateLikeAndDisLikeButtonUI()
            }
            .subscribe()
            .disposed(by: disposeBag)

        disLikeButton.rx.tap
            .map { [unowned self] in
                totalLike -= isLiked ? 1 : 0
                isDisLiked = !isDisLiked
                if isDisLiked {
                    isLiked = false
                } else {

                }
                updateLikeAndDisLikeButtonUI()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func setupView() {
        view.backgroundColor = .white

        navigationController?.navigationBar.tintColor = .white
        updateLikeAndDisLikeButtonUI()

        addButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .logoPink, shadowRadius: 5, shadowOpacity: 0.3, cornerRadius: 5)
        }

        subtractButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(color: .gray, shadowRadius: 5, shadowOpacity: 0.1, cornerRadius: 5)
            $0.isHidden = product.quantity >= 1 ? false : true
        }

        productImageView.do {
            $0.sd_setImage(with: URL(string: product.imageURL),
                           placeholderImage: UIImage(named: "imagePlaceholder"))
        }

        titleLabel.do {
            $0.text = product.name
        }

        categoryButton.do {
            $0.setTitle(product.category.name, for: .normal)
            $0.layer.cornerRadius = 15
        }

        priceLabel.do {
            $0.text = String(product.price)
            // Price's logic
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            if let string = formatter.string(from: product.price as NSNumber) {
                let priceString = String(string.dropFirst()) + "đ"
                $0.text = priceString
            } else {
                $0.text = "Không có giá trị"
            }
        }

        numberOfItemTextField.do {
            $0.isHidden = product.quantity >= 1 ? false : true
            $0.text = String(product.quantity)
            $0.isEnabled = false
        }

        submitCommentButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        commentTextView.do {
            $0.layer.cornerRadius = 5
        }
    }

    private func updateLikeAndDisLikeButtonUI() {
        let likedImage = UIImage(systemName: "hand.thumbsup.fill")
        let disLikedImage = UIImage(systemName: "hand.thumbsdown.fill")
        let notDisLikeImage = UIImage(systemName: "hand.thumbsdown")
        let notLikeImage = UIImage(systemName: "hand.thumbsup")

        likeButton.setImage(isLiked ? likedImage : notLikeImage,
                            for: .normal)
        disLikeButton.setImage(isDisLiked ? disLikedImage : notDisLikeImage,
                            for: .normal)
        likeButton.tintColor = isLiked ? UIColor.logoPink : UIColor.black
        likeButton.setTitle("\(totalLike)", for: .normal)
    }
}
