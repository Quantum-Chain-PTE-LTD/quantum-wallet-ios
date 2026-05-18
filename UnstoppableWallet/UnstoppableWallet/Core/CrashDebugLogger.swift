import Darwin
import Foundation

enum CrashDebugLogger {
    private static var installed = false

    static func install() {
        guard !installed else { return }
        installed = true

        NSSetUncaughtExceptionHandler { exception in
            let symbols = exception.callStackSymbols.joined(separator: "\n")
            print("[CRASH-DEBUG] UNCAUGHT EXCEPTION: \(exception.name.rawValue)")
            print("[CRASH-DEBUG] reason: \(exception.reason ?? "<none>")")
            print("[CRASH-DEBUG] userInfo: \(String(describing: exception.userInfo))")
            print("[CRASH-DEBUG] stack:\n\(symbols)")
            fflush(stdout)
            fflush(stderr)
        }

        let signals: [Int32] = [SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGTRAP, SIGPIPE]
        for sig in signals {
            signal(sig) { signal in
                let name = CrashDebugLogger.name(for: signal)
                print("[CRASH-DEBUG] SIGNAL CAUGHT: \(name) (\(signal))")
                let symbols = Thread.callStackSymbols.joined(separator: "\n")
                print("[CRASH-DEBUG] stack:\n\(symbols)")
                fflush(stdout)
                fflush(stderr)
                // restore default handler and re-raise so the process actually terminates
                Darwin.signal(signal, SIG_DFL)
                raise(signal)
            }
        }

        print("[CRASH-DEBUG] handlers installed")
        fflush(stdout)
    }

    private static func name(for signal: Int32) -> String {
        switch signal {
        case SIGABRT: return "SIGABRT"
        case SIGILL: return "SIGILL"
        case SIGSEGV: return "SIGSEGV"
        case SIGFPE: return "SIGFPE"
        case SIGBUS: return "SIGBUS"
        case SIGTRAP: return "SIGTRAP"
        case SIGPIPE: return "SIGPIPE"
        default: return "UNKNOWN"
        }
    }
}
