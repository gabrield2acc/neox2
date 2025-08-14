import Foundation
import Combine

// Realm detection is only possible with Apple's private HotspotHelper entitlement.
// This file provides a no-op detector by default, and an optional implementation stub
// behind the HOTSPOT_HELPER_ENABLED flag for teams who have the entitlement.

class RealmDetector: ObservableObject {
    @Published var naiRealm: String? = nil
    func start() { /* no-op */ }
}

#if HOTSPOT_HELPER_ENABLED
import NetworkExtension

// IMPORTANT: This code path requires the com.apple.developer.networking.HotspotHelper entitlement.
// Without it, registration will fail at runtime and App Store submission will be rejected.
final class HotspotHelperRealmDetector: RealmDetector {
    private var isRegistered = false

    override func start() {
        guard !isRegistered else { return }
        let queue = DispatchQueue(label: "net.acloudradius.neox2.hotspothelper")
        let options: [String: NSObject] = [kNEHotspotHelperOptionDisplayName: "neoX2" as NSString]
        let result = NEHotspotHelper.register(options: options, queue: queue) { [weak self] cmd in
            guard let self = self else { return }
            // NOTE: Real ANQP/NAI realm extraction would happen here based on command type
            // and available network list. This is highly dependent on private behaviors.
            // For illustration, we leave this as a placeholder.
            // self.naiRealm = extractedRealm
        }
        isRegistered = result
    }
}
#endif

