//
//  CBTabBarButton.swift
//  Custom-Tabbar
//
//  Created by Mauro Figueiredo on 07/07/21.
//  Copyright © 2021 Mauro Figueiredo. All rights reserved.
//

import UIKit

public class CBTabBarItem: UITabBarItem{
    @IBInspectable public var tintColor: UIColor?
    @IBInspectable public var rightToLeft:Bool = false
}
public class CBTabBarButton: UIControl {
    
    var dotView = UIView()
    var rightToLeft:Bool = false
    private var _isSelected: Bool = false
    override public var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            guard newValue != _isSelected else {
                return
            }
            setSelected(newValue)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    init(item: UITabBarItem) {
        super.init(frame: .zero)
        tabImage = UIImageView(image: item.image)
        defer {
            self.item = item
            configureSubviews()
        }
    }
    
    private var currentImage: UIImage? {
        var maybeImage: UIImage?
        if _isSelected {
            maybeImage = item?.selectedImage ?? item?.image
         } else {
            maybeImage = item?.image
         }
        guard let image = maybeImage else {
            return nil
        }
        return image.renderingMode == .automatic ? image.withRenderingMode(.alwaysTemplate) : image
    }
    
    public var item: UITabBarItem? {
        didSet {
            tabImage.image = currentImage
            tabLabel.text = item?.title
            if let tabItem = item as? CBTabBarItem {
                if let color = tabItem.tintColor {
                    tintColor = color
                }
                rightToLeft = tabItem.rightToLeft
            }
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            if _isSelected {
                tabImage.tintColor = tintColor
            }
            dotView.backgroundColor = tintColor
            tabLabel.textColor = tintColor
            tabBg.backgroundColor = tintColor.withAlphaComponent(0.2)
        }
    }
    
    private var tabImage = UIImageView()
    private var tabLabel = UILabel()
    private var tabBg = UIView()
    
    private let bgHeight: CGFloat = 42.0
    private var csFoldedBgTrailing: NSLayoutConstraint!
    private var csUnFoldedBgTrailing: NSLayoutConstraint!
    private var csFoldedLBLLeading: NSLayoutConstraint!
    private var csUnFoldedLBLLeading: NSLayoutConstraint!
    
    private var foldedConstraints: [NSLayoutConstraint] {
        return [csFoldedLBLLeading, csFoldedBgTrailing]
    }
    private var unfoldedConstraints: [NSLayoutConstraint] {
        return [csUnFoldedBgTrailing, csUnFoldedLBLLeading]
    }
    
    private func configureSubviews(){
        tabImage.contentMode = .center
        tabImage.translatesAutoresizingMaskIntoConstraints = false
        tabLabel.translatesAutoresizingMaskIntoConstraints = false
        tabLabel.font = UIFont.systemFont(ofSize: 14)
        tabLabel.adjustsFontSizeToFitWidth = true
        tabBg.translatesAutoresizingMaskIntoConstraints = false
        tabBg.isUserInteractionEnabled = false
        tabImage.setContentHuggingPriority(.required, for: .horizontal)
        tabImage.setContentHuggingPriority(.required, for: .vertical)
        tabImage.setContentCompressionResistancePriority(.required, for: .horizontal)
        tabImage.setContentCompressionResistancePriority(.required, for: .vertical)
        
        let dotSize: CGFloat = 5.0
        dotView.frame = CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize))
        dotView.layer.cornerRadius = dotSize / 2.0
        dotView.layer.shouldRasterize = true
        dotView.layer.rasterizationScale = UIScreen.main.scale
        dotView.isHidden = true
        
        self.addSubview(tabBg)
        self.addSubview(tabLabel)
        self.addSubview(tabImage)
        self.addSubview(dotView)
        
        tabBg.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabBg.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        tabBg.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tabBg.heightAnchor.constraint(equalToConstant: bgHeight).isActive = true
        
        if rightToLeft {
            tabImage.trailingAnchor.constraint(equalTo: tabBg.trailingAnchor, constant: -bgHeight/2.0).isActive = true
            tabImage.centerYAnchor.constraint(equalTo: tabBg.centerYAnchor).isActive = true
            tabLabel.centerYAnchor.constraint(equalTo: tabBg.centerYAnchor).isActive = true
            csFoldedLBLLeading = tabLabel.leadingAnchor.constraint(equalTo: tabBg.trailingAnchor)
            csUnFoldedLBLLeading = tabLabel.leadingAnchor.constraint(equalTo: tabBg.leadingAnchor, constant: bgHeight/4.0)
            csFoldedBgTrailing = tabImage.trailingAnchor.constraint(equalTo: tabBg.leadingAnchor, constant: bgHeight/2.0)
            csUnFoldedBgTrailing = tabLabel.trailingAnchor.constraint(equalTo: tabImage.leadingAnchor, constant: -bgHeight/2.0)
        } else {
            tabImage.leadingAnchor.constraint(equalTo: tabBg.leadingAnchor, constant: bgHeight/2.0).isActive = true
            tabImage.centerYAnchor.constraint(equalTo: tabBg.centerYAnchor).isActive = true
            tabLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            csFoldedLBLLeading = tabLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
            csUnFoldedLBLLeading = tabLabel.leadingAnchor.constraint(equalTo: tabImage.trailingAnchor, constant: bgHeight/4.0)
            csFoldedBgTrailing = tabImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -bgHeight/2.0)
            csUnFoldedBgTrailing = tabLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -bgHeight/2.0)
            
        }
        fold()
        setNeedsLayout()
    }
    
    private func fold(animationDuration duration: Double = 0.0) {
        unfoldedConstraints.forEach{$0.isActive = false}
        foldedConstraints.forEach{ $0.isActive = true}
        UIView.animate(withDuration: duration){
            self.tabBg.backgroundColor = .clear
            self.tabBg.alpha = 0.0
        }
        UIView.animate(withDuration: duration * 0.4) {
            self.dotView.isHidden = true
            self.tabLabel.alpha = 0.0
        }
        UIView.transition(with: tabImage, duration: duration, options: [.transitionCrossDissolve], animations: {
            self.tabImage.tintColor = .black
        }, completion: nil)
 }
    private func unFold(animationDuration duration: Double = 0.0) {
        unfoldedConstraints.forEach{$0.isActive = true}
        foldedConstraints.forEach{ $0.isActive = false}
        
        UIView.animate(withDuration: duration){
            self.tabBg.backgroundColor = .clear
            self.tabBg.alpha = 1.0
        }
        UIView.animate(withDuration: duration * 0.5, delay: duration * 0.5, options: [], animations: {
            self.dotView.isHidden = false
            self.tabLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.transition(with: tabImage, duration: duration, options: [.transitionCrossDissolve], animations: {
            self.tabImage.tintColor = self.tintColor
        }, completion: nil)
 }
    
    public func setSelected(_ selected: Bool, animationDuration duration: Double = 0.0){
        _isSelected = selected
        UIView.transition(with: tabImage, duration: 0.05, options: [.beginFromCurrentState], animations: {
            self.tabImage.image = self.currentImage
        }, completion: nil)
        if selected {
            unFold(animationDuration: duration)
        }else {
            fold(animationDuration: duration)
        }
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        tabBg.layer.cornerRadius = tabBg.bounds.height / 2.0
        let dotX: CGFloat = tabImage.center.x - dotView.frame.width/2.0
        let dotY: CGFloat = tabImage.frame.maxY + 13.0
        dotView.frame = CGRect(origin: CGPoint(x: dotX, y: dotY), size: dotView.frame.size)
    }
}
