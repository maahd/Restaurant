//
//  MenuConroller.swift
//  Restaurant
//
//  Created by Maahd Shahzad on 9/6/19.
//  Copyright © 2019 Maahd Shahzad. All rights reserved.
//

import Foundation
import UIKit

class MenuController {
    private var itemsById = [Int:MenuItem]()
    private var itemsByCategory = [String:[MenuItem]]()
    static let shared = MenuController()
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }
    let baseURL = URL(string: "http://localhost:8090/")!

    func submitOrder(forMenuIDs menuIds: [Int], completion: @escaping (Int?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("order")
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data: [String: [Int]] = ["menuIds": menuIds]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, erro) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let preparationTime = try? jsonDecoder.decode(PreparationTime.self, from: data) {
                completion(preparationTime.prepTime)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func loadOrder() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let orderFileURL = documentsDirectoryURL.appendingPathComponent("order").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: orderFileURL) else { return }
        order = (try? JSONDecoder().decode(Order.self, from: data)) ?? Order(menuItems: [])
    }
    
    func saveOrder() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let orderFileURL = documentsDirectoryURL.appendingPathComponent("oder").appendingPathExtension("json")
        
        if let data = try? JSONEncoder().encode(order) {
            try? data.write(to: orderFileURL)
        }
    }
    
    func item(withID itemID: Int) -> MenuItem? {
        return itemsById[itemID]
    }
    
    func items(forCategory category: String) -> [MenuItem]? {
        return itemsByCategory[category]
    }
    
    var categories: [String] {
        get {
            return itemsByCategory.keys.sorted()
        }
    }
    
    static let menuDataUpdatedNotification = Notification.Name("MenuController.menuDataUpdated")
    
    private func process(_ items: [MenuItem]) {
        itemsById.removeAll()
        itemsByCategory.removeAll()
        
        for item in items {
            itemsById[item.id] = item
            itemsByCategory[item.category, default: []].append(item)
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: MenuController.menuDataUpdatedNotification, object: nil)
        }
    }
    
    func loadRemoteData() {
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        let components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        let menuURL = components.url!
        
        let task = URLSession.shared.dataTask(with: menuURL) { (data, _, _) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) {
                self.process(menuItems.items)
            }
        }
        task.resume()
    }
    
    func loadItems() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let menuItemsFileURL = documentsDirectoryURL.appendingPathComponent("menuItems").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: menuItemsFileURL) else { return }
        let items = (try? JSONDecoder().decode([MenuItem].self, from: data)) ?? []
        process(items)
    }
    
    func saveItems() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let menuItemsFileURL = documentsDirectoryURL.appendingPathComponent("menuItems").appendingPathExtension("json")
        
        let items = Array(itemsById.values)
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: menuItemsFileURL)
        }
    }
}
