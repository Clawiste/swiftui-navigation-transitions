import AtomicTransition

/// Used to define a transition that executes only on push.
public struct On<Transition: AtomicTransition>: ModalTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
//        transition.transition(fromView, for: .removal, in: container)
        transition.transition(toView, for: .insertion, in: container)
    }
}

extension On: Equatable where Transition: Equatable {}
extension On: Hashable where Transition: Hashable {}

/// Used to define a transition that executes only on push.
public struct OnPresent<Transition: AtomicTransition>: ModalTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        switch operation {
        case .present:
//            transition.transition(fromView, for: .removal, in: container)
            transition.transition(toView, for: .insertion, in: container)
        case .dismiss:
            return
        }
    }
}

extension OnPresent: Equatable where Transition: Equatable {}
extension OnPresent: Hashable where Transition: Hashable {}

/// Used to define a transition that executes only on pop.
public struct OnDismiss<Transition: AtomicTransition>: ModalTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        switch operation {
        case .present:
            return
        case .dismiss:
//            transition.transition(fromView, for: .removal, in: container)
            transition.transition(toView, for: .insertion, in: container)
        }
    }
}

extension OnDismiss: Equatable where Transition: Equatable {}
extension OnDismiss: Hashable where Transition: Hashable {}
