import UIKit

final class WindowReader: UIView {
    var _window: PassthroughWindow?
    let rootViewController = PassthroughViewController()
    
    private var _viewControllerOnHold: UIViewController?

    init() {
        super.init(frame: .zero)
        
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let scene = window?.windowScene {
            _window = PassthroughWindow(windowScene: scene)
            _window?.rootViewController = rootViewController
            
            if let _viewControllerOnHold {
                rootViewController.present(_viewControllerOnHold, animated: false)
            }
        }
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // if window is not yet created, we want to wait for its creation and then present
        if _window == nil {
            _viewControllerOnHold = viewControllerToPresent
        } else {
            rootViewController.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        rootViewController.presentedViewController?.dismiss(animated: flag, completion: completion)
    }
}
