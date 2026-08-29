import SwiftUI

/// เนื้อหาภาพวอลเปเปอร์ที่จะถูก render ออกเป็นไฟล์ภาพจริง
struct WallpaperContentView: View {
    let size: CGSize
    let date: Date
    let auspicious: AuspiciousColor
    let timeOfDay: TimeOfDay
    let mantra: DailyMantra

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "th_TH")
        f.calendar = Calendar(identifier: .buddhist)
        f.dateFormat = "EEEEที่ d MMMM yyyy"
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "th_TH")
        f.dateFormat = "HH:mm"
        return f
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [auspicious.primary, auspicious.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.white.opacity(0.12), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: size.width * 0.8
            )

            Color.black.opacity(timeOfDay.darkOverlay)

            VStack(spacing: size.height * 0.02) {
                Spacer()
                Image(systemName: timeOfDay.icon)
                    .font(.system(size: size.height * 0.08, weight: .thin))
                    .foregroundStyle(.white.opacity(0.9))

                Text(timeFormatter.string(from: date))
                    .font(.system(size: size.height * 0.11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 8)

                Text(dateFormatter.string(from: date))
                    .font(.system(size: size.height * 0.028, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))

                Text("สีมงคลประจำวันนี้ • \(auspicious.colorName)")
                    .font(.system(size: size.height * 0.022, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, size.height * 0.01)

                Text("คาถาวันนี้ • \(mantra.buddhaPose) (สวด \(mantra.repeatCount) จบ)")
                    .font(.system(size: size.height * 0.018, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))

                Spacer()
                Spacer()
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }
}
