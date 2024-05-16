import Foundation

struct OsVersion {
    let os: String
    let version: String
}

extension OsVersion {
    func toMsg() -> [String: String] {
        ["os": os, "version": version]
    }
}
