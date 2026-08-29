import SwiftUI
import AppKit
import Combine

@MainActor
final class WallpaperManager: ObservableObject {
    static let shared = WallpaperManager()

    @Published private(set) var previewImage: NSImage?
    @Published private(set) var lastUpdated: Date?
    @Published var autoUpdateEnabled: Bool {
        didSet { UserDefaults.standard.set(autoUpdateEnabled, forKey: Self.autoUpdateKey) }
    }

    private var timer: Timer?
    private let folder: URL
    private static let autoUpdateKey = "autoUpdateEnabled"

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        folder = appSupport.appendingPathComponent("WallpaperSelector", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        autoUpdateEnabled = UserDefaults.standard.object(forKey: Self.autoUpdateKey) as? Bool ?? true
        generatePreview()
        if autoUpdateEnabled { startTimer() }
    }

    var todayColor: AuspiciousColor { AuspiciousColor.forNow() }
    var currentTimeOfDay: TimeOfDay { TimeOfDay.now() }
    var todayMantra: DailyMantra { DailyMantra.forNow() }

    func startTimer() {
        timer?.invalidate()
        // เช็กทุกนาที ว่าข้ามชั่วโมง/ช่วงเวลา/วันหรือยัง ค่อยสร้างวอลเปเปอร์ใหม่และตั้งค่าจริง
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func setAutoUpdate(_ enabled: Bool) {
        autoUpdateEnabled = enabled
        if enabled {
            startTimer()
            applyNow()
        } else {
            stopTimer()
        }
    }

    private var lastAppliedHour: Int?

    private func tick() {
        generatePreview()
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour != lastAppliedHour else { return }
        lastAppliedHour = hour
        applyNow()
    }

    /// สร้างภาพตัวอย่างสำหรับแสดงใน UI (ขนาดย่อ ไม่กระทบวอลเปเปอร์จริง)
    func generatePreview() {
        let size = CGSize(width: 640, height: 400)
        let view = WallpaperContentView(size: size, date: Date(), auspicious: todayColor, timeOfDay: currentTimeOfDay, mantra: todayMantra)
        previewImage = Self.render(view: view, size: size, scale: 2)
    }

    /// สร้างภาพวอลเปเปอร์ขนาดเต็มจอ บันทึกไฟล์ และตั้งเป็นวอลเปเปอร์เดสก์ท็อปทันที
    func applyNow() {
        guard let screen = NSScreen.main else { return }
        let scale = screen.backingScaleFactor
        let size = screen.frame.size
        let auspicious = todayColor
        let timeOfDay = currentTimeOfDay
        let mantra = todayMantra
        let now = Date()

        let view = WallpaperContentView(size: size, date: now, auspicious: auspicious, timeOfDay: timeOfDay, mantra: mantra)
        guard let image = Self.render(view: view, size: size, scale: scale) else { return }
        guard let data = image.pngData() else { return }

        // ใช้ชื่อไฟล์ใหม่ทุกครั้งเพื่อบังคับให้ macOS โหลดภาพใหม่แทนที่จะใช้ cache เดิม
        let filename = "wallpaper-\(Int(now.timeIntervalSince1970)).png"
        let fileURL = folder.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            for screen in NSScreen.screens {
                try NSWorkspace.shared.setDesktopImageURL(fileURL, for: screen, options: [:])
            }
            lastUpdated = now
            cleanupOldFiles(keeping: fileURL)
            generatePreview()
        } catch {
            print("ตั้งค่าวอลเปเปอร์ไม่สำเร็จ: \(error)")
        }
    }

    private func cleanupOldFiles(keeping current: URL) {
        guard let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else { return }
        for file in files where file != current {
            try? FileManager.default.removeItem(at: file)
        }
    }

    private static func render(view: some View, size: CGSize, scale: CGFloat) -> NSImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        return renderer.nsImage
    }
}

private extension NSImage {
    func pngData() -> Data? {
        guard let tiff = tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }
}
