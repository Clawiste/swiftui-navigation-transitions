//
//  PassthroughWindow.swift
//  UICommon
//
//  Created by Jan Prokes on 26.08.2022.
//

import Foundation
import UIKit

final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) {
            let hitViewClassName = String(describing: type(of: hitView))
            
            if hitView is Self {
                return nil
            } else if hitViewClassName == "UITransitionView" || hitViewClassName == "UIDimmingView" {
                return nil
            } else {
                return hitView
            }
        } else {
            return nil
        }
    }
}
