import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = DashboardViewModel()

    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: [.purple.opacity(0.9), .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    counters
                    milestones
                    cravingAction
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.configure(profile: authViewModel.profile)
            }
            .onChange(of: authViewModel.profile?.id) { _, _ in
                viewModel.configure(profile: authViewModel.profile)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time smoke-free")
                .foregroundStyle(.secondary)
            Text(elapsedString(viewModel.stats.elapsed))
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text("Keep going—your body is already healing.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(headerGradient)
        )
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 10)
    }

    private var counters: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                CounterCard(
                    title: "Cigs avoided",
                    value: formatted(viewModel.stats.cigarettesAvoided, suffix: ""),
                    systemImage: "nosign",
                    gradient: LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                CounterCard(
                    title: "Money saved",
                    value: formattedCurrency(viewModel.stats.moneySaved),
                    systemImage: "dollarsign.circle.fill",
                    gradient: LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }
            CounterCard(
                title: "Life regained",
                value: lifeString(minutes: viewModel.stats.lifeMinutesRegained),
                systemImage: "heart.circle.fill",
                gradient: LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }

    private var milestones: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health milestones")
                .font(.headline)
            ForEach(viewModel.milestoneProgress, id: \.0.id) { milestone, progress in
                MilestoneCard(milestone: milestone, progress: progress)
            }
        }
    }

    private var cravingAction: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cravings")
                .font(.headline)
            CravingButton(action: {
                Task { await viewModel.logCraving() }
            }, isLoading: viewModel.isLoggingCraving)
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
    }

    private func elapsedString(_ interval: TimeInterval) -> String {
        let days = Int(interval / 86_400)
        let hours = Int(interval.truncatingRemainder(dividingBy: 86_400) / 3600)
        let minutes = Int(interval.truncatingRemainder(dividingBy: 3600) / 60)
        return "\(days)d \(hours)h \(minutes)m"
    }

    private func formatted(_ value: Double, suffix: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: value)) ?? "0"
        return "\(number)\(suffix)"
    }

    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    private func lifeString(minutes: Double) -> String {
        let hours = minutes / 60
        if hours < 24 {
            return "\(Int(hours)) hrs"
        }
        let days = Int(hours / 24)
        return "\(days) days"
    }
}

