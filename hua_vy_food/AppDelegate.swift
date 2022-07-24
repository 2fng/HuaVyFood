//
//  AppDelegate.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 24/07/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()

        return true
    }
}

