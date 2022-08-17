//
//  ProductCategory.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 17/08/2022.
//

import Foundation
import ObjectMapper

struct ProductCategory {
    var id = ""
    var name = ""
}

extension ProductCategory: Mappable {
    init?(map: Map) {
        self.init()
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
