import Foundation
import Network
import Combine
import CoreLocation
import SystemConfiguration.CaptiveNetwork

final class AppState: NSObject, ObservableObject {
    enum AdMode { case defaultNeoX2, sony }

    @Published var adMode: AdMode = .defaultNeoX2
    @Published var isOnWiFi: Bool = false
    @Published var requiresLocationForSSID: Bool = false

    #if DEBUG
    @Published var debugSimulateRealm: Bool = false {
        didSet { updateAdMode() }
    }
    #endif

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "net.acloudradius.neox2.path")
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = LocationManager()
    private let realmDetector: RealmDetector = {
        #if HOTSPOT_HELPER_ENABLED
        return HotspotHelperRealmDetector()
        #else
        return RealmDetector()
        #endif
    }()

    override init() {
        super.init()
        startMonitoring()
        realmDetector.start()

        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                // If we want to read SSID, we need WhenInUse
                self.requiresLocationForSSID = (status == .notDetermined || status == .denied || status == .restricted)
            }
            .store(in: &cancellables)

        realmDetector.$naiRealm
            .receive(on: DispatchQueue.main)
            .sink { [weak self] realm in
                guard let self = self else { return }
                if let realm = realm, realm.lowercased().contains("sony.net") {
                    self.adMode = .sony
                } else {
                    self.updateAdMode()
                }
            }
            .store(in: &cancellables)
    }

    func appBecameActive() {
        // Re-evaluate after potential profile installation
        reevaluateNetworkAndUpdateAd()
    }

    func requestLocationPermission() { locationManager.requestWhenInUse() }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnWiFi = path.usesInterfaceType(.wifi)
                self?.updateAdMode()
            }
        }
        monitor.start(queue: queue)
    }

    var connectivityDescription: String {
        if isOnWiFi {
            if let ssid = currentSSID() {
                return "On Wi‑Fi (\(ssid))"
            } else {
                return "On Wi‑Fi"
            }
        } else {
            return "On Cellular/Other"
        }
    }

    private func reevaluateNetworkAndUpdateAd() {
        updateAdMode()
    }

    private func updateAdMode() {
        #if DEBUG
        if debugSimulateRealm { adMode = .sony; return }
        #endif

        // If we have a realm published, prefer that logic.
        if let realm = (realmDetector as AnyObject).value(forKey: "naiRealm") as? String, realm.lowercased().contains("sony.net") {
            adMode = .sony
            return
        }

        guard isOnWiFi else { adMode = .defaultNeoX2; return }

        // Optional SSID check (tighten this if you provide expected SSID)
        if let _ = currentSSID() {
            // Execute a lightweight reachability check to the realm domain.
            checkReachabilityOfRealm { [weak self] reachable in
                DispatchQueue.main.async {
                    self?.adMode = reachable ? .sony : .defaultNeoX2
                }
            }
        } else {
            // No SSID info (no permission): still attempt reachability while on Wi‑Fi
            checkReachabilityOfRealm { [weak self] reachable in
                DispatchQueue.main.async {
                    self?.adMode = reachable ? .sony : .defaultNeoX2
                }
            }
        }
    }

    private func checkReachabilityOfRealm(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://acloudradius.net") else { completion(false); return }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let http = response as? HTTPURLResponse, (200..<400).contains(http.statusCode), error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }

    private func currentSSID() -> String? {
        // Requires Access Wi‑Fi Information capability AND Location When In Use authorized
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways else {
            return nil
        }
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for iface in interfaces {
                if let dict = CNCopyCurrentNetworkInfo(iface as CFString) as? [String: AnyObject], let ssid = dict[kCNNetworkInfoKeySSID as String] as? String {
                    return ssid
                }
            }
        }
        return nil
    }
}
