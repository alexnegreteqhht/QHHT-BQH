import SwiftUI

@main
struct QHHTBQHApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authStateDelegate = AuthStateDelegate()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authStateDelegate.isAuthenticated {
                    ContentView(userProfile: UserProfile())
                } else {
                    LoginPage()
                }
            }.environmentObject(authStateDelegate)
        }
    }
}
