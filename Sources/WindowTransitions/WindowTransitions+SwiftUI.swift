import SwiftUI
import ModalTransitions

public extension View {
    func window<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        transition: AnyModalTransition,
        presentation: AnyModalPresentation,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping (Item) -> Content
    ) -> some View {
        self
            .background(
                WindowHostingView(
                    onDismiss: onDismiss,
                    item: item,
                    destination: destination,
                    transition: transition,
                    presentation: presentation
                )
            )
    }
}
