import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if let _ = authViewModel.userSession {
                if authViewModel.isEmailVerified {
                    MainTabView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                } else {
                    EmailVerificationView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
            } else {
                LoginView()
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.userSession != nil)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Tab = .transcripts

    enum Tab: String {
        case transcripts, feed, events, settings
    }

    var body: some View {
        ZStack {
            GlassBackgroundView()

            TabView(selection: $selectedTab) {
                TranscriptFeedView()
                    .tabItem {
                        Label("Transcripts", systemImage: "doc.text.fill")
                    }
                    .tag(Tab.transcripts)

                GroupMeFeedView()
                    .tabItem {
                        Label("Feed", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(Tab.feed)

                EventsView()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                    .tag(Tab.events)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(Tab.settings)
            }
            .tint(SColor.accent)
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear

                ScrollView {
                    VStack(spacing: SSpace.m.rawValue) {
                        // Account section
                        GlassCard {
                            VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                                Text("Account")
                                    .sectionHeaderStyle()

                                if let email = authViewModel.userSession?.email {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(SColor.accent)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(email)
                                                .font(.body)
                                                .foregroundStyle(SColor.text)
                                            Text(authViewModel.isAdmin ? "Admin" : "Member")
                                                .font(.caption)
                                                .foregroundStyle(SColor.textSecondary)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }

                        // Admin section
                        if authViewModel.isAdmin {
                            GlassCard {
                                VStack(alignment: .leading, spacing: SSpace.s.rawValue) {
                                    Text("Administration")
                                        .sectionHeaderStyle()

                                    NavigationLink(destination: AdminSettingsView()) {
                                        HStack {
                                            Image(systemName: "person.badge.shield.checkmark.fill")
                                                .foregroundStyle(SColor.accent)
                                            Text("Manage Roles")
                                                .foregroundStyle(SColor.text)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(SColor.textMuted)
                                        }
                                    }
                                }
                            }
                        }

                        // Sign out
                        GlassCard {
                            Button {
                                authViewModel.signOut()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundStyle(SColor.danger)
                                    Text("Sign Out")
                                        .foregroundStyle(SColor.danger)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(SSpace.m.rawValue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Email Verification View

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                GlassBackgroundView()

                VStack(spacing: SSpace.l.rawValue) {
                    Spacer()

                    GlassCard(cornerRadius: SRadius.loose.rawValue) {
                        VStack(spacing: SSpace.l.rawValue) {
                            Image(systemName: "envelope.badge")
                                .font(.system(size: 52))
                                .foregroundStyle(SColor.accent)

                            Text("Verify your email")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(SColor.text)

                            Text("We sent a verification link to your email. Please tap the link to verify your account, then return to the app.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(SColor.textSecondary)

                            if let message = authViewModel.infoMessage {
                                Text(message)
                                    .font(.footnote)
                                    .foregroundStyle(SColor.textSecondary)
                            }

                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(SColor.danger)
                            }

                            VStack(spacing: SSpace.s.rawValue) {
                                Button {
                                    authViewModel.sendEmailVerification()
                                } label: {
                                    Text("Resend verification email")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(SButtonSecondary())
                                .disabled(authViewModel.isLoading)

                                Button {
                                    authViewModel.reloadUser()
                                } label: {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        Text("I have verified – Check again")
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .buttonStyle(SButtonPrimary())
                                .disabled(authViewModel.isLoading)
                            }
                        }
                    }

                    Spacer()

                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SButtonSecondary())
                }
                .padding(SSpace.l.rawValue)
            }
            .navigationTitle("Email Verification")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
