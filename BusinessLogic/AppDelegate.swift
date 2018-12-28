/**
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let assembly = Assembly()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let viewController = window?.rootViewController as? ViewController {
            viewController.configure(product: Product(id: 1, name: "Cat", price: .single(.regular(1.50)), skus: []))
        }
        return true
    }
}

