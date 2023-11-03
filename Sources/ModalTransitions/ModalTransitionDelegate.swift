//
//  File.swift
//  
//
//  Created by Jan Prokes on 24.06.2023.
//

@_spi(package) import Animation
@_spi(package) import Animator
@_spi(package) import ModalTransition

import UIKit

@_spi(package) public final class ModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let presentation: ModalPresentation
    let transition: AnyModalTransition
    
    public var interactionController: UIPercentDrivenInteractiveTransition?
    private var initialAreAnimationsEnabled = UIView.areAnimationsEnabled

    public init(
        transition: AnyModalTransition,
        presentation: ModalPresentation
    ) {
        self.presentation = presentation
        self.transition = transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if
            !transition.isDefault,
            let animation = transition.animation
        {
            return ModalTransitionAnimatorProvider(transition: transition, animation: animation, operation: .dismiss)
        } else {
            return nil
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if
            !transition.isDefault,
            let animation = transition.animation
        {
            return ModalTransitionAnimatorProvider(transition: transition, animation: animation, operation: .present)
        } else {
            return nil
        }
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !transition.isDefault {
            return interactionController
        } else {
            return nil
        }
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !transition.isDefault {
            return interactionController
        } else {
            return nil
        }
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return presentation.presentationController(presentedViewController: presented, presenting: presenting)
    }
}

final class ModalTransitionAnimatorProvider: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {
    let transition: AnyModalTransition
    let animation: AnyModalTransition._Animation
    let operation: ModalTransitionOperation

    private var cachedAnimators: [ObjectIdentifier: UIViewPropertyAnimator] = .init(minimumCapacity: 1)
    
    init(transition: AnyModalTransition, animation: AnyModalTransition._Animation, operation: ModalTransitionOperation) {
        self.transition = transition
        self.animation = animation
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch operation {
        case .present:
            return animation.out.duration
        case .dismiss:
            return animation.in.duration
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionAnimator(for: transitionContext).startAnimation()
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        transitionAnimator(for: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        transitionAnimator(for: transitionContext)
    }
    
    private func transitionAnimator(for transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        if let cached = cachedAnimators[ObjectIdentifier(transitionContext)] {
            return cached
        }
        
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            timingParameters: {
                switch operation {
                case .present:
                    return animation.in.timingParameters
                case .dismiss:
                    return animation.out.timingParameters
                }
            }()
        )
        
        cachedAnimators[ObjectIdentifier(transitionContext)] = animator
        
        let container = transitionContext.containerView
        
        guard
            let fromUIView = transitionContext.viewController(forKey: .from)?.view,
            let toUIView = transitionContext.viewController(forKey: .to)?.view
        else {
            return animator
        }
        
        fromUIView.isUserInteractionEnabled = false
        toUIView.isUserInteractionEnabled = false
        
        switch transition.handler {
        case .transient(let handler):
            if let (fromView, toView) = transientViews(
                for: handler,
                animator: animator,
                context: (container, fromUIView, toUIView)
            ) {
                switch operation {
                case .present:
                    for view in [fromView, toView] {
                        view.setUIViewProperties(to: \.initial)
                        animator.addAnimations { view.setUIViewProperties(to: \.animation) }
                        animator.addCompletion { _ in
                            if transitionContext.transitionWasCancelled {
                                view.resetUIViewProperties()
                            } else {
                                view.setUIViewProperties(to: \.completion)
                            }
                        }
                    }
                case .dismiss:
                    for view in [fromView, toView] {
                        view.setUIViewProperties(to: \.completion)
                        animator.addAnimations {
                            view.setUIViewProperties(to: \.initial)
                        }
                        animator.addCompletion { _ in
                            if transitionContext.transitionWasCancelled {
                                view.resetUIViewProperties()
                            } else {
                                view.setUIViewProperties(to: \.initial)
                            }
                        }
                    }
                }
            }
        case .primitive(let handler):
            handler(animator, operation, transitionContext)
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

            fromUIView.isUserInteractionEnabled = true
            toUIView.isUserInteractionEnabled = true
        }

        return animator
    }
    
    private func transientViews(
        for handler: AnyModalTransition.TransientHandler,
        animator: Animator,
        context: (container: UIView, fromUIView: UIView, toUIView: UIView)
    ) -> (fromView: AnimatorTransientView, toView: AnimatorTransientView)? {
        let (container, fromUIView, toUIView) = context

        fromUIView.frame = container.frame
        toUIView.frame = container.frame

        let fromView = AnimatorTransientView(fromUIView)
        let toView = AnimatorTransientView(toUIView)

        switch operation {
        case .present:
            container.insertSubview(toUIView, aboveSubview: fromUIView)
            
            handler(fromView, toView, operation, container)

            return (fromView, toView)
        case .dismiss:
            handler(toView, fromView, operation, container)

            return (toView, fromView)
        }
    }
}
