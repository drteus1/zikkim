import SwiftUI

@main
struct ZikkimApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    DashboardView()
                        .environmentObject(authViewModel)
                } else {
                    OnboardingFlowView()
                        .environmentObject(authViewModel)
                }
            }
            .task {
                await authViewModel.restoreSession()
            }
        }
    }
}

