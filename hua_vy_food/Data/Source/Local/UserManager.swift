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

    func clearUser() {
        setUserID("")
        setIsAdmin(false)
    }
}
