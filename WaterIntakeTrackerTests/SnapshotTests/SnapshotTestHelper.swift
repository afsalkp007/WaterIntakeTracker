import SwiftUI
import UIKit

@MainActor
public final class SnapshotTestHelper {

    /// Renders any SwiftUI view to an optional UIImage using Apple's native ImageRenderer
    public static func render<V: View>(view: V, size: CGSize = CGSize(width: 375, height: 400), colorScheme: ColorScheme = .light) -> UIImage? {
        let hostingController = UIHostingController(
            rootView: view
                .environment(\.colorScheme, colorScheme)
                .frame(width: size.width, height: size.height)
        )

        let view = hostingController.view
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear

        let renderer = ImageRenderer(content: view.map { AnyView(UIViewRepresentableWrapper(uiView: $0)) })
        renderer.scale = 2.0

        return renderer.uiImage
    }
}

private struct UIViewRepresentableWrapper: UIViewRepresentable {
    let uiView: UIView

    func makeUIView(context: Context) -> UIView {
        return uiView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
