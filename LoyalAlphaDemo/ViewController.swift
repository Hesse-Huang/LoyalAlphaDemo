//
//  ViewController.swift
//  LoyalAlphaDemo
//
//  Created by Hesse Huang on 2018/2/5.
//  Copyright © 2018年 Hesse. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        extendedLayoutIncludesOpaqueBars = true
        navigationController?.navigationBar.barTintColor = .red
        
        let btn = UIButton(type: .system)
        btn.setTitle("Push", for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(push), for: .touchUpInside)
        btn.center = view.center
        view.addSubview(btn)
        
    }
    
    @objc private func push() {
        let vc = DetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

class DetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        extendedLayoutIncludesOpaqueBars = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.animateBackground(show: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.animateBackground(show: true)
    }
    
}

extension NSObject {
    /// Exchange two selectors
    ///
    /// - Parameters:
    ///   - originalSelector: The original selector
    ///   - swizzledSelector: A new selector
    class func exchangeImplementations(originalSelector: Selector, swizzledSelector: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            else {
                print("Error: Unable to exchange method implemenation!!")
                return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UINavigationBar {
    // Actual type: _UIBarBackground
    var background: UIView {
        return subviews[0]
    }
}

extension UIView {
    
    private struct Key {
        static var loyalAlpha = "loyalAlpha"
    }
    
    /// A highly loyal ALPHA who won't be changed by system calls.
    var loyalAlpha: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &Key.loyalAlpha) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &Key.loyalAlpha, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            if let value = newValue {
                alpha = value
            }
        }
    }
}

extension UIView {
    class func applySwizzledMethods() {
        exchangeSetAlpha
    }
    
    private static let exchangeSetAlpha: Void = {
        let os = #selector(setter: alpha)
        let ss = #selector(swizzledSetAlpha(_:))
        exchangeImplementations(originalSelector: os, swizzledSelector: ss)
        print("SWIZZLE WARNING: 'exchangeSetAlpha' has been activated!")
    }()
    
    @objc private func swizzledSetAlpha(_ alpha: CGFloat) {
        if type(of: self) == NSClassFromString("_UIBarBackground") {
            if let loyalAlpha = loyalAlpha, loyalAlpha != alpha {
                return
            }
        }
        swizzledSetAlpha(alpha)
    }
}

extension UINavigationBar {
    func animateBackground(show: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.background.loyalAlpha = show ? 1 : 0
        }
        if show {
            self.background.loyalAlpha = nil
        }
    }
}
