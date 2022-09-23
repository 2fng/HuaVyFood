//
//  UserShippingInfo.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 22/09/2022.
//

import Foundation
import ObjectMapper

struct UserShippingInfo {
    var id = ""
    var uid = ""
    var profileName = ""
    var fullName = ""
    var mobileNumber = ""
    var address = ""
}

extension UserShippingInfo: Mappable {
    init?(map: Map) {
        self.init()
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        uid <- map["uid"]
        profileName <- map["profileName"]
        fullName <- map["fullName"]
        mobileNumber <- map["mobileNumber"]
        address <- map["address"]
    }
}
