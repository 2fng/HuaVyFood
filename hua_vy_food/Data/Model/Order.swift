//
//  Order.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/09/2022.
//

import Foundation

struct Order {
    var documentID = ""
    var id = ""
    var uid = ""
    var totalValue = 0
    var totalValueBeforeCoupon = 0
    var couponUsed: Coupon?
    var cart = Cart()
    var paymentMethod = PaymentMethod()
    var userShippingInfo = UserShippingInfo()
    var orderDate = Date()
    var status = ""
    var paidDate: Date?
}
