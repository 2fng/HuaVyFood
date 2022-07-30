//
//  UserSignIn.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/07/2022.
//

import Foundation
import ObjectMapper

struct UserSignIn {
    var uid = ""
    var isAdmin = false
}

extension UserSignIn: Mappable {
    init?(map: Map) {
        self.init()
    }

    mutating func mapping(map: Map) {
        uid <- map["uid"]
        isAdmin <- map["isAdmin"]
    }
}
