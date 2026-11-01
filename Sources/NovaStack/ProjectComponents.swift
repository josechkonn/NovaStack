import SwiftUI
import AppKit

// MARK: - Project Grid Card (Clean Glass Style)
public struct ProjectGridCardView: View {
    public let project: ServerManager.ProjectItem
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onOpenBrowser: () -> Void
    public let onOpenFinder: () -> Void
    public let onCopyURL: () -> Void
    public let onCopyPath: () -> Void

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Top Row: Project Type Badge + Context Menu
                HStack(alignment: .center) {
                    NovaBadge(
                        project.type.rawValue,
                        icon: project.type.icon,
                        color: project.type.tintColor
                    )

                    Spacer()

                    Menu {
                        Button(action: onOpenBrowser) {
                            Label("Abrir en Safari", systemImage: "safari")
                        }
                        Button(action: onOpenFinder) {
                            Label("Mostrar en Finder", systemImage: "folder")
                        }
                        Divider()
                        Button(action: onCopyURL) {
                            Label("Copiar URL Local", systemImage: "link")
                        }
                        Button(action: onCopyPath) {
                            Label("Copiar Ruta en Disco", systemImage: "doc.on.doc")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(NovaTheme.textSecondary)
                            .frame(width: 22, height: 22)
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 22, height: 22)
                }

                // Project Title & URL
                VStack(alignment: .leading, spacing: 3) {
                    Text(project.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(NovaTheme.textPrimary)
                        .lineLimit(1)

                    Text(project.url.host != nil ? "localhost/\(project.name)" : project.name)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(NovaTheme.textSecondary)
                        .lineLimit(1)
                }

                Divider()
                    .overlay(NovaTheme.glassBorder)

                // Quick Action Buttons
                HStack(spacing: 8) {
                    Button(action: onOpenBrowser) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.forward")
                                .font(.system(size: 9, weight: .bold))
                            Text("Abrir")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [NovaTheme.neonCyan, NovaTheme.electricIndigo], startPoint: .leading, endPoint: .trailing))
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: onOpenFinder) {
                        Image(systemName: "folder")
                            .font(.system(size: 11))
                            .foregroundColor(NovaTheme.textSecondary)
                            .frame(width: 26, height: 26)
                            .background(NovaTheme.glassFill)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Mostrar en Finder")

                    Button(action: onCopyURL) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(NovaTheme.textSecondary)
                            .frame(width: 26, height: 26)
                            .background(NovaTheme.glassFill)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Copiar URL")
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? NovaTheme.glassSelected : NovaTheme.glassFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? NovaTheme.neonCyan : NovaTheme.glassBorder,
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: onOpenBrowser) {
                Label("Abrir en Safari", systemImage: "safari")
            }
            Button(action: onOpenFinder) {
                Label("Mostrar en Finder", systemImage: "folder")
            }
            Divider()
            Button(action: onCopyURL) {
                Label("Copiar URL", systemImage: "link")
            }
            Button(action: onCopyPath) {
                Label("Copiar Ruta en Disco", systemImage: "doc.on.doc")
            }
        }
    }
}

// MARK: - Project List Row
public struct ProjectListRowView: View {
    public let project: ServerManager.ProjectItem
    public let isSelected: Bool
    public let onOpenBrowser: () -> Void
    public let onOpenFinder: () -> Void
    public let onCopyURL: () -> Void
    public let onCopyPath: () -> Void

    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(project.type.tintColor.opacity(0.18))
                    .frame(width: 30, height: 30)
                Image(systemName: project.type.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(project.type.tintColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(project.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(NovaTheme.textPrimary)

                    NovaBadge(project.type.rawValue, color: project.type.tintColor)
                }

                Text("localhost/\(project.name)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(NovaTheme.textSecondary)
            }

            Spacer()

            Button(action: onOpenBrowser) {
                Text("Abrir")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(NovaTheme.glassFill)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(NovaTheme.glassBorder, lineWidth: 0.5))
            }
            .buttonStyle(.plain)

            Button(action: onOpenFinder) {
                Image(systemName: "folder")
                    .font(.system(size: 12))
                    .foregroundColor(NovaTheme.textSecondary)
            }
            .buttonStyle(.borderless)
            .help("Mostrar en Finder")

            Button(action: onCopyURL) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundColor(NovaTheme.textSecondary)
            }
            .buttonStyle(.borderless)
            .help("Copiar URL")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? NovaTheme.glassSelected : Color.clear)
        )
    }
}
