import Foundation
import JavaScriptEventLoop
import ElementaryUI
import BluetoothWeb

@main
struct WebApp {

    static func main() {
        JavaScriptEventLoop.installGlobalExecutor()
        let app = Application(ContentView())
        app.mount(in: .body)
    }
}
