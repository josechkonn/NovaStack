import SwiftUI
import AppKit

public struct ServerCardView: View {
    public let name: String
    public let technology: String
    public let symbol: String
    public let gradient: LinearGradient
    public let isRunning: Bool
    public let port: Int
    public let pid: Int32?
    public let onToggle: () -> Void
    public let onRestart: () -> Void
    public let primaryActionTitle: String
    public let onPrimaryAction: () -> Void

    public init(
        name: String,
        technology: String,
        symbol: String,
        gradient: LinearGradient,
        isRunning: Bool,
        port: Int,
        pid: Int32?,
        onToggle: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        primaryActionTitle: String,
        onPrimaryAction: @escaping () -> Void
    ) {
        self.name = name
        self.technology = technology
        self.symbol = symbol
        self.gradient = gradient
        self.isRunning = isRunning
        self.port = port
        self.pid = pid
        self.onToggle = onToggle
        self.onRestart = onRestart
        self.primaryActionTitle = primaryActionTitle
        self.onPrimaryAction = onPrimaryAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Icon + Titles + Live Status Pill
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(gradient)
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)

                    Text(technology)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Compact Status Badge
                HStack(spacing: 6) {
                    StatusDot(isActive: isRunning)
                    Text(isRunning ? "En línea" : "Inactivo")
                        .font(.caption.weight(.medium))
                        .foregroundColor(isRunning ? NovaTheme.emeraldGreen : .secondary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill((isRunning ? NovaTheme.emeraldGreen : Color.secondary).opacity(0.08))
                )
            }

            // Metric & Quick Link Row (Compact, decluttered)
            HStack(spacing: 10) {
                // Port Badge
                HStack(spacing: 4) {
                    Text("Puerto")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(verbatim: "\(port)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(NovaTheme.glassFill)
                .cornerRadius(6)

                // PID Badge (Only if running)
                if let pid = pid, isRunning {
                    HStack(spacing: 4) {
                        Text("PID")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(verbatim: "\(pid)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(NovaTheme.glassFill)
                    .cornerRadius(6)
                }

                Spacer()

                // Direct Open Link
                Button(action: onPrimaryAction) {
                    HStack(spacing: 4) {
                        Text(primaryActionTitle)
                        Image(systemName: "arrow.up.forward")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .font(.caption.weight(.semibold))
                }
                .buttonStyle(.link)
                .disabled(!isRunning)
                .opacity(isRunning ? 1.0 : 0.4)
            }

            Divider()
                .opacity(0.4)

            // Bottom Controls (Actionable, clear hierarchy)
            HStack(spacing: 8) {
                if isRunning {
                    Button(action: onToggle) {
                        Label("Detener", systemImage: "stop.fill")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(NovaTheme.coralRed)
                    .controlSize(.regular)
                } else {
                    Button(action: onToggle) {
                        Label("Iniciar Servicio", systemImage: "play.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(NovaTheme.neonCyan)
                    .controlSize(.regular)
                }

                Button(action: onRestart) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .help("Reiniciar servicio")
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 12)
    }
}
