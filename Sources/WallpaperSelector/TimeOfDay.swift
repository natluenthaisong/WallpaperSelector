import SwiftUI

/// ช่วงเวลาของวัน ใช้ปรับความสว่าง/บรรยากาศของพื้นหลังให้เปลี่ยนไปตามเวลา
enum TimeOfDay: String {
    case morning   // 06:00 - 11:59
    case afternoon // 12:00 - 16:59
    case evening   // 17:00 - 19:59
    case night     // 20:00 - 05:59

    static func now(_ date: Date = Date(), calendar: Calendar = .current) -> TimeOfDay {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 6..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<20: return .evening
        default: return .night
        }
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }

    var label: String {
        switch self {
        case .morning: return "เช้า"
        case .afternoon: return "บ่าย"
        case .evening: return "เย็น"
        case .night: return "กลางคืน"
        }
    }

    /// ระดับความมืดที่ overlay ทับพื้นหลังไล่สี (0 = ไม่มืด, 1 = มืดสุด)
    var darkOverlay: Double {
        switch self {
        case .morning: return 0.0
        case .afternoon: return 0.0
        case .evening: return 0.18
        case .night: return 0.45
        }
    }
}
