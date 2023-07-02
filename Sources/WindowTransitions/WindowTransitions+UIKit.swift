import UIKit
import SwiftUI
import ModalTransition
@_spi(package) import ModalTransitions

struct WindowHostingView<Item: Identifiable, Destination: View>: UIViewRepresentable {
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
        
    func makeUIView(context: Context) -> WindowReader {
        return WindowReader()
    }
    
    func updateUIView(_ uiView: WindowReader, context: Context) {
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

            if !(uiView._window?.isKeyWindow ?? true) {
                uiView._window?.makeKeyAndVisible()
            }
            
            if
                let presentedViewController = uiView.rootViewController.presentedViewController
            {
                if (presentedViewController as? HostingController<Item, Destination>)?.item.id != item.id {
                    presentedViewController.dismiss(animated: true) {
                        uiView.rootViewController.present(viewController, animated: true)
                    }
                }
            } else {
                uiView.rootViewController.present(viewController, animated: true)
            }
            
        } else {
            if
                let presentingViewController = uiView.rootViewController.presentedViewController,
                presentingViewController.view.tag == context.coordinator.id
            {
                context.coordinator.id = nil
                context.coordinator.onDismiss?()
                uiView.rootViewController.presentedViewController?.dismiss(animated: true)
            }
            
            if !(uiView.window?.isKeyWindow ?? true) {
                uiView.window?.makeKeyAndVisible()
            }
        }
    }
    
    static func dismantleUIView(_ uiView: WindowReader, coordinator: Coordinator) {
//        coordinator.onDismiss?()
//        uiView.presentingViewController?.presentedViewController?.dismiss(animated: true)
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
