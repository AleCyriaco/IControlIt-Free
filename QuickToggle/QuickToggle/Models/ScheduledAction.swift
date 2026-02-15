import Foundation
import SwiftData

@Model
final class ScheduledAction {
    var id: UUID
    var name: String
    var serviceType: String // RadioServiceType.rawValue
    var action: String // ToggleAction.rawValue
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var repeatDays: [Int] // 1=Dom, 2=Seg, ... 7=Sáb
    var createdAt: Date
    var notificationID: String

    init(
        name: String,
        serviceType: RadioServiceType,
        action: ToggleAction,
        hour: Int,
        minute: Int,
        repeatDays: [Int] = [],
        isEnabled: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.serviceType = serviceType.rawValue
        self.action = action.rawValue
        self.hour = hour
        self.minute = minute
        self.repeatDays = repeatDays
        self.isEnabled = isEnabled
        self.createdAt = Date()
        self.notificationID = "schedule_\(UUID().uuidString)"
    }

    var service: RadioServiceType? {
        RadioServiceType(rawValue: serviceType)
    }

    var toggleAction: ToggleAction? {
        ToggleAction(rawValue: action)
    }

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var repeatDaysString: String {
        if repeatDays.isEmpty { return String(localized: "Uma vez") }
        if repeatDays.count == 7 { return String(localized: "Todos os dias") }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.shortWeekdaySymbols ?? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        // Calendar weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
        let sorted = repeatDays.sorted()
        return sorted.compactMap { $0 >= 1 && $0 <= 7 ? symbols[$0 - 1] : nil }.joined(separator: ", ")
    }

    static var weekdays: [Int] { [2, 3, 4, 5, 6] }
    static var weekends: [Int] { [1, 7] }
    static var allDays: [Int] { [1, 2, 3, 4, 5, 6, 7] }
}
