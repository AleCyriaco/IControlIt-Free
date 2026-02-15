import Foundation
import CoreBluetooth
import CoreLocation
import Network
import UIKit
import Combine
import WidgetKit

/// Serviço central para controle dos rádios do dispositivo.
///
/// LIMITAÇÕES DO iOS:
/// - Apps de terceiros NÃO podem desligar Wi-Fi/Bluetooth/GPS diretamente
/// - A melhor abordagem é redirecionar ao painel exato de Ajustes via URL Scheme
/// - App Intents permitem criar automações no app Atalhos
/// - CoreBluetooth detecta estado mas não controla globalmente
/// - CLLocationManager controla apenas permissão do próprio app
final class RadioControlService: NSObject, ObservableObject {
    static let shared = RadioControlService()

    // MARK: - Published State

    @Published var wifiStatus: ServiceStatus = .unknown
    @Published var bluetoothStatus: ServiceStatus = .unknown
    @Published var locationStatus: ServiceStatus = .unknown

    // MARK: - Private

    private var bluetoothManager: CBCentralManager?
    private let locationManager = CLLocationManager()
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.icontrolit.networkmonitor")
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UserDefaults Keys

    private let wifiStateKey = "icontrolit_wifi_state"
    private let bluetoothStateKey = "icontrolit_bluetooth_state"
    private let locationStateKey = "icontrolit_location_state"

    override init() {
        super.init()
        bluetoothManager = CBCentralManager(delegate: self, queue: .main, options: [
            CBCentralManagerOptionShowPowerAlertKey: false
        ])
        locationManager.delegate = self
        startWiFiMonitor()
        loadSavedStates()
        detectCurrentStates()
    }

    deinit {
        pathMonitor.cancel()
    }

    // MARK: - State Detection

    func detectCurrentStates() {
        detectBluetoothState()
        detectLocationState()
        detectWiFiState()
    }

    /// Inicia NWPathMonitor para detectar Wi-Fi em tempo real
    private func startWiFiMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let usesWifi = path.usesInterfaceType(.wifi)
            DispatchQueue.main.async {
                self?.wifiStatus = usesWifi ? .on : .off
                self?.syncToWidget(.wifi, isOn: usesWifi)
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    private func detectWiFiState() {
        // Estado é atualizado continuamente via NWPathMonitor
        let path = pathMonitor.currentPath
        wifiStatus = path.usesInterfaceType(.wifi) ? .on : .off
    }

    private func detectBluetoothState() {
        // Estado é atualizado via CBCentralManagerDelegate
    }

    private func detectLocationState() {
        // Verificar se Serviços de Localização estão ativados globalmente
        let globalEnabled = CLLocationManager.locationServicesEnabled()
        if !globalEnabled {
            locationStatus = .off
            syncToWidget(.location, isOn: false)
            return
        }

        // GPS global ligado - verificar permissão do app
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatus = .on
        case .denied:
            // GPS global ligado, mas app sem permissão - mostra como ligado (estado global)
            locationStatus = .on
        case .restricted:
            locationStatus = .restricted
        case .notDetermined:
            // GPS global ligado, permissão não solicitada ainda
            locationStatus = .on
        @unknown default:
            locationStatus = .on
        }
        syncToWidget(.location, isOn: locationStatus == .on)
    }

    // MARK: - Persistence

    private func loadSavedStates() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: wifiStateKey) != nil {
            wifiStatus = defaults.bool(forKey: wifiStateKey) ? .on : .off
        }
    }

    func saveState(for service: RadioServiceType, isOn: Bool) {
        let key: String
        switch service {
        case .wifi: key = wifiStateKey
        case .bluetooth: key = bluetoothStateKey
        case .location: key = locationStateKey
        }
        UserDefaults.standard.set(isOn, forKey: key)
        syncToWidget(service, isOn: isOn)
    }

    /// Sincroniza estado do serviço com o App Group para o Widget
    private func syncToWidget(_ service: RadioServiceType, isOn: Bool) {
        let key: String
        switch service {
        case .wifi: key = wifiStateKey
        case .bluetooth: key = bluetoothStateKey
        case .location: key = locationStateKey
        }
        if let groupDefaults = UserDefaults(suiteName: "group.com.icontrolit.shared") {
            groupDefaults.set(isOn, forKey: key)
        }
        // Pedir ao widget para atualizar
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Open Settings (Principal método de controle)

    /// Abre os Ajustes do iOS para o serviço especificado.
    ///
    /// Tenta settings-navigation:// primeiro, fallback para Shortcuts.
    func openSettings(for service: RadioServiceType) {
        guard let directURL = URL(string: service.settingsURLScheme) else { return }

        UIApplication.shared.open(directURL, options: [:]) { success in
            if !success {
                let storageKey = "shortcutName_\(service.rawValue)"
                let shortcutName = UserDefaults.standard.string(forKey: storageKey) ?? service.shortcutName
                self.openViaShortcut(name: shortcutName, fallbackURL: service.settingsURLScheme)
            }
        }
    }

    /// Abre uma URL de Ajustes via Apple Shortcuts
    func openViaShortcut(name: String, fallbackURL: String) {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let shortcutURL = "shortcuts://run-shortcut?name=\(encoded)"

        guard let url = URL(string: shortcutURL) else {
            openDirectURL(fallbackURL)
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    self.openDirectURL(fallbackURL)
                }
            }
        }
    }

    /// Abre URL diretamente (settings-navigation:// ou qualquer URL)
    func openDirectURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    /// Abre os Ajustes gerais como fallback final
    func openSettingsFallback() {
        DispatchQueue.main.async {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }

    /// Abre a página de Ajustes do app (para permissões de localização)
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Toggle Actions (via URL Schemes)

    func toggleService(_ service: RadioServiceType) {
        openSettings(for: service)
    }

    func toggleAllOff() {
        // Abrir Ajustes para cada serviço em sequência
        // Na prática, abrimos o primeiro e fornecemos instruções
        openSettings(for: .wifi)
    }

    func toggleAllOn() {
        openSettings(for: .wifi)
    }

    // MARK: - Location Permission (único controle real do app)

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Status Helpers

    func status(for service: RadioServiceType) -> ServiceStatus {
        switch service {
        case .wifi: return wifiStatus
        case .bluetooth: return bluetoothStatus
        case .location: return locationStatus
        }
    }

    func isOn(_ service: RadioServiceType) -> Bool {
        status(for: service) == .on
    }
}

// MARK: - CBCentralManagerDelegate

extension RadioControlService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async { [weak self] in
            switch central.state {
            case .poweredOn:
                self?.bluetoothStatus = .on
                self?.syncToWidget(.bluetooth, isOn: true)
            case .poweredOff:
                self?.bluetoothStatus = .off
                self?.syncToWidget(.bluetooth, isOn: false)
            case .unauthorized:
                self?.bluetoothStatus = .restricted
                self?.syncToWidget(.bluetooth, isOn: false)
            case .unsupported:
                self?.bluetoothStatus = .unsupported
                self?.syncToWidget(.bluetooth, isOn: false)
            default:
                self?.bluetoothStatus = .unknown
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension RadioControlService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.detectLocationState()
        }
    }
}

// MARK: - ServiceStatus

enum ServiceStatus: String, Codable {
    case on
    case off
    case unknown
    case restricted
    case unsupported

    var isActive: Bool {
        self == .on
    }

    var displayName: String {
        switch self {
        case .on: return String(localized: "On")
        case .off: return String(localized: "Off")
        case .unknown: return String(localized: "Unknown")
        case .restricted: return String(localized: "Restricted")
        case .unsupported: return String(localized: "Not supported")
        }
    }

    var icon: String {
        switch self {
        case .on: return "checkmark.circle.fill"
        case .off: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        case .restricted: return "lock.circle.fill"
        case .unsupported: return "exclamationmark.circle.fill"
        }
    }
}
