//
//  Coupon.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/09/2022.
//

import Foundation
import ObjectMapper

struct Coupon {
    var id = ""
    var name = ""
    var value = 0
}

extension Coupon: Mappable {
    init?(map: Map) {
        self.init()
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        value <- map["value"]
    }
}
