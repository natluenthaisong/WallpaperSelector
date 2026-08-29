import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @ObservedObject var manager: WallpaperManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let preview = manager.previewImage {
                Image(nsImage: preview)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 4)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(manager.todayColor.thaiDayName)
                    .font(.headline)
                Text("สีมงคล: \(manager.todayColor.colorName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let updated = manager.lastUpdated {
                    Text("อัปเดตล่าสุด: \(updated.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("คาถาบูชาพระประจำวัน")
                    .font(.subheadline).bold()
                Text(manager.todayMantra.buddhaPose)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(manager.todayMantra.text)
                    .font(.caption)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                Text("สวด \(manager.todayMantra.repeatCount) จบ")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Button {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(manager.todayMantra.text, forType: .string)
                } label: {
                    Label("คัดลอกคาถา", systemImage: "doc.on.doc")
                }
                .font(.caption)
            }

            Divider()

            Button {
                manager.applyNow()
            } label: {
                Label("ตั้งเป็นวอลเปเปอร์ตอนนี้", systemImage: "wand.and.stars")
            }
            .buttonStyle(.borderedProminent)

            Toggle("อัปเดตอัตโนมัติตามวัน/เวลา", isOn: Binding(
                get: { manager.autoUpdateEnabled },
                set: { manager.setAutoUpdate($0) }
            ))

            Divider()

            Button(role: .destructive) {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("ออกจากโปรแกรม", systemImage: "power")
            }
        }
        .padding(16)
        .frame(width: 300)
    }
}
