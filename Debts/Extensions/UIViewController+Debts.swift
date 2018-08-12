//
//  UIViewController+Debts.swift
//  Debts
//
//  Created by dominik on 11/08/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func registerKeyboardObserver(bottomConstraint: NSLayoutConstraint) -> NSObjectProtocol {
       return NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
                
                bottomConstraint.constant = UIScreen.main.bounds.height - endFrameValue.cgRectValue.minY - tabBarHeight
                
                UIView.animate(withDuration: durationValue.doubleValue, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)), animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })
    }
}
