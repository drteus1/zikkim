import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AchievementsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.missions.isEmpty {
                    ProgressView("Loading missions...")
                } else if !viewModel.missions.isEmpty {
                    List {
                        ForEach(viewModel.missions) { mission in
                            MissionRow(mission: mission, progress: viewModel.progress[mission.id]) {
                                Task {
                                    await viewModel.markCompleted(missionId: mission.id, authViewModel: authViewModel)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    ContentUnavailableView(
                        "No missions yet",
                        systemImage: "target",
                        description: Text("Come back soon for new milestones.")
                    )
                }
            }
            .navigationTitle("Achievements")
            .task {
                await viewModel.load(authViewModel: authViewModel)
            }
            .refreshable {
                await viewModel.load(authViewModel: authViewModel)
            }
            .overlay(alignment: .bottom) {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

private struct MissionRow: View {
    let mission: Mission
    let progress: MissionProgress?
    let onComplete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(color)
                .font(.title2)
                .padding(10)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(mission.title)
                    .font(.headline)
                if let description = mission.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let reward = mission.reward {
                    Text(reward)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.green)
                }
            }
            Spacer()
            Button(action: onComplete) {
                Text(progress != nil ? "Done" : "Mark")
            }
            .buttonStyle(.borderedProminent)
            .tint(progress != nil ? .gray : .blue)
            .disabled(progress != nil)
        }
        .padding(.vertical, 6)
    }

    private var iconName: String {
        if progress != nil { return "checkmark.seal.fill" }
        return "target"
    }

    private var color: Color {
        if progress != nil { return .green }
        return .blue
    }
}

