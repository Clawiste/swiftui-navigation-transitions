//
//  File.swift
//  
//
//  Created by Jan Prokes on 26.06.2023.
//

import Foundation
import UIKit

public protocol ModalPresentation {
    var modalPresentationStyle: UIModalPresentationStyle { get }
    
    func presentationController(presentedViewController: UIViewController, presenting: UIViewController?) -> UIPresentationController?
}

public extension AnyModalPresentation {
    static var fullScreenCover: AnyModalPresentation {
        return AnyModalPresentation(presentation: FullScreenCoverModalPresentation())
    }
}

struct FullScreenCoverModalPresentation: ModalPresentation {
    let modalPresentationStyle: UIModalPresentationStyle = .overFullScreen
    
    func presentationController(presentedViewController: UIViewController, presenting: UIViewController?) -> UIPresentationController? {
        return nil
    }
}

@available(iOS 15.0, *)
public extension AnyModalPresentation {
    static var sheet: AnyModalPresentation {
        return AnyModalPresentation(presentation: SheetModalPresentation())
    }
}

@available(iOS 15.0, *)
struct SheetModalPresentation: ModalPresentation {
    let modalPresentationStyle: UIModalPresentationStyle = .custom
    
    func presentationController(presentedViewController: UIViewController, presenting: UIViewController?) -> UIPresentationController? {
        let presentationController = UISheetPresentationController(presentedViewController: presentedViewController, presenting: presenting)
        
        presentationController.detents = [.large(), .medium()]
        
        return presentationController
    }
}
