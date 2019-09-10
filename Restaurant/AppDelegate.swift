//
//  AppDelegate.swift
//  Restaurant
//
//  Created by Maahd Shahzad on 9/6/19.
//  Copyright © 2019 Maahd Shahzad. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var orderTabBarItem: UITabBarItem!
    var window: UIWindow?
    
    @objc func updateOrderBadge() {
        switch MenuController.shared.order.menuItems.count {
        case 0:
            orderTabBarItem.badgeValue = nil
        case let count:
            orderTabBarItem.badgeValue = String(count)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let temporaryDirectory = NSTemporaryDirectory()
        let urlCache = URLCache(memoryCapacity: 25_000_000, diskCapacity: 50_000_000, diskPath: temporaryDirectory)
        URLCache.shared = urlCache
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrderBadge), name: MenuController.orderUpdatedNotification, object: nil)
        
        orderTabBarItem = (self.window!.rootViewController! as! UITabBarController).viewControllers![1].tabBarItem!
        
        updateOrderBadge()
        
        return true
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MenuController.shared.loadOrder()
        MenuController.shared.loadItems()
        
        MenuController.shared.loadRemoteData()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        MenuController.shared.saveOrder()
        MenuController.shared.saveItems()
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
}

