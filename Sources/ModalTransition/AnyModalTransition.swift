import Animation
import UIKit

public struct AnyModalTransition {
    @_spi(package) public struct _Animation {
        static let `default` = _Animation()
        
        public var `in`: Animation = .default
        public var out: Animation = .default
    }
    
    @_spi(package) public typealias TransientHandler = (
        AnimatorTransientView,
        AnimatorTransientView,
        ModalTransitionOperation,
        UIView
    ) -> Void

    @_spi(package) public typealias PrimitiveHandler = (
        Animator,
        ModalTransitionOperation,
        UIViewControllerContextTransitioning
    ) -> Void

    @_spi(package) public enum Handler {
        case transient(TransientHandler)
        case primitive(PrimitiveHandler)
    }

    @_spi(package) public let isDefault: Bool
    @_spi(package) public let handler: Handler
    @_spi(package) public var animation: _Animation? = .default

    public init<T: ModalTransition>(_ transition: T) {
        self.isDefault = false
        self.handler = .transient(transition.transition(from:to:for:in:))
    }

    public init<T: PrimitiveModalTransition>(_ transition: T) {
        self.isDefault = transition is Default
        self.handler = .primitive(transition.transition(with:for:in:))
    }
}

extension AnyModalTransition {
    /// Attaches an animation to this transition.
    public func animation(in: Animation, out: Animation) -> Self {
        var copy = self
        var animation = AnyModalTransition._Animation.default
        
        animation.in = `in`
        animation.out = out
        
        copy.animation = animation
        
        return copy
    }
    
    /// Attaches an animation to this transition.
    public func animation(_ inAndOut: Animation?) -> Self {
        var copy = self
        if let inAndOut {
            var animation = AnyModalTransition._Animation.default
            
            animation.in = inAndOut
            animation.out = inAndOut
            
            copy.animation = animation
        } else {
            copy.animation = nil
        }
        return copy
    }
}
