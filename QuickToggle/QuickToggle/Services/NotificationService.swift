import Foundation
import UserNotifications

/// Serviço para gerenciar notificações locais e lembretes agendados
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    private init() {
        checkPermission()
    }

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
        }
        registerCategories()
    }

    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Categories

    private func registerCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_SETTINGS",
            title: "Abrir Ajustes",
            options: .foreground
        )
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dispensar",
            options: .destructive
        )

        let toggleCategory = UNNotificationCategory(
            identifier: "TOGGLE_REMINDER",
            actions: [openAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([toggleCategory])
    }

    // MARK: - Schedule Notifications

    /// Agenda uma notificação para lembrar o usuário de alterar um serviço
    func scheduleToggleReminder(
        id: String,
        service: RadioServiceType,
        action: ToggleAction,
        hour: Int,
        minute: Int,
        repeatDays: [Int] = []
    ) {
        let content = UNMutableNotificationContent()

        let actionText = action == .on ? "ligar" : "desligar"
        content.title = "QuickToggle"
        content.body = "Hora de \(actionText) \(service.displayName)"
        content.sound = .default
        content.categoryIdentifier = "TOGGLE_REMINDER"
        content.userInfo = [
            "service": service.rawValue,
            "action": action.rawValue
        ]

        if repeatDays.isEmpty {
            // Notificação única
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        } else {
            // Notificação repetida para cada dia
            for day in repeatDays {
                var dateComponents = DateComponents()
                dateComponents.weekday = day
                dateComponents.hour = hour
                dateComponents.minute = minute

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents,
                    repeats: true
                )

                let dayID = "\(id)_day\(day)"
                let request = UNNotificationRequest(
                    identifier: dayID,
                    content: content,
                    trigger: trigger
                )

                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    /// Remove notificações agendadas
    func cancelNotification(id: String) {
        // Cancelar a notificação principal e todas as variantes por dia
        var ids = [id]
        for day in 1...7 {
            ids.append("\(id)_day\(day)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Remove todas as notificações do app
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Quick Notification

    /// Envia uma notificação imediata (para feedback)
    func sendQuickNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
