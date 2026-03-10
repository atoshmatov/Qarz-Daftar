import Foundation
import UIKit

enum AvatarStorage {
    static func loadImage(path: String) -> UIImage? {
        guard path.isEmpty == false else { return nil }
        return UIImage(contentsOfFile: path)
    }

    static func saveImage(data: Data, previousPath: String?) throws -> String {
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.86) else {
            throw CocoaError(.fileWriteUnknown)
        }

        let directoryURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("avatars", isDirectory: true)

        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let fileURL = directoryURL.appendingPathComponent("avatar-\(UUID().uuidString).jpg")
        try jpegData.write(to: fileURL, options: .atomic)

        if let previousPath, previousPath.isEmpty == false {
            try? FileManager.default.removeItem(atPath: previousPath)
        }

        return fileURL.path
    }

    static func remove(path: String) {
        guard path.isEmpty == false else { return }
        try? FileManager.default.removeItem(atPath: path)
    }
}
