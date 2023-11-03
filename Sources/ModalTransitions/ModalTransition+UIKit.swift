@_spi(package) import ModalTransition
@_implementationOnly import RuntimeAssociation
import UIKit
import SwiftUI

struct ModalHostingView<Item: Identifiable, Destination: View>: UIViewRepresentable {
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
        if
            let presentingViewController = uiView.presentingViewController?.presentedViewController,
            presentingViewController.view.tag == coordinator.id
        {
            coordinator.onDismiss?()
            uiView.presentingViewController?.presentedViewController?.dismiss(animated: true)
        }
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
}

@_spi(package) public final class HostingController<Item: Identifiable, Destination: View>: UIHostingController<Destination> {
    public let item: Item
    let onDismiss: (() -> Void)?
    
    public init(
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        onDismiss?()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        clearBackgroundColor(views: [view])
    }
    
    #warning("Is there better a solution?")
    func clearBackgroundColor(views: [UIView]) {
        views
            .forEach { view in
                let viewClass = String(describing: type(of: view))
                
                let shouldClearBackgroud = ["_UIHostingView", "_UISplitViewControllerPanelImplView"]
                    .reduce(false) {
                        if $0 {
                            return $0
                        } else {
                            return viewClass.contains($1)
                        }
                    }
                
                if shouldClearBackgroud {
                    view.backgroundColor = .clear
                }
                
                clearBackgroundColor(views: view.subviews)
            }
    }
}
