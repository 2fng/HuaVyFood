//
//  Product.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 18/08/2022.
//

import Foundation
import ObjectMapper

struct Product {
    var id = ""
    var name = ""
    var price = 0.0
    var category = ProductCategory()
    var image = UIImage()
    var imageName = ""
    var imageURL = ""
}

extension Product: Mappable {
    init?(map: Map) {
        self.init()
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        price <- map["price"]
        category <- map["category"]
        image <- map["image"]
        imageName <- map["imageName"]
        imageURL <- map["imageURL"]
    }
}
