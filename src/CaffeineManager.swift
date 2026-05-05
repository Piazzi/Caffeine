import Foundation
import IOKit.pwr_mgt

enum CaffeineDuration: String, CaseIterable, Identifiable {
    case thirtyMinutes = "30 Minutes"
    case oneHour = "1 Hour"
    case twoHours = "2 Hours"
    case fourHours = "4 Hours"
    case eightHours = "8 Hours"
    case indefinitely = "Indefinitely"

    var id: String { rawValue }

    var seconds: Int? {
        switch self {
        case .thirtyMinutes: return 30 * 60
        case .oneHour: return 60 * 60
        case .twoHours: return 2 * 60 * 60
        case .fourHours: return 4 * 60 * 60
        case .eightHours: return 8 * 60 * 60
        case .indefinitely: return nil
        }
    }
}

@MainActor
final class CaffeineManager: ObservableObject {
    @Published var isActive = false
    @Published var isPaused = false
    @Published var remainingSeconds: Int = 0
    @Published var isIndefinite = false

    private var assertionID: IOPMAssertionID = 0
    private var timer: Timer?

    var formattedTimeRemaining: String {
        if isIndefinite { return "∞" }
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    func activate(duration: CaffeineDuration) {
        deactivate()

        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Caffeine: keeping screen awake" as CFString,
            &assertionID
        )

        guard result == kIOReturnSuccess else { return }

        isActive = true

        if let seconds = duration.seconds {
            isIndefinite = false
            remainingSeconds = seconds
            startTimer()
        } else {
            isIndefinite = true
            remainingSeconds = 0
        }
    }

    func pause() {
        guard isActive, !isPaused else { return }
        isPaused = true
        timer?.invalidate()
        timer = nil
        IOPMAssertionRelease(assertionID)
        assertionID = 0
    }

    func resume() {
        guard isActive, isPaused else { return }

        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Caffeine: keeping screen awake" as CFString,
            &assertionID
        )
        guard result == kIOReturnSuccess else { return }

        isPaused = false
        if !isIndefinite {
            startTimer()
        }
    }

    func deactivate() {
        if isActive && !isPaused {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        timer?.invalidate()
        timer = nil
        isActive = false
        isPaused = false
        isIndefinite = false
        remainingSeconds = 0
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.deactivate()
                }
            }
        }
    }
}
