import Foundation
import SwiftUI
import SwiftData

/// ViewModel para gerenciamento de ações agendadas
@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published var showingNewSchedule = false
    @Published var showingEditSchedule = false
    @Published var editingSchedule: ScheduledAction?

    // Campos do formulário
    @Published var scheduleName = ""
    @Published var selectedService: RadioServiceType = .wifi
    @Published var selectedAction: ToggleAction = .off
    @Published var selectedTime = Date()
    @Published var selectedDays: Set<Int> = []

    let dayNames = [
        (1, "Dom"), (2, "Seg"), (3, "Ter"),
        (4, "Qua"), (5, "Qui"), (6, "Sex"), (7, "Sáb")
    ]

    // MARK: - Create

    func createSchedule(context: ModelContext) {
        guard !scheduleName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)

        let schedule = ScheduledAction(
            name: scheduleName,
            serviceType: selectedService,
            action: selectedAction,
            hour: hour,
            minute: minute,
            repeatDays: Array(selectedDays).sorted()
        )

        context.insert(schedule)
        try? context.save()

        // Agendar notificação
        NotificationService.shared.scheduleToggleReminder(
            id: schedule.notificationID,
            service: selectedService,
            action: selectedAction,
            hour: hour,
            minute: minute,
            repeatDays: Array(selectedDays).sorted()
        )

        resetForm()
    }

    // MARK: - Toggle Enable/Disable

    func toggleSchedule(_ schedule: ScheduledAction, context: ModelContext) {
        schedule.isEnabled.toggle()
        try? context.save()

        if schedule.isEnabled {
            // Reagendar
            if let service = schedule.service, let action = schedule.toggleAction {
                NotificationService.shared.scheduleToggleReminder(
                    id: schedule.notificationID,
                    service: service,
                    action: action,
                    hour: schedule.hour,
                    minute: schedule.minute,
                    repeatDays: schedule.repeatDays
                )
            }
        } else {
            // Cancelar
            NotificationService.shared.cancelNotification(id: schedule.notificationID)
        }
    }

    // MARK: - Edit

    func startEditing(_ schedule: ScheduledAction) {
        editingSchedule = schedule
        scheduleName = schedule.name
        selectedService = schedule.service ?? .wifi
        selectedAction = schedule.toggleAction ?? .off

        var components = DateComponents()
        components.hour = schedule.hour
        components.minute = schedule.minute
        selectedTime = Calendar.current.date(from: components) ?? Date()

        selectedDays = Set(schedule.repeatDays)
        showingEditSchedule = true
    }

    func updateSchedule(context: ModelContext) {
        guard let schedule = editingSchedule else { return }

        // Cancelar notificação anterior
        NotificationService.shared.cancelNotification(id: schedule.notificationID)

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)

        schedule.name = scheduleName
        schedule.serviceType = selectedService.rawValue
        schedule.action = selectedAction.rawValue
        schedule.hour = hour
        schedule.minute = minute
        schedule.repeatDays = Array(selectedDays).sorted()

        try? context.save()

        // Reagendar
        if schedule.isEnabled {
            NotificationService.shared.scheduleToggleReminder(
                id: schedule.notificationID,
                service: selectedService,
                action: selectedAction,
                hour: hour,
                minute: minute,
                repeatDays: Array(selectedDays).sorted()
            )
        }

        resetForm()
    }

    // MARK: - Delete

    func deleteSchedule(_ schedule: ScheduledAction, context: ModelContext) {
        NotificationService.shared.cancelNotification(id: schedule.notificationID)
        context.delete(schedule)
        try? context.save()
    }

    // MARK: - Quick Presets

    func createQuickPreset(_ preset: SchedulePreset, context: ModelContext) {
        scheduleName = preset.name
        selectedService = preset.service
        selectedAction = preset.action

        var components = DateComponents()
        components.hour = preset.hour
        components.minute = preset.minute
        selectedTime = Calendar.current.date(from: components) ?? Date()

        selectedDays = Set(preset.days)
        createSchedule(context: context)
    }

    // MARK: - Form

    func resetForm() {
        scheduleName = ""
        selectedService = .wifi
        selectedAction = .off
        selectedTime = Date()
        selectedDays = []
        editingSchedule = nil
        showingNewSchedule = false
        showingEditSchedule = false
    }

    func prepareNewSchedule() {
        resetForm()
        showingNewSchedule = true
    }

    func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    func selectWeekdays() {
        selectedDays = Set(ScheduledAction.weekdays)
    }

    func selectWeekends() {
        selectedDays = Set(ScheduledAction.weekends)
    }

    func selectAllDays() {
        selectedDays = Set(ScheduledAction.allDays)
    }
}

// MARK: - SchedulePreset

struct SchedulePreset: Identifiable {
    let id = UUID()
    let name: String
    let service: RadioServiceType
    let action: ToggleAction
    let hour: Int
    let minute: Int
    let days: [Int]

    static let presets: [SchedulePreset] = [
        SchedulePreset(
            name: "GPS à noite",
            service: .location,
            action: .off,
            hour: 23,
            minute: 0,
            days: ScheduledAction.allDays
        ),
        SchedulePreset(
            name: "Bluetooth no trabalho",
            service: .bluetooth,
            action: .off,
            hour: 9,
            minute: 0,
            days: ScheduledAction.weekdays
        ),
        SchedulePreset(
            name: "Wi-Fi ao dormir",
            service: .wifi,
            action: .off,
            hour: 23,
            minute: 30,
            days: ScheduledAction.allDays
        ),
        SchedulePreset(
            name: "Tudo ligado de manhã",
            service: .wifi,
            action: .on,
            hour: 7,
            minute: 0,
            days: ScheduledAction.weekdays
        )
    ]
}
