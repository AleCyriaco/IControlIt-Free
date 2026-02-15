import SwiftUI
import SwiftData

/// Tela de agendamento de ações em horários determinados
struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScheduledAction.hour) private var schedules: [ScheduledAction]

    var body: some View {
        NavigationStack {
            List {
                // Presets rápidos
                if schedules.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)

                            Text("Nenhuma ação agendada")
                                .font(.headline)

                            Text("Agende horários para ligar ou desligar serviços automaticamente.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                }

                // Sugestões rápidas
                Section("Sugestões") {
                    ForEach(SchedulePreset.presets) { preset in
                        Button {
                            viewModel.createQuickPreset(preset, context: modelContext)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: preset.service.icon)
                                    .foregroundStyle(preset.service.activeColor)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preset.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text("\(preset.action == .on ? String(localized: "Ligar") : String(localized: "Desligar")) \(preset.service.displayName) \(String(format: "%02d:%02d", preset.hour, preset.minute))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                // Agendamentos ativos
                if !schedules.isEmpty {
                    Section("Agendamentos") {
                        ForEach(schedules) { schedule in
                            ScheduleRow(
                                schedule: schedule,
                                onToggle: {
                                    viewModel.toggleSchedule(schedule, context: modelContext)
                                },
                                onEdit: {
                                    viewModel.startEditing(schedule)
                                }
                            )
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteSchedule(schedules[index], context: modelContext)
                            }
                        }
                    }
                }

                // Informação
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(.orange)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Como funciona")
                                .font(.subheadline.weight(.semibold))
                            Text("No horário agendado, você receberá uma notificação com atalho para abrir os Ajustes e alterar o serviço. Também é possível criar automações no app Atalhos para mais controle.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Agenda")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.prepareNewSchedule()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewSchedule) {
                ScheduleFormSheet(viewModel: viewModel, isEditing: false)
            }
            .sheet(isPresented: $viewModel.showingEditSchedule) {
                ScheduleFormSheet(viewModel: viewModel, isEditing: true)
            }
        }
    }
}

// MARK: - Schedule Row

struct ScheduleRow: View {
    let schedule: ScheduledAction
    let onToggle: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Ícone do serviço
            if let service = schedule.service {
                Image(systemName: service.icon)
                    .foregroundStyle(schedule.isEnabled ? service.activeColor : .gray)
                    .frame(width: 30)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(schedule.isEnabled ? .primary : .secondary)

                HStack(spacing: 8) {
                    Text(schedule.timeString)
                        .font(.title3.weight(.semibold).monospacedDigit())
                        .foregroundStyle(schedule.isEnabled ? .primary : .secondary)

                    Text(schedule.toggleAction?.displayName ?? "")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            schedule.toggleAction == .on
                                ? Color.green.opacity(0.15)
                                : Color.red.opacity(0.15),
                            in: Capsule()
                        )
                        .foregroundStyle(schedule.toggleAction == .on ? .green : .red)
                }

                Text(schedule.repeatDaysString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Toggle ativar/desativar
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { onEdit() }
        .accessibilityLabel("\(schedule.name), \(schedule.timeString), \(schedule.isEnabled ? "ativo" : "inativo")")
    }
}

// MARK: - Schedule Form Sheet

struct ScheduleFormSheet: View {
    @ObservedObject var viewModel: ScheduleViewModel
    let isEditing: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Detalhes") {
                    TextField("Nome", text: $viewModel.scheduleName)

                    Picker("Serviço", selection: $viewModel.selectedService) {
                        ForEach(RadioServiceType.allCases) { service in
                            Label(service.displayName, systemImage: service.icon)
                                .tag(service)
                        }
                    }

                    Picker("Ação", selection: $viewModel.selectedAction) {
                        Text("Desligar").tag(ToggleAction.off)
                        Text("Ligar").tag(ToggleAction.on)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Horário") {
                    DatePicker(
                        "Hora",
                        selection: $viewModel.selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                }

                Section("Repetir") {
                    // Botões de preset
                    HStack(spacing: 8) {
                        quickDayButton("Dias úteis") { viewModel.selectWeekdays() }
                        quickDayButton("Fim de semana") { viewModel.selectWeekends() }
                        quickDayButton("Todos") { viewModel.selectAllDays() }
                    }

                    // Dias individuais
                    HStack(spacing: 6) {
                        ForEach(viewModel.dayNames, id: \.0) { day in
                            Button {
                                viewModel.toggleDay(day.0)
                            } label: {
                                Text(day.1)
                                    .font(.caption2.weight(.medium))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        viewModel.selectedDays.contains(day.0)
                                            ? Color.blue
                                            : Color.gray.opacity(0.15),
                                        in: Circle()
                                    )
                                    .foregroundStyle(
                                        viewModel.selectedDays.contains(day.0)
                                            ? .white
                                            : .primary
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(isEditing ? "Editar" : "Novo Agendamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { viewModel.resetForm() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if isEditing {
                            viewModel.updateSchedule(context: modelContext)
                        } else {
                            viewModel.createSchedule(context: modelContext)
                        }
                    }
                    .disabled(viewModel.scheduleName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func quickDayButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title) { action() }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.1), in: Capsule())
            .foregroundStyle(.blue)
    }
}

#Preview {
    ScheduleView()
}
