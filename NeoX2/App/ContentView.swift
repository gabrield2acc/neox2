import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationView {
        VStack(spacing: 24) {
            Spacer(minLength: 24)

            // Title
            Text("neoX2")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(.linearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing))

            // Marketing section (styled like images)
            Group {
                if appState.adMode == .defaultNeoX2 {
                    AdNeoX2View()
                } else {
                    AdSonyView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)

            // Profile install button
            Button(action: openProfileURL) {
                HStack(spacing: 12) {
                    Image(systemName: "wifi")
                    Text("Get Passpoint Profile")
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal)

            NavigationLink(destination: ProfileSetupView()) {
                Label("How to install the profile", systemImage: "questionmark.circle")
            }
            .padding(.horizontal)

            // Status & controls
            VStack(spacing: 8) {
                HStack {
                    Label(appState.connectivityDescription, systemImage: appState.isOnWiFi ? "wifi" : "antenna.radiowaves.left.and.right")
                    Spacer()
                }
                .font(.footnote)
                .foregroundColor(.secondary)

                if appState.requiresLocationForSSID {
                    Button("Allow Location to Read SSID") {
                        appState.requestLocationPermission()
                    }
                    .font(.footnote)
                }

                #if DEBUG
                Toggle("Simulate Passpoint Realm Detected", isOn: $appState.debugSimulateRealm)
                    .padding(.top, 8)
                    .padding(.horizontal)
                #endif
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("neoX2")
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active { appState.appBecameActive() }
        }
        }
    }

    private func openProfileURL() {
        guard let url = URL(string: "https://profiles.acloudradius.net") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Ad Views (stylized as images)

struct AdNeoX2View: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.9), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(spacing: 8) {
                Text("neoX2")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                Text("Fast. Seamless. Secure.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .frame(height: 200)
    }
}

struct AdSonyView: View {
    var body: some View {
        ZStack {
            // AI-styled effect using layered gradients, glow, and noise overlay
            LinearGradient(colors: [.black, Color.blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [.blue.opacity(0.2), .clear], center: .center, startRadius: 10, endRadius: 200)
            VStack(spacing: 10) {
                Text("SONY")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .blue.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: .blue.opacity(0.6), radius: 16, x: 0, y: 8)
                    .overlay(
                        Text("SONY")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.12))
                            .blur(radius: 2)
                    )
                Text("AI‑styled dynamic branding")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                Text("Activated by realm: sony.net")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
            }
            .padding(.vertical)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .frame(height: 200)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
