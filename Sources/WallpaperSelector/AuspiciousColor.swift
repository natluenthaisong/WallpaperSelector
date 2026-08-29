import SwiftUI

/// สีมงคลประจำวันตามความเชื่อไทยดั้งเดิม (สีประจำวันเกิด/วันในสัปดาห์)
struct AuspiciousColor {
    let thaiDayName: String
    let colorName: String
    let primaryHex: String
    let secondaryHex: String

    var primary: Color { Color(hex: primaryHex) }
    var secondary: Color { Color(hex: secondaryHex) }

    /// ตารางสีมงคลประจำวัน (จันทร์-อาทิตย์ รวมพุธกลางคืน/ราหู)
    private static let table: [Int: AuspiciousColor] = [
        1: AuspiciousColor(thaiDayName: "วันอาทิตย์", colorName: "สีแดง", primaryHex: "#E4392C", secondaryHex: "#FF7A5C"),
        2: AuspiciousColor(thaiDayName: "วันจันทร์", colorName: "สีเหลือง", primaryHex: "#F5C400", secondaryHex: "#FFE985"),
        3: AuspiciousColor(thaiDayName: "วันอังคาร", colorName: "สีชมพู", primaryHex: "#F286B0", secondaryHex: "#FFC1DD"),
        4: AuspiciousColor(thaiDayName: "วันพุธ (กลางวัน)", colorName: "สีเขียว", primaryHex: "#3FA34D", secondaryHex: "#8DD98A"),
        5: AuspiciousColor(thaiDayName: "วันพฤหัสบดี", colorName: "สีส้ม", primaryHex: "#F5822B", secondaryHex: "#FFC078"),
        6: AuspiciousColor(thaiDayName: "วันศุกร์", colorName: "สีฟ้า", primaryHex: "#3FA9E0", secondaryHex: "#A8DCF7"),
        7: AuspiciousColor(thaiDayName: "วันเสาร์", colorName: "สีม่วง", primaryHex: "#7B4EA3", secondaryHex: "#C6A6E0"),
    ]

    /// วันพุธกลางคืน (ราหู) นับตั้งแต่ 18:00 น. เป็นต้นไป ใช้สีเขียวเข้ม/เทา
    private static let wednesdayNight = AuspiciousColor(
        thaiDayName: "วันพุธ (กลางคืน)",
        colorName: "สีเขียวเข้ม (ราหู)",
        primaryHex: "#1F3D2B",
        secondaryHex: "#4A6B57"
    )

    /// คืนค่าสีมงคลของ "วันนี้" ตามเวลาปัจจุบัน (พุธกลางวัน/กลางคืนแยกกัน)
    static func forNow(_ date: Date = Date(), calendar: Calendar = .current) -> AuspiciousColor {
        let weekday = calendar.component(.weekday, from: date) // 1 = Sunday ... 7 = Saturday
        let hour = calendar.component(.hour, from: date)
        if weekday == 4, hour >= 18 || hour < 6 {
            return wednesdayNight
        }
        return table[weekday] ?? table[1]!
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
