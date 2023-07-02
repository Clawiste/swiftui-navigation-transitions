import UIKit

final class WindowReader: UIView {
    var _window: PassthroughWindow?
    let rootViewController = PassthroughViewController()

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
        }
    }
}
