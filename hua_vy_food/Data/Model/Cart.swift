//
//  Cart.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 06/09/2022.
//

import Foundation
import ObjectMapper

struct Cart {
    var uid = ""
    var id = ""
    var items = [Product]()
    var totalValue = 0.0
}

extension Cart: Mappable {
    init?(map: Map) {
        self.init()
    }

    mutating func mapping(map: Map) {
        uid <- map["uid"]
        id <- map["id"]
        items <- map["items"]
        totalValue <- map["totalValue"]
    }
}
