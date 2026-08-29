import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // ซ่อนไอคอนออกจาก Dock เพราะเป็นแอปที่อยู่บน Menu Bar เท่านั้น
        NSApp.setActivationPolicy(.accessory)

        // โหมดทดสอบ/อัตโนมัติ: รันคำสั่งสร้าง+ตั้งวอลเปเปอร์ครั้งเดียวแล้วปิดตัวเอง
        // ใช้ได้กับสคริปต์/launchd โดยไม่ต้องเปิด UI: swift run WallpaperSelector -- --apply-now
        if CommandLine.arguments.contains("--apply-now") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                WallpaperManager.shared.applyNow()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NSApp.terminate(nil)
                }
            }
        }
    }
}

@main
struct WallpaperSelectorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @ObservedObject private var manager = WallpaperManager.shared

    var body: some Scene {
        MenuBarExtra("Wallpaper Selector", systemImage: "paintpalette.fill") {
            MenuBarContentView(manager: manager)
        }
        .menuBarExtraStyle(.window)
    }
}
