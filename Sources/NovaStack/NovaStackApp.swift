import SwiftUI
import AppKit

@main
struct NovaStackApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var manager = ServerManager.shared

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .frame(minWidth: 1060, minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandMenu("Servidores") {
                Button("Iniciar Todos los Servicios") {
                    manager.startAll()
                }
                .keyboardShortcut("r", modifiers: .command)

                Button("Detener Todos los Servicios") {
                    manager.stopAll()
                }
                .keyboardShortcut(".", modifiers: .command)

                Divider()

                Button("Abrir Localhost") {
                    manager.openLocalhost()
                }
                .keyboardShortcut("l", modifiers: .command)

                Button("Abrir phpMyAdmin") {
                    manager.openPhpMyAdmin()
                }
                .keyboardShortcut("m", modifiers: .command)

                Button("Mostrar Carpeta www en Finder") {
                    manager.openInFinder(path: manager.documentRoot)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }

        // Menu Bar Extra
        MenuBarExtra("NovaStack", systemImage: menuBarSymbol) {
            VStack {
                Text("NovaStack")
                    .font(.caption.bold())

                Divider()

                HStack {
                    Circle()
                        .fill(manager.isApacheRunning ? NovaTheme.emeraldGreen : Color.secondary.opacity(0.4))
                        .frame(width: 8, height: 8)
                    Text("Apache: \(manager.isApacheRunning ? "En ejecución" : "Detenido")")
                }

                HStack {
                    Circle()
                        .fill(manager.isMySQLRunning ? NovaTheme.emeraldGreen : Color.secondary.opacity(0.4))
                        .frame(width: 8, height: 8)
                    Text("MySQL: \(manager.isMySQLRunning ? "En ejecución" : "Detenido")")
                }

                Divider()

                Button("Iniciar Todos los Servicios (⌘R)") {
                    manager.startAll()
                }
                .disabled(manager.isBusy)

                Button("Detener Todos los Servicios (⌘.)") {
                    manager.stopAll()
                }
                .disabled(manager.isBusy)

                Divider()

                Button("Abrir Localhost (⌘L)") {
                    manager.openLocalhost()
                }

                Button("Abrir phpMyAdmin (⌘M)") {
                    manager.openPhpMyAdmin()
                }

                Button("Abrir Carpeta www (Disco Externo)") {
                    manager.openInFinder(path: manager.documentRoot)
                }

                Divider()

                Button("Salir de NovaStack") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }

    private var menuBarSymbol: String {
        if manager.isApacheRunning && manager.isMySQLRunning {
            return "server.rack"
        } else if manager.isApacheRunning || manager.isMySQLRunning {
            return "bolt.horizontal.circle"
        } else {
            return "network.slash"
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
                window.titleVisibility = .hidden
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
