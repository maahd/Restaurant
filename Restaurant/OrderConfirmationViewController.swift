//
//  OrderConfirmationViewController.swift
//  Restaurant
//
//  Created by Maahd Shahzad on 9/7/19.
//  Copyright © 2019 Maahd Shahzad. All rights reserved.
//

import UIKit

class OrderConfirmationViewController: UIViewController {
    @IBOutlet var timeRemainingLabel: UILabel!
    var minutes: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeRemainingLabel.text = "Thank you for your order! Your wait time is approximately \(minutes!) minutes."
    }
}
