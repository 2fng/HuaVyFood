//
//  CartViewController.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 10/09/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Then

final class CartViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var checkoutButton: UIButton!

    private var disposeBag = DisposeBag()
    private let viewModel = CartViewModel(cartRepository: CartRepository(),
                                          userRepository: UserRepository())
    // Variables
    private var cart = Cart()
    private var userShippingInfo = UserShippingInfo()
    private var paymentMethods = [PaymentMethod]()
    private var currentPaymentMethod = PaymentMethod(id: "HVFPM01", name: "Thanh toán khi nhận hàng")
    private var coupons = [Coupon]()
    private var discountValue = 0


    // Triggers
    private let updateCartTrigger = PublishSubject<Cart>()
    private let getUserShippingInfoTrigger = PublishSubject<Void>()
    private let getPaymentMethodsTrigger = PublishSubject<Void>()
    private let getCouponsTrigger = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configView()
    }

    override func viewWillAppear(_ animated: Bool) {
        getUserShippingInfoTrigger.onNext(())
        getPaymentMethodsTrigger.onNext(())
        getCouponsTrigger.onNext(())
    }

    func configCart(cart: Cart) {
        self.cart = cart
    }

    private func configView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = UITableView.automaticDimension
            $0.register(ProductTableViewCell.nib, forCellReuseIdentifier: ProductTableViewCell.identifier)
            $0.register(CartBottomTableViewCell.nib, forCellReuseIdentifier: CartBottomTableViewCell.identifier)
        }

        checkoutButton.do {
            $0.layer.cornerRadius = 5
            $0.shadowView(cornerRadius: 5)
        }

        checkoutButton.rx.tap
            .map { [unowned self] in
                checkoutButton.animationSelect()
                if currentPaymentMethod.id != "HVFPM01" {
                    let checkoutMessage = "Vui lòng thanh toán hoá đơn thông qua phương thức \n\(currentPaymentMethod.name)\n \(currentPaymentMethod.paymentDetail) \nNội dung chuyển khoản:\n <Họ và tên> <Ngày mua>"
                    showAlert(message: checkoutMessage, okButtonOnly: true, okCompletion: {
                        print(currentPaymentMethod)
                        print(discountValue)
                        print(userShippingInfo)
                        print(cart)
                    })
                } else {
                    print(currentPaymentMethod)
                    print(discountValue)
                    print(userShippingInfo)
                    print(cart)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        let input = CartViewModel.Input(updateCartTrigger: updateCartTrigger.asDriverOnErrorJustComplete(),
                                        userShippingInfoTrigger: getUserShippingInfoTrigger.asDriverOnErrorJustComplete(),
                                        getPaymentMethodTrigger: getPaymentMethodsTrigger.asDriverOnErrorJustComplete(),
                                        getCouponsTrigger: getCouponsTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input)

        output.updateCart
            .drive(updateCartMessage)
            .disposed(by: disposeBag)

        output.userShippingInfo
            .drive(userShippingInfoBinder)
            .disposed(by: disposeBag)

        output.paymentMethods
            .drive(getPaymentMethodsBinder)
            .disposed(by: disposeBag)

        output.coupons
            .drive(getCouponsBinder)
            .disposed(by: disposeBag)

        output.loading
            .drive(rx.isLoading)
            .disposed(by: disposeBag)

        output.error
            .drive(rx.error)
            .disposed(by: disposeBag)

        getUserShippingInfoTrigger.onNext(())
        getPaymentMethodsTrigger.onNext(())
        getCouponsTrigger.onNext(())
    }
}

// MARK: Binder
extension CartViewController {
    private var updateCartMessage: Binder<String> {
        return Binder(self) { vc, message in
            
        }
    }

    private var userShippingInfoBinder: Binder<UserShippingInfo> {
        return Binder(self) { vc, returnUserShippingInfo in
            vc.userShippingInfo = returnUserShippingInfo
            vc.tableView.reloadData()
        }
    }

    private var getPaymentMethodsBinder: Binder<[PaymentMethod]> {
        return Binder(self) { vc, paymentMethods in
            vc.paymentMethods = paymentMethods
            vc.tableView.reloadData()
        }
    }

    private var getCouponsBinder: Binder<[Coupon]> {
        return Binder(self) { vc, coupons in
            vc.coupons = coupons
            vc.tableView.reloadData()
        }
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < cart.items.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
            cell.configCell(data: cart.items[indexPath.row])
            cell.handleAdjustItemQuantity = { [unowned self] product in
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
                tableView.reloadData()
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CartBottomTableViewCell.identifier) as? CartBottomTableViewCell else { return UITableViewCell() }
            cell.configCell(cart: cart, userShippingInfo: userShippingInfo, paymentMethod: currentPaymentMethod, discountValue: discountValue)
            cell.handleNavigateToCreateShippingInfo = {
                self.navigationController?.pushViewController(AddNewShippingInfoViewController(), animated: true)
            }
            cell.handleChoosingPaymentMethod = { [unowned self] in
                let vc = PopupListViewController()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                present(vc, animated: true)

                vc.getData(tableViewData: paymentMethods, selectedData: currentPaymentMethod)
                vc.handleDoneButton = { [unowned self] data in
                    if let data = data as? PaymentMethod {
                        self.currentPaymentMethod = data
                        tableView.reloadData()
                    }
                }
            }
            cell.handleSubmitCoupon = { [unowned self] couponName in
                if let couponContain = coupons.first(where: { coupon in
                    coupon.name == couponName
                }) {
                    discountValue = couponContain.value
                    tableView.reloadData()
                } else {
                    showAlert(message: "Mã giảm giá không đúng", okButtonOnly: true)
                }
            }
            return cell
        }
    }
}

extension CartViewController: UITableViewDelegate {

}
