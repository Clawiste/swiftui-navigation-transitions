import SwiftUI
@_implementationOnly import SwiftUIIntrospect
import Foundation
import SwiftUI

extension View {
    public func presentation<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        transition: AnyModalTransition,
        presentation: AnyModalPresentation,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping (Item) -> Content
    ) -> some View {
        self
            .background(
                ModalHostingView(
                    onDismiss: onDismiss,
                    item: item,
                    destination: destination,
                    transition: transition,
                    presentation: presentation
                )
            )
    }
}

