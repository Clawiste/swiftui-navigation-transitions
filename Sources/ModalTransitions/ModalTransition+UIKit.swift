@_spi(package) import ModalTransition
@_implementationOnly import RuntimeAssociation
import UIKit
import SwiftUI

extension AnyModalTransition {
    public enum Interactivity {
        case disabled

        @inlinable
        public static var `default`: Self {
            .disabled
        }
    }
}

struct ModalHostingView<Item: Identifiable, Destination: View>: UIViewRepresentable {
    private let onDismiss: (() -> Void)?
    private let item: Binding<Item?>
    private let destination: (Item) -> Destination
    private let transition: AnyModalTransition
    private let presentation: AnyModalPresentation
        
    init(
        onDismiss: (() -> Void)? = nil,
        item: Binding<Item?>,
        destination: @escaping (Item) -> Destination,
        transition: AnyModalTransition,
        presentation: AnyModalPresentation
    ) {
        self.onDismiss = onDismiss
        self.item = item
        self.destination = destination
        self.transition = transition
        self.presentation = presentation
    }
        
    func makeUIView(context: Context) -> ViewControllerReader {
        return ViewControllerReader()
    }
    
    func updateUIView(_ uiView: ViewControllerReader, context: Context) {        
        if let item = item.wrappedValue {
            context.coordinator.id = item.id.hashValue
            let viewController = HostingController(item: item, destination: destination) {
                self.item.wrappedValue = nil
                onDismiss?()
            }
            
            viewController.view.tag = item.id.hashValue
            viewController.modalPresentationStyle = presentation.modalPresentationStyle
            viewController.transitioningDelegate = context.coordinator.delegate
            
            viewController.view.backgroundColor = .clear
            
            if let presentingViewController = uiView.presentingViewController {
                if
                    let presentedViewController = presentingViewController.presentedViewController
                {
                    if (presentedViewController as? HostingController<Item, Destination>)?.item.id != item.id {
                        presentedViewController.dismiss(animated: true) {
                            presentingViewController.present(viewController, animated: true)
                        }
                    }
                } else {
                    presentingViewController.present(viewController, animated: true)
                }
            }
        } else {
            if
                let presentingViewController = uiView.presentingViewController?.presentedViewController,
                presentingViewController.view.tag == context.coordinator.id
            {
                context.coordinator.id = nil
                context.coordinator.onDismiss?()
                uiView.presentingViewController?.presentedViewController?.dismiss(animated: true)
            }
        }
    }
    
    static func dismantleUIView(_ uiView: ViewControllerReader, coordinator: Coordinator) {
        coordinator.onDismiss?()
        uiView.presentingViewController?.presentedViewController?.dismiss(animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: onDismiss,
            delegate: ModalTransitionDelegate(
                transition: transition,
                presentation: presentation
            )
        )
    }

    class Coordinator: NSObject {
        var id: Int?
        let onDismiss: (() -> Void)?
        let delegate: ModalTransitionDelegate
        
        init(
            onDismiss: (() -> Void)? = nil,
            delegate: ModalTransitionDelegate
        ) {
            self.onDismiss = onDismiss
            self.delegate = delegate
        }
    }
}

final class HostingController<Item: Identifiable, Destination: View>: UIHostingController<Destination> {
    let item: Item
    let onDismiss: (() -> Void)?
    
    init(
        item: Item,
        destination: @escaping (Item) -> Destination,
        onDismiss: (() -> Void)?
    ) {
        self.item = item
        self.onDismiss = onDismiss
        
        super.init(rootView: destination(item))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        onDismiss?()
    }
}
