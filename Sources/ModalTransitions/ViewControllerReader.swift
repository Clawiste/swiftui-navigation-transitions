//
//  File.swift
//  
//
//  Created by Jan Prokes on 25.06.2023.
//

import Foundation
import UIKit
import struct SwiftUI.Binding

fileprivate extension UIView {
    var viewController: UIViewController? {
        var responder: UIResponder? = next
        
        while responder != nil, !(responder is UIViewController) {
            responder = responder?.next
        }
        
        return responder as? UIViewController
    }
}

final class ViewControllerReader: UIView {
    var presentingViewController: UIViewController?

    init() {        
        super.init(frame: .zero)
        
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self = self else {
                return
            }
            
            self.presentingViewController = self.viewController
        }
        CATransaction.commit()
    }
}
