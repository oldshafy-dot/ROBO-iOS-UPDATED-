import SwiftUI
import CryptoKit
import Security

private enum CalculatorPINStore {
    private static let service = "ROBO.iOS.Calculator"
    private static let account = "calculator-pin"
    private static let installMarker = "robo.calculator.install.marker"

    static func prepareForInstall() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: installMarker) {
            delete()
            defaults.set(true, forKey: installMarker)
        }
    }

    static var hasPIN: Bool {
        read() != nil
    }

    static func save(pin: String) -> Bool {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else { return false }
        let salt = SymmetricKey(size: .bits256)
        let saltData = salt.withUnsafeBytes { Data($0) }
        let digest = SHA256.hash(data: saltData + Data(pin.utf8))
        let payload = saltData + Data(digest)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: payload,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    static func matches(pin: String) -> Bool {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }),
              let payload = read(), payload.count == 64 else { return false }
        let salt = payload.prefix(32)
        let expected = payload.suffix(32)
        let actual = SHA256.hash(data: salt + Data(pin.utf8))
        return Data(actual) == expected
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    private static func read() -> Data? {
        let query: [String: Any] = [
            kSecClass as String,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }
}

struct CalculatorView: View {
    @EnvironmentObject private var licenseSession: LicenseSessionController
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppTheme.accentStorageKey) private var accentHex = AppTheme.defaultAccentHex

    @State private var display = "0"
    @State private var storedValue: Double?
    @State private var operation: Operation?
    @State private var waitingForOperand = false

    enum Operation {
        case add, subtract, multiply, divide
    }

    private var accent: Color { Color(hex: accentHex) }

    var body: some View {
        ZStack {
            AppTheme.pageBackground.ignoresSafeArea()
            FallingStarsBackground()

            VStack(spacing: 14) {
                HStack {
                    Text("Calculator")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accent)
                }

                Spacer(minLength: 10)

                HStack {
                    Spacer()
                    Text(display)
                        .font(.system(size: 54, weight: .light, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.35)
                }
                .padding(.horizontal, 8)

                keypad
            }
            .padding(20)
        }
        .onAppear {
            CalculatorPINStore.prepareForInstall()
        }
    }

    private var keypad: some View {
        let rows = [
            ["AC", "±", "%", "÷"],
            ["7", "8", "9", "×"],
            ["4", "5", "6", "−"],
            ["1", "2", "3", "+"],
            ["0", ".", "="]
        ]

        return VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        calculatorKey(key, wide: index == 4 && key == "0")
                    }
                }
            }
        }
    }

    private func calculatorKey(_ key: String, wide: Bool = false) -> some View {
        Button {
            press(key)
        } label: {
            Text(key)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(key == "=" ? .white : AppTheme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    key == "=" ? accent : Color.white.opacity(key == "AC" || key == "±" || key == "%" ? 0.13 : 0.07),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func press(_ key: String) {
        switch key {
        case "0"..."9":
            if waitingForOperand || display == "0" {
                display = key
                waitingForOperand = false
            } else if display.count < 15 {
                display.append(key)
            }

        case ".":
            if waitingForOperand {
                display = "0."
                waitingForOperand = false
            } else if !display.contains(".") {
                display.append(".")
            }

        case "AC":
            display = "0"
            storedValue = nil
            operation = nil
            waitingForOperand = false

        case "±":
            if let value = Double(display) {
                display = format(-value)
            }

        case "%":
            if let value = Double(display) {
                display = format(value / 100)
            }

        case "+", "−", "×", "÷":
            guard let value = Double(display) else { return }
            storedValue = value
            operation = key == "+" ? .add : key == "−" ? .subtract : key == "×" ? .multiply : .divide
            waitingForOperand = true

        case "=":
            Task { await evaluateAndCheckPIN() }

        default:
            break
        }
    }

    private func evaluateAndCheckPIN() async {
        let candidate = display
        let isFourDigitPIN = candidate.count == 4 && candidate.allSatisfy({ $0.isNumber })

        if isFourDigitPIN, CalculatorPINStore.hasPIN, CalculatorPINStore.matches(pin: candidate) {
            await licenseSession.renewAuthorityIfNeeded()
            if licenseSession.hasLiveAuthority {
                await MainActor.run {
                    dismiss()
                }
                return
            }
        }

        await MainActor.run {
            calculate()
        }
    }

    private func calculate() {
        guard let lhs = storedValue,
              let rhs = Double(display),
              let operation else {
            if let value = Double(display) {
                display = format(value)
            }
            waitingForOperand = true
            return
        }

        let result: Double
        switch operation {
        case .add: result = lhs + rhs
        case .subtract: result = lhs - rhs
        case .multiply: result = lhs * rhs
        case .divide:
            guard rhs != 0 else {
                display = "Error"
                storedValue = nil
                self.operation = nil
                waitingForOperand = true
                return
            }
            result = lhs / rhs
        }

        display = format(result)
        storedValue = nil
        self.operation = nil
        waitingForOperand = true
    }

    private func format(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.10g", value)
    }
}

struct CalculatorSettingsSection: View {
    @Binding var enabled: Bool
    @EnvironmentObject private var licenseSession: LicenseSessionController
    @State private var showPINSheet = false
    @State private var showChangePIN = false
    @State private var showCalculator = false
    @State private var oldPIN = ""
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "calculator.fill")
                    .foregroundStyle(AppTheme.accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Calculator Mode")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(enabled ? "Enabled" : "Disabled")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { enabled },
                    set: { newValue in
                        if newValue {
                            showPINSheet = true
                        } else {
                            enabled = false
                        }
                    }
                ))
                .labelsHidden()
                .tint(AppTheme.accent)
            }

            if enabled {
                HStack(spacing: 10) {
                    Button("Open Calculator") { showCalculator = true }
                    Spacer()
                    Menu {
                        Button("Change PIN") { showChangePIN = true }
                        Button("Disable Calculator Mode") { enabled = false }
                        Button("Forget PIN", role: .destructive) {
                            CalculatorPINStore.delete()
                            enabled = false
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.07), in: Circle())
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
            }
        }
        .sheet(isPresented: $showPINSheet) {
            CalculatorPINSetupView(title: "Set Calculator PIN") { pin in
                let saved = CalculatorPINStore.save(pin: pin)
                if saved {
                    enabled = true
                    showPINSheet = false
                } else {
                    message = "Could not save the PIN."
                }
            }
        }
        .sheet(isPresented: $showChangePIN) {
            CalculatorPINSetupView(title: "Change Calculator PIN", requireCurrentPIN: true) { pin in
                let saved = CalculatorPINStore.save(pin: pin)
                if saved {
                    showChangePIN = false
                } else {
                    message = "Could not save the PIN."
                }
            }
        }
        .sheet(isPresented: $showCalculator) {
            CalculatorView()
                .environmentObject(licenseSession)
        }
        .alert("Calculator Mode", isPresented: Binding(
            get: { message != nil },
            set: { if !$0 { message = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message ?? "")
        }
        .onAppear {
            CalculatorPINStore.prepareForInstall()
            enabled = CalculatorPINStore.hasPIN && enabled
        }
    }
}

private struct CalculatorPINSetupView: View {
    let title: String
    let requireCurrentPIN: Bool
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var current = ""
    @State private var pin = ""
    @State private var confirm = ""
    @State private var error: String?

    init(title: String, requireCurrentPIN: Bool = false, onSave: @escaping (String) -> Void) {
        self.title = title
        self.requireCurrentPIN = requireCurrentPIN
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                if requireCurrentPIN {
                    Section("Current PIN") {
                        SecureField("4 digits", text: $current)
                            .keyboardType(.numberPad)
                    }
                }
                Section("New PIN") {
                    SecureField("4 digits", text: $pin)
                        .keyboardType(.numberPad)
                    SecureField("Confirm PIN", text: $confirm)
                        .keyboardType(.numberPad)
                }
                if let error {
                    Text(error)
                        .foregroundStyle(.red)
                }
                Button("Save") {
                    guard (!requireCurrentPIN || CalculatorPINStore.matches(pin: current)) else {
                        error = "Incorrect current PIN."
                        return
                    }
                    guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
                        error = "PIN must be exactly 4 digits."
                        return
                    }
                    guard pin == confirm else {
                        error = "PINs do not match."
                        return
                    }
                    onSave(pin)
                    dismiss()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
