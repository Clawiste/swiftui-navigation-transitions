import AtomicTransition

extension AnyModalTransition {
    public static var none: Self {
        .init(None())
    }
}

@_spi(package) public struct None: ModalTransition {
    init() {
        
    }

    public var body: some ModalTransition {
        Empty()
    }
}

public struct Empty: ModalTransition {
    public func transition(
        from fromView: TransientView,
        to toView: TransientView,
        for operation: TransitionOperation,
        in container: Container
    ) {
        
    }
}

extension Empty: Equatable {}
extension Empty: Hashable {}
