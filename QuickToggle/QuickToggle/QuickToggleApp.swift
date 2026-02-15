import SwiftUI
import SwiftData
import UserNotifications

@main
struct IControlItApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ToggleHistoryEntry.self,
            ServiceProfile.self,
            ScheduledAction.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Não foi possível criar ModelContainer: \(error)")
        }
    }()

    @AppStorage("shortcutsInstalled") private var shortcutsInstalled = false

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .sheet(isPresented: .init(
                    get: { !shortcutsInstalled },
                    set: { if !$0 { shortcutsInstalled = true } }
                )) {
                    ShortcutSetupView()
                        .interactiveDismissDisabled(false)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appDelegate.handlePendingToggleAction()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationService.shared.requestPermission()
        syncShortcutNamesToAppGroup()
        handlePendingToggleAction()
        return true
    }

    /// Sincroniza nomes dos shortcuts para o App Group (usado pelo Widget)
    private func syncShortcutNamesToAppGroup() {
        guard let groupDefaults = UserDefaults(suiteName: "group.com.icontrolit.shared") else { return }
        let standard = UserDefaults.standard
        for key in ["shortcutName_wifi", "shortcutName_bluetooth", "shortcutName_location", "shortcutName_safari"] {
            if let value = standard.string(forKey: key) {
                groupDefaults.set(value, forKey: key)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        handlePendingToggleAction()
    }

    /// Verifica se há ação pendente do Widget e redireciona aos Ajustes
    func handlePendingToggleAction() {
        guard let defaults = UserDefaults(suiteName: "group.com.icontrolit.shared"),
              let action = defaults.string(forKey: "pending_toggle_action"),
              let service = RadioServiceType(rawValue: action) else { return }

        // Limpar a ação pendente
        defaults.removeObject(forKey: "pending_toggle_action")

        // Pequeno delay para garantir que o app está visível
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            RadioControlService.shared.openSettings(for: service)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionID = response.notification.request.content.categoryIdentifier
        if actionID == "TOGGLE_REMINDER" {
            let serviceRaw = response.notification.request.content.userInfo["service"] as? String ?? ""
            if let service = RadioServiceType(rawValue: serviceRaw) {
                RadioControlService.shared.openSettings(for: service)
            }
        }
        completionHandler()
    }
}
