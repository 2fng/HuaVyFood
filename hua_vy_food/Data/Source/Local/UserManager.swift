//
//  UserManager.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/07/2022.
//

import Foundation

enum UserKey: String {
    case userIdKey = "HVF_USER_ID_KEY"
    case userIsAdminKey = "HVF_USER_IS_MANAGER_KEY"
    case userFullName = "HVF_USER_FULL_NAME_KEY"
    case userPhoneNumber = "HVF_USER_PHONE_NUMBER_KEY"
    case userAddress = "HVF_USER_ADDRESS_KEY"
}

protocol UserManagerType {
    func setUserID(_ uid: String)
    func getUserID() -> String
    func setIsAdmin(_ isAdmin: Bool)
    func getUserIsAdmin() -> Bool
    func clearUser()
}

final class UserManager: UserManagerType {
    static let shared = UserManager()
    private init() {}

    private lazy var userDefault = UserDefaults.standard

    func setUserID(_ uid: String) {
        self.userDefault.set(uid, forKey: UserKey.userIdKey.rawValue)
    }

    func getUserID() -> String {
        return self.userDefault.string(forKey: UserKey.userIdKey.rawValue) ?? ""
    }

    func setIsAdmin(_ isAdmin: Bool) {
        self.userDefault.set(isAdmin, forKey: UserKey.userIsAdminKey.rawValue)
    }

    func getUserIsAdmin() -> Bool {
        return self.userDefault.bool(forKey: UserKey.userIsAdminKey.rawValue)
    }

    // Shipping info
    func setUserFullName(name: String) {
        return self.userDefault.set(name, forKey: UserKey.userFullName.rawValue)
    }

    func getUserFullName() -> String {
        return self.userDefault.string(forKey: UserKey.userFullName.rawValue) ?? "Không có dữ liệu tên"
    }

    func setUserPhoneNumber(phoneNumber: String) {
        return self.userDefault.set(phoneNumber, forKey: UserKey.userPhoneNumber.rawValue)
    }

    func getUserPhoneNumber() -> String {
        return self.userDefault.string(forKey: UserKey.userPhoneNumber.rawValue) ?? "Không có dữ liệu số điện thoại"
    }

    func setUserAddress(address: String) {
        return self.userDefault.set(address, forKey: UserKey.userAddress.rawValue)
    }

    func getUserAddress() -> String {
        return self.userDefault.string(forKey: UserKey.userAddress.rawValue) ?? "Không có dữ liệu địa chỉ"
    }

    func clearUser() {
        setUserID("")
        setIsAdmin(false)
    }
}
