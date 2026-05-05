import SwiftUI

@main
struct CaffeineApp: App {
    @StateObject private var manager = CaffeineManager()

    var body: some Scene {
        MenuBarExtra {
            if manager.isActive {
                Section(manager.isPaused ? "Paused" : "Active") {
                    if manager.isIndefinite {
                        Text(manager.isPaused ? "Paused (indefinite)" : "Running indefinitely")
                    } else {
                        Text("\(manager.formattedTimeRemaining) remaining")
                    }
                }
                Button(manager.isPaused ? "Resume" : "Pause") {
                    if manager.isPaused {
                        manager.resume()
                    } else {
                        manager.pause()
                    }
                }
                Button("Deactivate") {
                    manager.deactivate()
                }
            } else {
                Section("Keep Awake For") {
                    ForEach(CaffeineDuration.allCases) { duration in
                        Button(duration.rawValue) {
                            manager.activate(duration: duration)
                        }
                    }
                }
            }

            Divider()

            Button("Quit") {
                manager.deactivate()
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            HStack(spacing: 4) {
                Image(systemName: manager.isActive ? (manager.isPaused ? "pause.circle" : "cup.and.saucer.fill") : "cup.and.saucer")
                if manager.isActive && !manager.isPaused {
                    Text(manager.isIndefinite ? "∞" : manager.formattedTimeRemaining)
                        .monospacedDigit()
                }
            }
        }
    }
}
