//
//  CustomTabBarController.swift
//  Custom-Tabbar
//
//  Created by Mauro Figueiredo on 07/07/21.
//  Copyright © 2021 Mauro Figueiredo. All rights reserved.
//

import UIKit

open class BorderTabBarController: UITabBarController {
    fileprivate var shouldSelectOnTabBar = true
    
    open override var selectedViewController: UIViewController? {
        willSet {
            guard shouldSelectOnTabBar,
                let newValue = newValue else {
                    shouldSelectOnTabBar = true
                    return
            }
            guard let tabBar = tabBar as? CustomTabBar, let index = viewControllers?.index(of: newValue) else {
                return
            }
            tabBar.select(itemAt: index, animated: false)
        }
        }
    open override var selectedIndex: Int {
        willSet{
            guard shouldSelectOnTabBar else {
                shouldSelectOnTabBar = true
                return
            }
            guard let tabBar = tabBar as? CustomTabBar else {
                return
            }
            tabBar.select(itemAt: selectedIndex, animated: false)
        }
    }

    open override func viewDidLoad(){
        super.viewDidLoad()
        let tabBar = CustomTabBar()
        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 40
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tabBar.backgroundImage = getColoredImage(color: .clear, size: CGSize(width: view.frame.width, height: 100))
        
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        
        self.setValue(tabBar, forKey: "tabBar")
    }
    


func getColoredImage(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    guard let image:UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage()}
    UIGraphicsEndImageContext()
    return image
}
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private var _barHeight: CGFloat = 100
    open var barHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return _barHeight + view.safeAreaInsets.bottom
            }else {
                return _barHeight
            }
     }
        set {
            _barHeight = newValue
            updateTabBarFrame()
        }
    }
    
    private func updateTabBarFrame(){
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = barHeight
        tabFrame.origin.y = self.view.frame.size.height - barHeight
        self.tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateTabBarFrame()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        updateTabBarFrame()
    }
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.index(of: item) else {
            return
        }
        if let controller = viewControllers?[idx] {
            shouldSelectOnTabBar = false
            selectedIndex = idx
            delegate?.tabBarController?(self, didSelect: controller)
        }
    }
}
