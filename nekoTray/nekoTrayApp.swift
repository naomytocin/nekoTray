import SwiftUI

@main
struct nekoTrayApp: App {
    @StateObject private var neko = CatViewModel()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView(neko: neko)
        } label: {

            Image(neko.statusIconName)
        }
        .menuBarExtraStyle(.window)
    }
}
