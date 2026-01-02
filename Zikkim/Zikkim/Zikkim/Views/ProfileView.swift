import SwiftUI
internal import Auth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                if let profile = authViewModel.profile {
                    Section("Your plan") {
                        row(label: "Quit at", value: formatted(date: profile.quitAt))
                        row(label: "Cigs per day", value: "\(profile.cigarettesPerDay)")
                        row(label: "Price per pack", value: currency(profile.pricePerPack, currency: profile.currency))
                    }
                } else {
                    Section {
                        Text("No profile loaded yet.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Account") {
                    row(label: "User ID", value: authViewModel.session?.user.id.uuidString ?? "—")
                    Button("Refresh profile") {
                        Task { await authViewModel.loadProfile() }
                    }
                }

                Section("About") {
                    Text("Zikkim is built to keep you smoke-free with real-time stats, milestones, and cravings support.")
                    Text("Creator: Alperen Donmez")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .navigationTitle("Profile")
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }

    private func formatted(date: Date?) -> String {
        guard let date else { return "—" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func currency(_ amount: Double, currency: String?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currency { formatter.currencyCode = currency }
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

