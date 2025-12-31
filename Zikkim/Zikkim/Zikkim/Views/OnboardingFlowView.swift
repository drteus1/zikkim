import SwiftUI
import Supabase
import AuthenticationServices
import CryptoKit

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let gradient: [Color]
}

struct OnboardingFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var currentIndex = 0
    @State private var quitDate = Date()
    @State private var cigarettesPerDay = 15
    @State private var pricePerPack = 10.0
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var isAuthorizingApple = false
    @FocusState private var focusField: Field?

    private enum Field { case cigs, price }

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Health first",
            subtitle: "Your heart, lungs, and skin start healing within minutes of stopping.",
            systemImage: "heart.text.square.fill",
            gradient: [.pink, .purple]
        ),
        OnboardingSlide(
            title: "Wealth regained",
            subtitle: "Every cigarette skipped keeps cash in your pocket for what matters most.",
            systemImage: "creditcard.fill",
            gradient: [.teal, .blue]
        ),
        OnboardingSlide(
            title: "Freedom",
            subtitle: "Drop the cravings. Win back control of your time, energy, and mood.",
            systemImage: "lock.open.display",
            gradient: [.orange, .red]
        ),
        OnboardingSlide(
            title: "Momentum",
            subtitle: "Tiny wins stack up. We track them in real-time so you never lose sight.",
            systemImage: "speedometer",
            gradient: [.indigo, .cyan]
        ),
        OnboardingSlide(
            title: "Support",
            subtitle: "Tap to log cravings, reflect, and stay accountable—synced securely in the cloud.",
            systemImage: "hands.sparkles.fill",
            gradient: [.mint, .green]
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(slides.enumerated()), id: \.1.id) { index, slide in
                    VStack(spacing: 24) {
                        Spacer()
                        Image(systemName: slide.systemImage)
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: slide.gradient,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(radius: 18)
                        Text(slide.title)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text(slide.subtitle)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Spacer()
                        Button(action: { withAnimation { goNext() } }) {
                            Text(index == slides.count - 1 ? "Continue" : "Next")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: slide.gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .tag(index)
                }

                onboardingForm
                    .tag(slides.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private var onboardingForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your quit plan")
                .font(.largeTitle.bold())
            Text("We will personalize your dashboard and sync securely to Supabase.")
                .foregroundStyle(.secondary)

            DatePicker("Quit date & time", selection: $quitDate, displayedComponents: [.date, .hourAndMinute])
                .tint(.blue)

            Stepper(value: $cigarettesPerDay, in: 1...60, step: 1) {
                HStack {
                    Text("Cigarettes per day")
                    Spacer()
                    Text("\(cigarettesPerDay)")
                        .monospacedDigit()
                        .bold()
                }
            }

            HStack {
                Text("Price per pack")
                Spacer()
                TextField("Price", value: $pricePerPack, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .focused($focusField, equals: .price)
            }
            .padding(.vertical, 4)

            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            VStack(spacing: 12) {
                SignInWithAppleButton(
                    .signUp,
                    onRequest: { request in
                        isAuthorizingApple = true
                        let rawNonce = NonceGenerator.shared.makeNonce()
                        NonceGenerator.shared.currentNonce = rawNonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = rawNonce.sha256()
                    },
                    onCompletion: { result in
                        Task { await handleAppleResult(result) }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .disabled(isSubmitting)

                Button(action: { Task { await submitProfile() } }) {
                    HStack {
                        if isSubmitting { ProgressView().tint(.white) }
                        Text(isSubmitting ? "Saving..." : "Start my journey")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(isSubmitting || isAuthorizingApple)
            }

            Text("This only shows once. You can always adjust your plan later.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func goNext() {
        if currentIndex < slides.count {
            currentIndex += 1
        }
    }

    private func submitProfile() async {
        errorMessage = nil
        guard cigarettesPerDay > 0, pricePerPack > 0 else {
            errorMessage = "Please add valid inputs."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            guard let session = authViewModel.session else {
                errorMessage = "Sign in with Apple first."
                return
            }

            try await authViewModel.upsertProfile(
                quitAt: quitDate,
                cigarettesPerDay: cigarettesPerDay,
                pricePerPack: pricePerPack,
                currency: Locale.current.currency?.identifier ?? "USD"
            )
            await authViewModel.loadProfile()
            hasCompletedOnboarding = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) async {
        isAuthorizingApple = false
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let identityToken = credential.identityToken,
                let tokenString = String(data: identityToken, encoding: .utf8),
                let nonce = NonceGenerator.shared.currentNonce
            else {
                errorMessage = "Unable to fetch Apple ID token."
                return
            }

            do {
                try await authViewModel.signInWithApple(idToken: tokenString, nonce: nonce)
                await authViewModel.loadProfile()
                // After successful sign-in, we can proceed to submitProfile if desired.
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

private final class NonceGenerator {
    static let shared = NonceGenerator()
    fileprivate var currentNonce: String?

    func makeNonce(length: Int = 32) -> String {
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}

private extension String {
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

