//
//  PaymentMethod.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 26/09/2022.
//

import Foundation
import ObjectMapper

struct PaymentMethod {
    var id = ""
    var name = ""
}

extension PaymentMethod: Mappable {
    init?(map: Map) {
        self.init()
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
