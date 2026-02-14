# QuickToggle

Aplicativo iOS para controle rápido de Wi-Fi, Bluetooth e Serviços de Localização com o mínimo de toques possível.

## Funcionalidades

### Controles Principais
- **Wi-Fi**: Redireciona diretamente aos Ajustes de Wi-Fi (1 toque)
- **Bluetooth**: Redireciona diretamente aos Ajustes de Bluetooth (1 toque)
- **Localização/GPS**: Redireciona diretamente a Privacidade > Localização (1 toque)
- **Desligar Tudo**: Botão para acessar rapidamente os ajustes de todos os serviços
- **Ligar Tudo**: Botão para religar todos os serviços

### Atalhos para Ajustes (URL Schemes)
O app abre a **seção exata** dos Ajustes do iOS para cada serviço:
- Wi-Fi: `App-prefs:WIFI`
- Bluetooth: `App-prefs:Bluetooth`
- Localização: `App-prefs:Privacy&path=LOCATION`
- Ajustes gerais: Fallback via `UIApplication.openSettingsURLString`

### Agendamento por Horário
- Agendar lembretes para ligar/desligar serviços em horários específicos
- Repetição por dias da semana (dias úteis, fim de semana, todos os dias)
- Presets rápidos: "GPS à noite", "Bluetooth no trabalho", etc.
- Notificações com ação direta para abrir Ajustes

### Economia de Bateria
- Monitoramento de nível de bateria em tempo real
- Estimativa de economia ao desligar cada serviço (mAh/hora, %/hora)
- Sugestão automática quando bateria está baixa (< 30%)
- Detecção de Modo Economia de Energia do iOS
- Dicas de economia de bateria

### Perfis/Presets
- **Avião Plus**: Desliga Wi-Fi + Bluetooth + GPS
- **Privacidade**: Desliga GPS + Wi-Fi, mantém Bluetooth
- **Economia**: Desliga Bluetooth + GPS, mantém Wi-Fi
- **Tudo Ligado**: Liga todos os serviços
- Perfis customizáveis pelo usuário
- Seletor de ícones para cada perfil

### Siri e Atalhos (App Intents)
Comandos de voz disponíveis:
- "Hey Siri, Desligar Tudo no QuickToggle"
- "Hey Siri, Ligar Tudo no QuickToggle"
- "Hey Siri, Alternar Wi-Fi no QuickToggle"
- "Hey Siri, Alternar Bluetooth no QuickToggle"
- "Hey Siri, Alternar Localização no QuickToggle"
- "Hey Siri, Modo Privacidade no QuickToggle"
- "Hey Siri, Economia de Bateria no QuickToggle"

### Widget (WidgetKit)
- **Widget Pequeno**: Indicadores de estado dos 3 serviços
- **Widget Médio**: 3 botões interativos lado a lado (iOS 17+)
- **Widget Grande**: Lista detalhada com impacto na bateria
- **Lock Screen Circular**: Contador de serviços ativos
- **Lock Screen Retangular**: Status resumido

### Control Center (iOS 18+)
- Controles customizados para Wi-Fi, Bluetooth e GPS no Control Center

### Histórico
- Registro de todas as ações (ligar/desligar)
- Filtro por serviço
- Agrupamento por data
- Estatísticas (total ligados, desligados)
- Fonte da ação (manual, perfil, agendado, atalho, widget)

### Interface
- Design minimalista estilo iOS nativo
- Suporte completo a Dark Mode
- Glassmorphism e SF Symbols
- Haptic feedback nos toggles
- Animações suaves (spring)
- VoiceOver e Dynamic Type (Acessibilidade)
- Português (Brasil) como idioma primário

## Requisitos
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Configuração do Projeto no Xcode

### 1. Criar o projeto
1. Abra o Xcode
2. **File > New > Project**
3. Selecione **App** (iOS)
4. Configure:
   - Product Name: `QuickToggle`
   - Team: Seu time de desenvolvimento
   - Organization Identifier: `com.quicktoggle`
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: **Swift**
5. Salve em `/Users/Ale/ControltAll/QuickToggle/`

### 2. Adicionar os arquivos
1. No Xcode, arraste todas as pastas de código para o projeto:
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Services/`
   - `Intents/`
   - `Extensions/`
2. Substitua `QuickToggleApp.swift` e `ContentView.swift` pelos fornecidos

### 3. Adicionar Widget Extension
1. **File > New > Target**
2. Selecione **Widget Extension**
3. Product Name: `QuickToggleWidget`
4. Desmarque "Include Configuration App Intent"
5. Copie os arquivos de `QuickToggleWidget/` para o target

### 4. Configurar App Group
1. Selecione o target **QuickToggle**
2. **Signing & Capabilities > + Capability > App Groups**
3. Adicione: `group.com.quicktoggle.shared`
4. Repita para o target **QuickToggleWidget**

### 5. Configurar Capabilities
No target principal, adicione:
- **App Groups**: `group.com.quicktoggle.shared`
- **Background Modes**: Background fetch (opcional)

### 6. Info.plist
O `Info.plist` já inclui:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- `NSBluetoothAlwaysUsageDescription`
- `NSLocalNetworkUsageDescription`
- `LSApplicationQueriesSchemes`: prefs, App-prefs, shortcuts

### 7. Build e Run
1. Selecione um dispositivo iOS ou simulador (iOS 17+)
2. **Cmd + R** para compilar e executar

## Arquitetura

```
QuickToggle/
├── QuickToggleApp.swift          # Entry point + AppDelegate
├── ContentView.swift             # TabView principal
├── Models/
│   ├── RadioServiceType.swift    # Enum dos serviços (Wi-Fi, BT, GPS)
│   ├── ServiceProfile.swift      # Perfis (SwiftData)
│   ├── ToggleHistoryEntry.swift  # Histórico (SwiftData)
│   └── ScheduledAction.swift     # Ações agendadas (SwiftData)
├── ViewModels/
│   ├── ToggleViewModel.swift     # VM principal
│   ├── ProfileViewModel.swift    # VM de perfis
│   └── ScheduleViewModel.swift   # VM de agendamento
├── Views/
│   ├── MainToggleView.swift      # Tela principal
│   ├── Components/
│   │   └── ToggleCardView.swift  # Card de toggle
│   ├── ProfilesView.swift        # Tela de perfis
│   ├── ScheduleView.swift        # Tela de agendamento
│   ├── HistoryView.swift         # Tela de histórico
│   ├── SettingsView.swift        # Tela de ajustes
│   └── BatterySavingView.swift   # Economia de bateria
├── Services/
│   ├── RadioControlService.swift # Serviço de controle dos rádios
│   ├── NotificationService.swift # Notificações locais
│   └── BatteryMonitorService.swift # Monitor de bateria
├── Intents/
│   ├── ToggleIntents.swift       # App Intents para Siri/Atalhos
│   └── ControlCenterWidgets.swift # Widgets do Control Center (iOS 18+)
└── Extensions/
    └── Color+Extensions.swift    # Extensões visuais

QuickToggleWidget/
├── QuickToggleWidget.swift       # Widget principal
└── QuickToggleWidgetBundle.swift  # Bundle do widget
```

## Limitações Conhecidas do iOS

### Wi-Fi
- **Limitação**: Apps de terceiros NÃO podem desligar Wi-Fi diretamente
- **API disponível**: `NEHotspotConfiguration` (apenas configura redes específicas)
- **Solução**: Redirecionamento ao painel `App-prefs:WIFI`

### Bluetooth
- **Limitação**: `CoreBluetooth` permite detectar estado, mas não controlar globalmente
- **API disponível**: `CBCentralManager` (apenas detecção de estado)
- **Solução**: Redirecionamento ao painel `App-prefs:Bluetooth`

### Localização/GPS
- **Limitação**: `CLLocationManager` controla apenas permissão do próprio app
- **API disponível**: Apenas permissões por app, não controle global
- **Solução**: Redirecionamento a `App-prefs:Privacy&path=LOCATION`

### URL Schemes (App-prefs:)
- **Risco**: Apple pode restringir `App-prefs:` a qualquer momento
- **Fallback**: Se não funcionar, abre `UIApplication.openSettingsURLString`
- **App Store**: É uma área cinza — pode ser aceito ou rejeitado na revisão

### Controle Real
Para controle verdadeiramente direto, as alternativas são:
1. **MDM (Mobile Device Management)** — Apenas enterprise
2. **Guided Access** — Cenários controlados
3. **Jailbreak** — Fora do escopo (não recomendado)

## Considerações de App Store

- Nenhuma API privada é utilizada
- Todos os frameworks são públicos: CoreBluetooth, CoreLocation, WidgetKit, AppIntents
- O uso de `App-prefs:` é documentado como URL Scheme (área cinza)
- As permissões são justificadas com descrições claras
- O app segue as App Store Review Guidelines
- Se `App-prefs:` for rejeitado, o fallback abre os Ajustes gerais

## Tecnologias

| Tecnologia | Uso |
|---|---|
| SwiftUI | Interface do usuário |
| SwiftData | Persistência (histórico, perfis, agendamentos) |
| CoreBluetooth | Detecção de estado do Bluetooth |
| CoreLocation | Detecção de estado da Localização |
| NetworkExtension | Detecção de rede Wi-Fi |
| WidgetKit | Widgets de tela inicial e Lock Screen |
| AppIntents | Integração com Siri e Atalhos |
| UserNotifications | Notificações agendadas |
| UIKit | Haptic feedback, bateria, URL handling |

## Licença

Projeto pessoal. Todos os direitos reservados.
