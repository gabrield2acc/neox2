import SwiftUI

struct ProfileSetupView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Install Passpoint Profile")
                    .font(.title.bold())

                Text("Follow these steps to install the Passpoint (Hotspot 2.0) profile. This enables automatic, secure Wi‑Fi connectivity where supported.")

                StepView(number: 1, title: "Open the Profile Portal", content: "Tap the button below to open profiles.acloudradius.net in your browser.")
                Button(action: {
                    if let url = URL(string: "https://profiles.acloudradius.net") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Open profiles.acloudradius.net", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                StepView(number: 2, title: "Allow Download", content: "If prompted, allow the profile to download.")
                StepView(number: 3, title: "Install in Settings", content: "Go to Settings > Profile Downloaded and follow the prompts to install the profile.")
                StepView(number: 4, title: "Trust the Certificate (if asked)", content: "Depending on your profile, you might be asked to trust a network certificate.")
                StepView(number: 5, title: "Enable Location (optional)", content: "To let the app confirm Wi‑Fi SSID for a better experience, allow Location access from the app’s Settings page.")

                HStack {
                    Button("Open App Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
                    }
                    .buttonStyle(.bordered)
                }

                Divider().padding(.vertical, 8)

                Text("After Installation")
                    .font(.headline)
                Text("Once installed, your device will automatically connect to compatible Passpoint networks in range. The app will update the marketing section once Wi‑Fi connectivity is detected.")

                Text("Note on NAI Realm")
                    .font(.headline)
                Text("Detecting the NAI realm advertised by an access point requires Apple’s HotspotHelper entitlement. If your bundle is approved for this entitlement, we can integrate true realm detection; otherwise the app uses a safe network‑reachability heuristic.")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Profile Setup")
    }
}

private struct StepView: View {
    let number: Int
    let title: String
    let content: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.blue.opacity(0.15)))
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(content).foregroundColor(.secondary)
            }
        }
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { ProfileSetupView() }
    }
}
