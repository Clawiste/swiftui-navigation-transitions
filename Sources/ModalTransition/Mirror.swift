import AtomicTransition

/// Used to define a transition that executes on push, and executes the mirrored version of said transition on pop.
public struct MirrorPresent<Transition: MirrorableAtomicTransition>: ModalTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public var body: some ModalTransition {
        OnPresent {
            transition
        }
        OnDismiss {
            transition.mirrored()
        }
    }
}

extension MirrorPresent: Equatable where Transition: Equatable {}
extension MirrorPresent: Hashable where Transition: Hashable {}

/// Used to define a transition that executes on pop, and executes the mirrored version of said transition on push.
public struct MirrorDismiss<Transition: MirrorableAtomicTransition>: ModalTransition {
    private let transition: Transition

    public init(@AtomicTransitionBuilder transition: () -> Transition) {
        self.transition = transition()
    }

    public var body: some ModalTransition {
        OnPresent {
            transition.mirrored()
        }
        OnDismiss {
            transition
        }
    }
}

extension MirrorDismiss: Equatable where Transition: Equatable {}
extension MirrorDismiss: Hashable where Transition: Hashable {}
