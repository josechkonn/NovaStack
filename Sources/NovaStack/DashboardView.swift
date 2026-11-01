import SwiftUI
import AppKit

public struct DashboardView: View {
    @ObservedObject var manager = ServerManager.shared
    @State private var selectedTab: NavigationSection = .servers
    @State private var projectSearchText: String = ""
    @State private var isGridView: Bool = true
    @State private var isRestarting: Bool = false

    public enum NavigationSection: String, CaseIterable, Identifiable {
        case servers = "Servidores"
        case projects = "Proyectos Web"
        case logs = "Registros"
        case settings = "Configuración"

        public var id: String { rawValue }

        public var icon: String {
            switch self {
            case .servers: return "server.rack"
            case .projects: return "macwindow.on.rectangle"
            case .logs: return "terminal"
            case .settings: return "gearshape"
            }
        }
    }

    public var body: some View {
        ZStack {
            // Full-Bleed Cosmic Canvas
            CosmicCanvasBackground()

            HStack(spacing: 0) {
                // Bespoke Glass Navigation Rail (CleanMyMac Style)
                customSidebarView
                    .frame(width: 236)

                // Thin Glass Vertical Separator
                Rectangle()
                    .fill(NovaTheme.glassBorder)
                    .frame(width: 1)

                // Main Display Content
                VStack(spacing: 0) {
                    topUtilityBar
                        .padding(.horizontal, 28)
                        .padding(.top, 18)
                        .padding(.bottom, 14)

                    // Detail Area
                    ZStack {
                        switch selectedTab {
                        case .servers:
                            serversCleanView
                        case .projects:
                            projectsCleanView
                        case .logs:
                            logsCleanView
                        case .settings:
                            settingsCleanView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            // Floating Toast Feedback
            if let toast = manager.toastMessage {
                VStack {
                    Spacer()
                    glassToast(toast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 28)
                }
            }
        }
    }

    // MARK: - Bespoke Navigation Rail (Sidebar)
    private var customSidebarView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Traffic lights spacer & Brand Header
            VStack(alignment: .leading, spacing: 14) {
                // Header Branding
                HStack(spacing: 12) {
                    BrandLogoView(size: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("NovaStack")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(NovaTheme.textPrimary)

                            Text("1.0")
                                .font(.system(size: 9, weight: .heavy))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(NovaTheme.neonCyan.opacity(0.20))
                                .foregroundColor(NovaTheme.neonCyan)
                                .clipShape(Capsule())
                        }

                        Text("Entorno Web Local")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(NovaTheme.textSecondary)
                    }
                }
            }
            .padding(.top, 40)
            .padding(.horizontal, 18)
            .padding(.bottom, 24)

            // Section Label
            Text("SERVICIOS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(NovaTheme.textTertiary)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            // Nav Items
            VStack(spacing: 4) {
                sidebarButton(
                    title: "Servidores",
                    icon: NavigationSection.servers.icon,
                    section: .servers,
                    statusDotColor: serverStatusColor
                )

                sidebarButton(
                    title: "Proyectos Web",
                    icon: NavigationSection.projects.icon,
                    section: .projects,
                    badgeCount: manager.projects.count
                )
            }
            .padding(.horizontal, 12)

            // Section Label
            Text("HERRAMIENTAS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(NovaTheme.textTertiary)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)

            VStack(spacing: 4) {
                sidebarButton(
                    title: "Registros",
                    icon: NavigationSection.logs.icon,
                    section: .logs
                )

                sidebarButton(
                    title: "Configuración",
                    icon: NavigationSection.settings.icon,
                    section: .settings
                )
            }
            .padding(.horizontal, 12)

            Spacer()

            // External Drive Glass Status Pill at bottom
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(NovaTheme.emeraldGreen.opacity(0.20))
                        .frame(width: 26, height: 26)
                    Image(systemName: "externaldrive.fill.badge.checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(NovaTheme.emeraldGreen)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Disco Externo (APFS)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(NovaTheme.textPrimary)
                    Text("Conectado y listo")
                        .font(.system(size: 10))
                        .foregroundColor(NovaTheme.textSecondary)
                }
                Spacer()
            }
            .padding(10)
            .background(NovaTheme.glassFill)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(NovaTheme.glassBorder, lineWidth: 0.5)
            )
            .cornerRadius(10)
            .padding(14)
        }
    }

    private func sidebarButton(
        title: String,
        icon: String,
        section: NavigationSection,
        badgeCount: Int? = nil,
        statusDotColor: Color? = nil
    ) -> some View {
        let isSelected = selectedTab == section
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedTab = section
            }
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? NovaTheme.neonCyan : NovaTheme.textSecondary)
                    .frame(width: 20)

                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? NovaTheme.textPrimary : NovaTheme.textSecondary)
                    .lineLimit(1)

                Spacer()

                if let dotColor = statusDotColor {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 7, height: 7)
                        .shadow(color: dotColor.opacity(0.6), radius: 3)
                } else if let count = badgeCount {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(NovaTheme.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? NovaTheme.glassSelected : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? NovaTheme.glassBorderSelected : Color.clear, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var serverStatusColor: Color {
        if manager.isApacheRunning && manager.isMySQLRunning {
            return NovaTheme.emeraldGreen
        } else if manager.isApacheRunning || manager.isMySQLRunning {
            return NovaTheme.solarAmber
        } else {
            return Color.white.opacity(0.3)
        }
    }

    // MARK: - Top Utility Bar
    private var topUtilityBar: some View {
        HStack(spacing: 10) {
            Text(selectedTab.rawValue)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(NovaTheme.textPrimary)

            Spacer()

            // Quick Utility Actions
            Button(action: { manager.openLocalhost() }) {
                HStack(spacing: 5) {
                    Image(systemName: "safari")
                    Text("Localhost")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(NovaTheme.textPrimary)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(NovaTheme.glassFill)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(NovaTheme.glassBorder, lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .help("Abrir Localhost (⌘L)")

            Button(action: { manager.openPhpMyAdmin() }) {
                HStack(spacing: 5) {
                    Image(systemName: "cylinder.split.1x2")
                    Text("phpMyAdmin")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(NovaTheme.textPrimary)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(NovaTheme.glassFill)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(NovaTheme.glassBorder, lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .help("Abrir phpMyAdmin (⌘M)")

            Button(action: { manager.openInFinder(path: manager.documentRoot) }) {
                HStack(spacing: 5) {
                    Image(systemName: "folder")
                    Text("Raíz www")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(NovaTheme.textPrimary)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(NovaTheme.glassFill)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(NovaTheme.glassBorder, lineWidth: 0.5))
            }
            .buttonStyle(.plain)
            .help("Mostrar proyectos en Finder (⇧⌘O)")
        }
    }

    // MARK: - Tab 1: Servidores (CleanMyMac "Smart Care" Hero Style)
    private var serversCleanView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 2-Column Hero Structure
            HStack(alignment: .center, spacing: 32) {
                // Left Column: 3D Floating Isometric Stack
                VStack(spacing: 12) {
                    ZStack {
                        // Ambient radial glow behind 3D stack
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (manager.isApacheRunning && manager.isMySQLRunning ? NovaTheme.neonCyan : NovaTheme.electricIndigo).opacity(0.35),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 110
                                )
                            )
                            .frame(width: 220, height: 220)

                        BrandLogoView(size: 160)
                    }

                    HStack(spacing: 8) {
                        NovaBadge("Apache 80", icon: "globe", color: NovaTheme.neonCyan)
                        NovaBadge("MySQL 3306", icon: "cylinder.fill", color: NovaTheme.electricIndigo)
                    }
                }
                .frame(width: 220)

                // Right Column: Executive Service Checklist & Status
                VStack(alignment: .leading, spacing: 16) {
                    // Headline
                    VStack(alignment: .leading, spacing: 4) {
                        Text(heroStatusTitle)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(NovaTheme.textPrimary)

                        Text(heroStatusSubtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(NovaTheme.textSecondary)
                    }

                    // 3 Glass Service Checklist Rows
                    VStack(spacing: 10) {
                        // Apache Row
                        serviceChecklistRow(
                            name: "Apache HTTP Server",
                            tech: "PHP 8.2",
                            port: "Puerto 80",
                            pid: manager.apachePID,
                            isRunning: manager.isApacheRunning,
                            icon: "globe",
                            iconColor: NovaTheme.neonCyan,
                            onToggle: {
                                if manager.isApacheRunning { manager.stopApache() } else { manager.startApache() }
                            },
                            primaryAction: ("Localhost", { manager.openLocalhost() })
                        )

                        // MySQL Row
                        serviceChecklistRow(
                            name: "MySQL / MariaDB",
                            tech: "MariaDB",
                            port: "Puerto 3306",
                            pid: manager.mysqlPID,
                            isRunning: manager.isMySQLRunning,
                            icon: "cylinder.split.1x2.fill",
                            iconColor: NovaTheme.electricIndigo,
                            onToggle: {
                                if manager.isMySQLRunning { manager.stopMySQL() } else { manager.startMySQL() }
                            },
                            primaryAction: ("phpMyAdmin", { manager.openPhpMyAdmin() })
                        )

                        // Storage Row
                        storageChecklistRow
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 28)

            Spacer()

            // Bottom Floating Master Action (The CleanMyMac "Scan" Button)
            HStack(spacing: 16) {
                // Secondary Action: Reiniciar Todo
                Button(action: {
                    isRestarting = true
                    manager.restartAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isRestarting = false
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(NovaTheme.glassFill)
                            .frame(width: 46, height: 46)
                            .overlay(Circle().stroke(NovaTheme.glassBorder, lineWidth: 0.5))

                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(NovaTheme.textPrimary)
                            .rotationEffect(.degrees(isRestarting ? 360 : 0))
                            .animation(isRestarting ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRestarting)
                    }
                }
                .buttonStyle(.plain)
                .help("Reiniciar todos los servidores")
                .disabled(manager.isBusy)

                // Master Glow Button
                Button(action: {
                    if manager.isApacheRunning && manager.isMySQLRunning {
                        manager.stopAll()
                    } else {
                        manager.startAll()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: manager.isApacheRunning && manager.isMySQLRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))

                        Text(manager.isApacheRunning && manager.isMySQLRunning ? "Detener Servidores" : "Iniciar Servidores")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(manager.isApacheRunning && manager.isMySQLRunning ? NovaTheme.actionGradientStop : NovaTheme.actionGradientPrimary)
                    )
                    .shadow(
                        color: (manager.isApacheRunning && manager.isMySQLRunning ? NovaTheme.coralRed : NovaTheme.neonCyan).opacity(0.50),
                        radius: 18,
                        y: 4
                    )
                }
                .buttonStyle(.plain)
                .disabled(manager.isBusy)

                // Secondary Action: Respaldar Bases de Datos
                Button(action: {
                    Task {
                        _ = await manager.migrateDatabasesFromXAMPP()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(NovaTheme.glassFill)
                            .frame(width: 46, height: 46)
                            .overlay(Circle().stroke(NovaTheme.glassBorder, lineWidth: 0.5))

                        Image(systemName: "cylinder.split.1x2")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(NovaTheme.textPrimary)
                    }
                }
                .buttonStyle(.plain)
                .help("Respaldar todas las bases de datos en disco externo")
                .disabled(manager.isBusy)
            }
            .padding(.bottom, 32)
        }
    }

    private var heroStatusTitle: String {
        if manager.isApacheRunning && manager.isMySQLRunning {
            return "Entorno Operativo"
        } else if manager.isApacheRunning || manager.isMySQLRunning {
            return "Operación Parcial"
        } else {
            return "Servidores Detenidos"
        }
    }

    private var heroStatusSubtitle: String {
        if manager.isApacheRunning && manager.isMySQLRunning {
            return "Apache y MySQL activos en disco externo listos para servir."
        } else if manager.isApacheRunning {
            return "Apache activo en puerto 80. MySQL se encuentra detenido."
        } else if manager.isMySQLRunning {
            return "MySQL activo en puerto 3306. Apache se encuentra detenido."
        } else {
            return "Presiona Iniciar para arrancar la suite y servir tus sitios web."
        }
    }

    private func serviceChecklistRow(
        name: String,
        tech: String,
        port: String,
        pid: Int32?,
        isRunning: Bool,
        icon: String,
        iconColor: Color,
        onToggle: @escaping () -> Void,
        primaryAction: (title: String, action: () -> Void)
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(NovaTheme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(tech)
                        .font(.system(size: 11))
                        .foregroundColor(NovaTheme.textSecondary)
                    Text("·")
                        .foregroundColor(NovaTheme.textTertiary)
                    Text(port)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(NovaTheme.textSecondary)

                    if let pid = pid, isRunning {
                        Text("·")
                            .foregroundColor(NovaTheme.textTertiary)
                        Text("PID \(String(pid))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(NovaTheme.textTertiary)
                    }
                }
                .lineLimit(1)
            }

            Spacer(minLength: 12)

            // Status Badge
            HStack(spacing: 5) {
                StatusDot(isActive: isRunning)
                Text(isRunning ? "En línea" : "Inactivo")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(isRunning ? NovaTheme.emeraldGreen : NovaTheme.textTertiary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())

            // Direct Link
            Button(action: primaryAction.action) {
                HStack(spacing: 4) {
                    Text(primaryAction.title)
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 9, weight: .bold))
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isRunning ? NovaTheme.neonCyan : NovaTheme.textTertiary)
            }
            .buttonStyle(.plain)
            .disabled(!isRunning)

            // Inline Mini Toggle
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(isRunning ? NovaTheme.coralRed.opacity(0.22) : NovaTheme.neonCyan.opacity(0.22))
                        .frame(width: 28, height: 28)
                    Image(systemName: isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isRunning ? NovaTheme.coralRed : NovaTheme.neonCyan)
                }
            }
            .buttonStyle(.plain)
            .help(isRunning ? "Detener servicio" : "Iniciar servicio")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 14)
    }

    private var storageChecklistRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(NovaTheme.solarAmber.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: "externaldrive.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(NovaTheme.solarAmber)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Almacenamiento en Disco Externo")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(NovaTheme.textPrimary)

                Text("/Volumes/Externo/NovaStack · www · database")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(NovaTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 16)

            Button(action: { manager.openInFinder(path: manager.documentRoot) }) {
                Image(systemName: "folder")
                    .font(.system(size: 12))
                    .foregroundColor(NovaTheme.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(NovaTheme.glassFill)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Abrir carpeta www en Finder")

            Button(action: { manager.copyToClipboard(manager.documentRoot) }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 11))
                    .foregroundColor(NovaTheme.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(NovaTheme.glassFill)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Copiar ruta")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 14)
    }

    // MARK: - Tab 2: Proyectos Web
    private var filteredProjects: [ServerManager.ProjectItem] {
        if projectSearchText.isEmpty {
            return manager.projects
        } else {
            return manager.projects.filter {
                $0.name.localizedCaseInsensitiveContains(projectSearchText) ||
                $0.type.rawValue.localizedCaseInsensitiveContains(projectSearchText)
            }
        }
    }

    private var projectsCleanView: some View {
        VStack(spacing: 16) {
            // Search & View Controls Bar
            HStack(spacing: 12) {
                // Search Input with Glass Styling
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(NovaTheme.textTertiary)
                        .font(.system(size: 13))

                    TextField("Buscar proyecto web...", text: $projectSearchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(NovaTheme.textPrimary)

                    if !projectSearchText.isEmpty {
                        Button(action: { projectSearchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(NovaTheme.textTertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(NovaTheme.glassFill)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(NovaTheme.glassBorder, lineWidth: 0.5))

                Spacer()

                Text("\(manager.projects.count) proyectos")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(NovaTheme.textSecondary)

                Picker("", selection: $isGridView) {
                    Image(systemName: "square.grid.2x2").tag(true)
                    Image(systemName: "list.bullet").tag(false)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 76)

                Button(action: { manager.scanProjects() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(NovaTheme.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(NovaTheme.glassFill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(NovaTheme.glassBorder, lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .help("Volver a escanear")
            }
            .padding(.horizontal, 28)

            // Content
            if filteredProjects.isEmpty {
                VStack(spacing: 14) {
                    Spacer()
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(NovaTheme.textTertiary)

                    Text(projectSearchText.isEmpty ? "No se encontraron proyectos en /www" : "Sin resultados para '\(projectSearchText)'")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(NovaTheme.textSecondary)

                    if !projectSearchText.isEmpty {
                        Button("Limpiar filtro") { projectSearchText = "" }
                            .buttonStyle(.bordered)
                    }
                    Spacer()
                }
            } else if isGridView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 14)], spacing: 14) {
                        ForEach(filteredProjects) { project in
                            ProjectGridCardView(
                                project: project,
                                isSelected: manager.selectedProject?.id == project.id,
                                onSelect: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if manager.selectedProject?.id == project.id {
                                            manager.selectedProject = nil
                                        } else {
                                            manager.selectedProject = project
                                        }
                                    }
                                },
                                onOpenBrowser: { manager.openInBrowser(project.url) },
                                onOpenFinder: { manager.openInFinder(path: project.path) },
                                onCopyURL: { manager.copyToClipboard(project.url.absoluteString) },
                                onCopyPath: { manager.copyToClipboard(project.path) }
                            )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                }
            } else {
                List(filteredProjects, id: \.id) { project in
                    ProjectListRowView(
                        project: project,
                        isSelected: manager.selectedProject?.id == project.id,
                        onOpenBrowser: { manager.openInBrowser(project.url) },
                        onOpenFinder: { manager.openInFinder(path: project.path) },
                        onCopyURL: { manager.copyToClipboard(project.url.absoluteString) },
                        onCopyPath: { manager.copyToClipboard(project.path) }
                    )
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Tab 3: Registros (Logs)
    private var logsCleanView: some View {
        VStack(spacing: 14) {
            // Log Header Controls
            HStack {
                Picker("", selection: $manager.selectedLogType) {
                    ForEach(ServerManager.LogType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 320)
                .onChange(of: manager.selectedLogType) {
                    manager.loadLogs()
                }

                Spacer()

                Button(action: { manager.loadLogs() }) {
                    Label("Recargar", systemImage: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(NovaTheme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(NovaTheme.glassFill)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(NovaTheme.glassBorder, lineWidth: 0.5))
                }
                .buttonStyle(.plain)

                Button(action: {
                    manager.copyToClipboard(manager.liveLogs.joined(separator: "\n"))
                }) {
                    Label("Copiar Todo", systemImage: "doc.on.doc")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(NovaTheme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(NovaTheme.glassFill)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(NovaTheme.glassBorder, lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)

            // Terminal Screen
            ScrollView {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(manager.liveLogs.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(logLineColor(line))
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .background(Color.black.opacity(0.40))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(NovaTheme.glassBorder, lineWidth: 0.5))
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .onAppear { manager.loadLogs() }
    }

    private func logLineColor(_ line: String) -> Color {
        let lower = line.lowercased()
        if lower.contains("error") || lower.contains("fail") || lower.contains("fatal") {
            return NovaTheme.coralRed
        } else if lower.contains("warn") {
            return NovaTheme.solarAmber
        } else if lower.contains("notice") || lower.contains("info") {
            return NovaTheme.neonCyan
        } else {
            return NovaTheme.textSecondary
        }
    }

    // MARK: - Tab 4: Configuración
    private var settingsCleanView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Storage Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("UBICACIÓN EN DISCO EXTERNO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(NovaTheme.textTertiary)

                    folderSettingRow(
                        title: "Carpeta DocumentRoot (Web)",
                        subtitle: "Ubicación de tus proyectos PHP y sitios web.",
                        path: $manager.documentRoot
                    )

                    Divider().overlay(NovaTheme.glassBorder)

                    folderSettingRow(
                        title: "Carpeta de Bases de Datos",
                        subtitle: "Directorio de datos y respaldos de MySQL.",
                        path: $manager.dataDir
                    )
                }
                .padding(18)
                .glassCard(cornerRadius: 14)

                // Network Ports Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("PUERTOS DE RED LOCAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(NovaTheme.textTertiary)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Puerto Apache HTTP")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(NovaTheme.textPrimary)
                            Text("Puerto estándar para solicitudes web (80)")
                                .font(.system(size: 11))
                                .foregroundColor(NovaTheme.textSecondary)
                        }
                        Spacer()
                        TextField("", value: $manager.apachePort, formatter: portFormatter)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(NovaTheme.glassFill)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(NovaTheme.glassBorder, lineWidth: 0.5))
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(NovaTheme.textPrimary)
                    }

                    Divider().overlay(NovaTheme.glassBorder)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Puerto MySQL")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(NovaTheme.textPrimary)
                            Text("Puerto de conexión de base de datos (3306)")
                                .font(.system(size: 11))
                                .foregroundColor(NovaTheme.textSecondary)
                        }
                        Spacer()
                        TextField("", value: $manager.mysqlPort, formatter: portFormatter)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(NovaTheme.glassFill)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(NovaTheme.glassBorder, lineWidth: 0.5))
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(NovaTheme.textPrimary)
                    }
                }
                .padding(18)
                .glassCard(cornerRadius: 14)

                // Active Config Files Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("ARCHIVOS DE CONFIGURACIÓN ACTIVOS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(NovaTheme.textTertiary)

                    HStack(spacing: 10) {
                        Button("httpd.conf") {
                            manager.openInFinder(path: "\(manager.configDir)/httpd.conf")
                        }
                        .buttonStyle(.bordered)

                        Button("my.cnf") {
                            manager.openInFinder(path: "\(manager.configDir)/my.cnf")
                        }
                        .buttonStyle(.bordered)

                        Button("php.ini") {
                            manager.openInFinder(path: "\(manager.configDir)/php.ini")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(18)
                .glassCard(cornerRadius: 14)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
    }

    private var portFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        f.usesGroupingSeparator = false
        return f
    }

    private func folderSettingRow(title: String, subtitle: String, path: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(NovaTheme.textPrimary)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(NovaTheme.textSecondary)

            HStack {
                TextField("", text: path)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(NovaTheme.glassFill)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(NovaTheme.glassBorder, lineWidth: 0.5))
                    .foregroundColor(NovaTheme.textPrimary)

                Button("Examinar...") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    if panel.runModal() == .OK, let url = panel.url {
                        path.wrappedValue = url.path
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Glass Toast
    private func glassToast(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(NovaTheme.emeraldGreen)
                .font(.system(size: 14, weight: .semibold))

            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.70))
        .cornerRadius(20)
        .overlay(
            Capsule()
                .stroke(NovaTheme.glassBorderSelected, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 10, y: 5)
    }
}
