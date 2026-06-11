import SwiftUI
import UIKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            AgentCanvasDemoScreen()
        }
    }
}

// MARK: - Host Apple's AgentCanvasUICore.AgentCanvasDemoView 1:1
//
// `AgentCanvasDemoView` is Apple's built-in, no-arg SwiftUI demo harness for the new
// Siri / Agent-Canvas response UI (serif titles, streamed markdown, callouts,
// suggestion chips, accordions, sample responses). It's a zero-size POD struct. We
// host it by building `UIHostingController<AgentCanvasDemoView>` through the Swift
// runtime: resolve its `SwiftUI.View` witness with `swift_conformsToProtocol`,
// instantiate the hosting metadata, then call `init(rootView:)` with the metadata in
// x20 (the swiftcc trampoline `DLCallRet1_X20`). Unentitled.

@MainActor
enum AgentCanvasDemo {
    private static let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)

    static func makeViewController() -> UIViewController? {
        let acPath = "/System/Library/PrivateFrameworks/AgentCanvasUICore.framework/AgentCanvasUICore"
        guard dlopen(acPath, RTLD_NOW) != nil else { return nil }

        guard
            let demoMa = dlsym(RTLD_DEFAULT, "$s17AgentCanvasUICore0abC8DemoViewVMa"),
            let hcMa   = dlsym(RTLD_DEFAULT, "$s7SwiftUI19UIHostingControllerCMa"),
            let hcInit = dlsym(RTLD_DEFAULT, "$s7SwiftUI19UIHostingControllerC8rootViewACyxGx_tcfC"),
            let viewProto = dlsym(RTLD_DEFAULT, "$s7SwiftUI4ViewMp"),
            let conforms  = dlsym(RTLD_DEFAULT, "swift_conformsToProtocol")
        else { return nil }

        typealias MetaAccessor1 = @convention(c) (Int) -> UnsafeRawPointer
        typealias MetaAccessor3 = @convention(c) (Int, UnsafeRawPointer, UnsafeRawPointer) -> UnsafeRawPointer
        typealias Conforms = @convention(c) (UnsafeRawPointer, UnsafeRawPointer) -> UnsafeRawPointer?

        // 1. AgentCanvasDemoView type metadata.
        let demoMD = unsafeBitCast(demoMa, to: MetaAccessor1.self)(0)
        // 2. Its SwiftUI.View witness table.
        guard let viewWT = unsafeBitCast(conforms, to: Conforms.self)(demoMD, viewProto) else { return nil }
        // 3. UIHostingController<AgentCanvasDemoView> metadata.
        let hcMD = unsafeBitCast(hcMa, to: MetaAccessor3.self)(0, demoMD, viewWT)
        // 4. rootView slot (DemoView is size 0 — a zeroed buffer suffices).
        let rootView = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 16)
        defer { rootView.deallocate() }
        memset(rootView, 0, 16)
        // 5. UIHostingController.init(rootView:) — rootView in x0, hosting metadata in x20.
        guard let vcPtr = DLCallRet1_X20(rootView, UnsafeMutableRawPointer(mutating: hcMD), hcInit) else { return nil }
        return Unmanaged<UIViewController>.fromOpaque(vcPtr).takeRetainedValue()  // +1 retained
    }
}

struct AgentCanvasDemoHost: UIViewControllerRepresentable {
    @Binding var ok: Bool?
    func makeUIViewController(context: Context) -> UIViewController {
        if let vc = AgentCanvasDemo.makeViewController() {
            DispatchQueue.main.async { ok = true }
            return vc
        }
        DispatchQueue.main.async { ok = false }
        return UIHostingController(rootView: Color.clear)
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct AgentCanvasDemoScreen: View {
    @State private var ok: Bool?
    var body: some View {
        NavigationStack {
            AgentCanvasDemoHost(ok: $ok)
                .ignoresSafeArea()
                .overlay(alignment: .bottom) {
                    if ok == false {
                        Text("Couldn't instantiate AgentCanvasDemoView")
                    }
                }
        }
    }
}
