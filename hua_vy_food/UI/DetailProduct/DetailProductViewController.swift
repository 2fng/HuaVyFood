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
import IQKeyboardManagerSwift

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
    private let viewModel = DetailProductViewModel(productRepository: ProductRepository(),
                                                   cartRepository: CartRepository())

    private let updateLikeAndDislikeStatusTrigger = PublishSubject<(Bool, String)>()
    private let getLikeAndDislikeTrigger = PublishSubject<String>()
    private let updateCartTrigger = PublishSubject<Cart>()
    private let submitCommentTrigger = PublishSubject<(String, String)>()
    private let getCommentTrigger = PublishSubject<String>()

    private var product = Product()
    private var cart = Cart()
    private var isLiked = false
    private var isDisLiked = false
    private var totalLike = 0
    private var comments = [Comment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 1000)
    }

    func configProduct(product: Product, cart: Cart) {
        self.product = product
        self.cart = cart
    }

    private func bindViewModel() {
        let input = DetailProductViewModel.Input(updateLikeAndDislikeStatusTrigger: updateLikeAndDislikeStatusTrigger.asDriverOnErrorJustComplete(),
                                                 getLikeAndDislikeTrigger: getLikeAndDislikeTrigger.asDriverOnErrorJustComplete(),
                                                 updateCartTrigger: updateCartTrigger.asDriverOnErrorJustComplete(),
                                                 commentTrigger: submitCommentTrigger.asDriverOnErrorJustComplete(),
                                                 getCommentTrigger: getCommentTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.likeAndDislikeStatus
            .drive()
            .disposed(by: disposeBag)

        output.likeAndDislike
            .drive(likeAndDislikeBinder)
            .disposed(by: disposeBag)

        output.updateCart
            .drive()
            .disposed(by: disposeBag)

        output.productComment
            .drive(submitCommentBinder)
            .disposed(by: disposeBag)

        output.comments
            .drive(commentBinder)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .map { [unowned self] in
                self.addButton.animationSelect()
                product.quantity += 1
                numberOfItemTextField.text = String(product.quantity)
                UIView.animate(withDuration: 1.0, delay: 0.0) { [unowned self] in
                    subtractButton.isHidden = product.quantity >= 1 ? false : true
                    numberOfItemTextField.isHidden = product.quantity >= 1 ? false : true
                }
                handleAdjustItemQuantity()
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
                handleAdjustItemQuantity()
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
                updateLikeAndDislikeStatusTrigger.onNext((true, product.id))
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
                updateLikeAndDislikeStatusTrigger.onNext((false, product.id))
            }
            .subscribe()
            .disposed(by: disposeBag)

        submitCommentButton.rx.tap
            .map { [unowned self] in
                submitCommentButton.animationSelect()
                if commentTextView.text.count > 10 {
                    submitCommentTrigger.onNext((product.id, commentTextView.text))
                } else {
                    showAlert(message: "Bình luận phải có ít nhất 11 ký tự", okButtonOnly: true)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        getLikeAndDislikeTrigger.onNext(product.id)
        getCommentTrigger.onNext(product.id)
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
            $0.delegate = self
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

    private func handleAdjustItemQuantity() {
        if product.quantity < 1 {
            cart.items.removeAll { cartProduct in
                cartProduct.id == product.id
            }
        } else {
            if let cartIndex = cart.items.firstIndex(where: { cartProduct in
                cartProduct.id == product.id
            }) {
                cart.items[cartIndex] = product
            } else {
                cart.items.append(product)
            }
        }
        cart.totalValue = 0
        for item in cart.items {
            cart.totalValue += (item.price * Double(item.quantity))
        }
        updateCartTrigger.onNext(cart)
    }
}

extension DetailProductViewController {
    private var likeAndDislikeBinder: Binder<(Int, Bool, Bool)> {
        return Binder(self) { vc, likeAndDislike in
            vc.totalLike = likeAndDislike.0
            vc.isLiked = likeAndDislike.1
            vc.isDisLiked = likeAndDislike.2
            vc.updateLikeAndDisLikeButtonUI()
        }
    }

    private var submitCommentBinder: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.commentTextView.text = nil
            vc.showAlert(message: "Bình luận thành công!", okButtonOnly: true, okCompletion: {
                vc.getCommentTrigger.onNext(vc.product.id)
            })
        }
    }

    private var commentBinder: Binder<[Comment]> {
        return Binder(self) { vc, comments in
            vc.comments = comments
            print("Hehe: \n\(comments)")
        }
    }
}

extension DetailProductViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Bình luận về sản phẩm tại đây..." {
            textView.text = nil
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Bình luận về sản phẩm tại đây..."
        }
    }
}
