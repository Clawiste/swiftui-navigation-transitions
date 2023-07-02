//
//  PassthroughView.swift
//  UICommon
//
//  Created by Jan Prokeš on 30.03.2022.
//

import Foundation
import UIKit

final class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) {
            if hitView is Self {
                return nil
            } else {
                return hitView
            }
        } else {
            return nil
        }
    }
}
