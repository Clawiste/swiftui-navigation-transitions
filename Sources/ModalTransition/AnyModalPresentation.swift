//
//  File.swift
//  
//
//  Created by Jan Prokes on 26.06.2023.
//

import Foundation
import UIKit

public struct AnyModalPresentation {
    private let presentation: ModalPresentation
    
    public init(presentation: ModalPresentation) {
        self.presentation = presentation
    }
}

extension AnyModalPresentation: ModalPresentation {
    public var modalPresentationStyle: UIModalPresentationStyle {
        return presentation.modalPresentationStyle
    }
    
    public func presentationController(presentedViewController: UIViewController, presenting: UIViewController?) -> UIPresentationController? {
        return presentation.presentationController(presentedViewController: presentedViewController, presenting: presenting)
    }
}
