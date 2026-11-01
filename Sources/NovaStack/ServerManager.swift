import Foundation
import SwiftUI
import AppKit

@MainActor
public class ServerManager: ObservableObject {
    public static let shared = ServerManager()

    // MARK: - State Properties
    @Published public var isApacheRunning: Bool = false
    @Published public var isMySQLRunning: Bool = false
    @Published public var apachePID: Int32? = nil
    @Published public var mysqlPID: Int32? = nil
    @Published public var apachePort: Int = 8080
    @Published public var mysqlPort: Int = 3306
    
    @Published public var documentRoot: String = "/Volumes/Externo/NovaStack/www"
    @Published public var dataDir: String = "/Volumes/Externo/NovaStack/database"
    @Published public var configDir: String = "/Volumes/Externo/NovaStack/config"
    @Published public var logsDir: String = "/Volumes/Externo/NovaStack/logs"
    
    @Published public var projects: [ProjectItem] = []
    @Published public var isBusy: Bool = false
    @Published public var statusMessage: String = "NovaStack preparado"
    @Published public var liveLogs: [String] = []
    @Published public var selectedLogType: LogType = .apacheError
    
    // Toast notification for optimistic UI & feedback
    @Published public var toastMessage: String? = nil
    @Published public var selectedProject: ProjectItem? = nil

    public enum LogType: String, CaseIterable, Identifiable, Sendable {
        case apacheError = "Apache Error"
        case apacheAccess = "Apache Access"
        case mysqlLog = "MariaDB / MySQL"
        
        public var id: String { rawValue }
    }

    public enum ProjectType: String, Sendable, CaseIterable {
        case wordpress = "WordPress"
        case laravel = "Laravel"
        case php = "PHP"
        case staticSite = "HTML / Web"

        public var icon: String {
            switch self {
            case .wordpress: return "w.circle.fill"
            case .laravel: return "flame.fill"
            case .php: return "chevron.left.forwardslash.chevron.right"
            case .staticSite: return "safari.fill"
            }
        }

        public var tintColor: Color {
            switch self {
            case .wordpress: return .blue
            case .laravel: return .red
            case .php: return .indigo
            case .staticSite: return .teal
            }
        }
    }

    public struct ProjectItem: Identifiable, Sendable, Hashable {
        public let id = UUID()
        public let name: String
        public let path: String
        public let url: URL
        public let type: ProjectType
    }

    private var statusTimer: Timer?

    private init() {
        startStatusMonitor()
        scanProjects()
    }

    // MARK: - Toast helper
    public func showToast(_ text: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.toastMessage = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if self.toastMessage == text {
                    self.toastMessage = nil
                }
            }
        }
    }

    public func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        showToast("Copiado al portapapeles")
    }

    // MARK: - Timer Monitor
    public func startStatusMonitor() {
        refreshStatuses()
        statusTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshStatuses()
            }
        }
    }

    // MARK: - Service Status Checks
    public func refreshStatuses() {
        checkApacheStatus()
        checkMySQLStatus()
    }

    private func checkApacheStatus() {
        let running = Self.runCommandSync("/usr/bin/pgrep", ["-x", "httpd"]).exitCode == 0
        self.isApacheRunning = running
        self.apachePID = running ? getPgrepPID("httpd") : nil
    }

    private func checkMySQLStatus() {
        let runningMaria = Self.runCommandSync("/usr/bin/pgrep", ["-x", "mariadbd"]).exitCode == 0
        let runningMysql = Self.runCommandSync("/usr/bin/pgrep", ["-x", "mysqld"]).exitCode == 0
        let isUp = runningMaria || runningMysql
        self.isMySQLRunning = isUp
        self.mysqlPID = runningMaria ? getPgrepPID("mariadbd") : (runningMysql ? getPgrepPID("mysqld") : nil)
    }

    private func getPgrepPID(_ name: String) -> Int32? {
        let res = Self.runCommandSync("/usr/bin/pgrep", ["-x", name])
        if let firstLine = res.output.components(separatedBy: .newlines).first,
           let pid = Int32(firstLine.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return pid
        }
        return nil
    }

    // MARK: - Apache Control (Native Homebrew ARM64)
    public func startApache() {
        isBusy = true
        statusMessage = "Iniciando Apache..."
        Task {
            _ = await Task.detached {
                let script = """
                if ! /usr/bin/pgrep -x httpd >/dev/null 2>&1; then
                    /opt/homebrew/bin/httpd -k start 2>&1
                fi
                """
                return Self.runCommandSync("/bin/bash", ["-c", script])
            }.value

            try? await Task.sleep(nanoseconds: 800_000_000)
            self.refreshStatuses()
            self.isBusy = false
            let success = self.isApacheRunning
            self.statusMessage = success ? "Apache iniciado en puerto \(self.apachePort)" : "Error al iniciar Apache"
            self.showToast(success ? "Apache iniciado (:\(self.apachePort))" : "Error al iniciar Apache")
        }
    }

    public func stopApache() {
        isBusy = true
        statusMessage = "Deteniendo Apache..."
        Task {
            _ = await Task.detached {
                let script = """
                /opt/homebrew/bin/httpd -k stop 2>/dev/null || /usr/bin/pkill -x httpd 2>/dev/null || true
                """
                return Self.runCommandSync("/bin/bash", ["-c", script])
            }.value

            try? await Task.sleep(nanoseconds: 600_000_000)
            self.refreshStatuses()
            self.isBusy = false
            self.statusMessage = "Apache detenido"
            self.showToast("Apache detenido")
        }
    }

    public func restartApache() {
        stopApache()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startApache()
        }
    }

    // MARK: - MySQL / MariaDB Control (Native Homebrew ARM64)
    public func startMySQL() {
        isBusy = true
        statusMessage = "Iniciando MariaDB..."
        Task {
            _ = await Task.detached {
                let script = """
                if ! /usr/bin/pgrep -x mariadbd >/dev/null 2>&1; then
                    /opt/homebrew/bin/mariadbd-safe --datadir=/opt/homebrew/var/mysql >/dev/null 2>&1 &
                fi
                """
                return Self.runCommandSync("/bin/bash", ["-c", script])
            }.value

            try? await Task.sleep(nanoseconds: 1_200_000_000)
            self.refreshStatuses()
            self.isBusy = false
            let success = self.isMySQLRunning
            self.statusMessage = success ? "MariaDB iniciado (:\(self.mysqlPort))" : "Error al iniciar MariaDB"
            self.showToast(success ? "MariaDB iniciado" : "Error al iniciar MariaDB")
        }
    }

    public func stopMySQL() {
        isBusy = true
        statusMessage = "Deteniendo MariaDB..."
        Task {
            _ = await Task.detached {
                let script = """
                /opt/homebrew/bin/mariadb-admin -u root shutdown 2>/dev/null || true
                /opt/homebrew/bin/brew services stop mariadb 2>/dev/null || true
                /usr/bin/pkill -f mariadbd-safe 2>/dev/null || true
                /usr/bin/pkill -15 -x mariadbd 2>/dev/null || true
                for i in {1..10}; do
                    if ! /usr/bin/pgrep -x mariadbd >/dev/null 2>&1; then
                        break
                    fi
                    sleep 0.2
                done
                /usr/bin/pkill -9 -x mariadbd 2>/dev/null || true
                rm -f /tmp/mysql.sock /tmp/mysql.sock.lock 2>/dev/null || true
                """
                return Self.runCommandSync("/bin/bash", ["-c", script])
            }.value

            try? await Task.sleep(nanoseconds: 800_000_000)
            self.refreshStatuses()
            self.isBusy = false
            self.statusMessage = "MariaDB detenido"
            self.showToast("MariaDB detenido")
        }
    }

    public func restartMySQL() {
        stopMySQL()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.startMySQL()
        }
    }

    // MARK: - Batch Control
    public func startAll() {
        startApache()
        startMySQL()
        showToast("Iniciando servicios...")
    }

    public func stopAll() {
        stopApache()
        stopMySQL()
        showToast("Deteniendo servicios...")
    }

    public func restartAll() {
        restartApache()
        restartMySQL()
        showToast("Reiniciando servicios...")
    }

    // MARK: - Project Scanner
    public func scanProjects() {
        guard FileManager.default.fileExists(atPath: documentRoot) else {
            projects = []
            return
        }

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: documentRoot)
            var list: [ProjectItem] = []
            for item in items.sorted() {
                if item.hasPrefix(".") || item == "webalizer" || item == "img" || item == "dashboard" || item == "phpmyadmin" {
                    continue
                }
                let fullPath = "\(documentRoot)/\(item)"
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue {
                    let url = URL(string: "http://localhost:\(apachePort)/\(item)") ?? URL(string: "http://localhost:\(apachePort)")!
                    
                    // Detect project type
                    var pType: ProjectType = .staticSite
                    if FileManager.default.fileExists(atPath: "\(fullPath)/wp-config.php") ||
                       FileManager.default.fileExists(atPath: "\(fullPath)/wp-load.php") {
                        pType = .wordpress
                    } else if FileManager.default.fileExists(atPath: "\(fullPath)/artisan") {
                        pType = .laravel
                    } else if FileManager.default.fileExists(atPath: "\(fullPath)/index.php") {
                        pType = .php
                    }
                    
                    list.append(ProjectItem(name: item, path: fullPath, url: url, type: pType))
                }
            }
            self.projects = list
            if let sel = selectedProject, !list.contains(where: { $0.id == sel.id }) {
                selectedProject = list.first
            }
        } catch {
            print("Error scanning projects: \(error)")
        }
    }

    // MARK: - Database Backup Helper
    public func migrateDatabasesFromXAMPP() async -> (Bool, String) {
        return await backupDatabases()
    }

    public func backupDatabases() async -> (Bool, String) {
        isBusy = true
        statusMessage = "Respaldando bases de datos de MariaDB..."
        
        let script = """
        DEST="/Volumes/Externo/NovaStack/database"
        mkdir -p "$DEST"
        MARIADB="/opt/homebrew/bin/mariadb"
        DUMP="/opt/homebrew/bin/mariadb-dump"
        DATABASES=$($MARIADB -u root -e "SHOW DATABASES;" 2>/dev/null | grep -Ev "(Database|information_schema|performance_schema|sys)")
        for db in $DATABASES; do
            $DUMP -u root --skip-lock-tables --events --routines --triggers "$db" > "$DEST/${db}.sql" 2>/dev/null || true
        done
        $DUMP -u root --skip-lock-tables --all-databases --events --routines --triggers > "$DEST/all_databases_backup.sql" 2>/dev/null || true
        """
        
        let success = await Task.detached {
            let res = Self.runCommandSync("/bin/bash", ["-c", script])
            return res.exitCode == 0
        }.value

        self.isBusy = false
        let msg = success ? "Bases de datos respaldadas en disco externo." : "Error respaldando bases de datos"
        self.statusMessage = msg
        showToast(success ? "Bases de datos respaldadas con éxito" : "Error en respaldo")
        return (success, msg)
    }

    // MARK: - Logs Loader
    public func loadLogs() {
        let path: String
        switch selectedLogType {
        case .apacheError:
            path = "/opt/homebrew/var/log/httpd/error_log"
        case .apacheAccess:
            path = "/opt/homebrew/var/log/httpd/access_log"
        case .mysqlLog:
            // Find latest .err file in MariaDB var dir
            let dir = "/opt/homebrew/var/mysql"
            if let files = try? FileManager.default.contentsOfDirectory(atPath: dir),
               let errFile = files.first(where: { $0.hasSuffix(".err") }) {
                path = "\(dir)/\(errFile)"
            } else {
                path = "\(dir)/mariadb.err"
            }
        }

        if FileManager.default.fileExists(atPath: path),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            let lines = content.components(separatedBy: .newlines).suffix(140)
            self.liveLogs = Array(lines)
        } else {
            self.liveLogs = ["(No se encontraron registros en \(path))"]
        }
    }

    // MARK: - Quick Openers
    public func openInBrowser(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    public func openInFinder(path: String) {
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    public func openLocalhost() {
        if let url = URL(string: "http://localhost:\(apachePort)") {
            NSWorkspace.shared.open(url)
        }
    }

    public func openPhpMyAdmin() {
        if let url = URL(string: "http://localhost:\(apachePort)/phpmyadmin") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Execution Helpers
    nonisolated public static func runCommandSync(_ command: String, _ args: [String]) -> (output: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let out = String(data: data, encoding: .utf8) ?? ""
            return (out, process.terminationStatus)
        } catch {
            return ("", 1)
        }
    }
}
