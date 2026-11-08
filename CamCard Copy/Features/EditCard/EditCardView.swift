import ImageIO
import SwiftUI
import UIKit

struct EditCardView: View {
    let image: ScannedCardImage
    let onRetake: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        VStack(spacing: 16) {
            cardImage
            fullNameRow
            Spacer()
        }
        .padding()
        .navigationTitle("Edit Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Retake", action: onRetake)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {}
                    .disabled(true)
            }
        }
        .task(id: image) {
            // Decode once, off the main actor, at display size. Decoding the
            // full-resolution capture in body blocks the navigation push.
            thumbnail = await Self.makeThumbnail(
                from: image.processedImage ?? image.originalImage
            )
        }
    }

    private var cardImage: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Color(white: 0.2)
                    .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var fullNameRow: some View {
        HStack {
            Text("Full Name")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .accessibilityIdentifier("editCard.fullName")
    }

    /// Renders a display-sized thumbnail without touching the stored data.
    nonisolated private static func makeThumbnail(
        from data: Data,
        maxPixelSize: Int = 1500
    ) async -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
