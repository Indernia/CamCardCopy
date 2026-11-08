import Foundation
import UIKit

/// Generated fixtures only. No CamCard artwork is reproduced.
enum ScanFixtureFactory {
    static let referenceSize = CGSize(width: 1200, height: 1600)

    /// A light card rotated on a dark background, for rectangle detection.
    static func cardImageData(size: CGSize = referenceSize) -> Data {
        render(size: size) { context, bounds in
            UIColor(white: 0.16, alpha: 1).setFill()
            context.fill(bounds)

            let cardWidth = size.width * 0.78
            let cardHeight = cardWidth / 1.58
            let cardRect = CGRect(
                x: -cardWidth / 2,
                y: -cardHeight / 2,
                width: cardWidth,
                height: cardHeight
            )

            context.cgContext.saveGState()
            context.cgContext.translateBy(x: size.width / 2, y: size.height / 2)
            context.cgContext.rotate(by: .pi / 16)

            let path = UIBezierPath(roundedRect: cardRect, cornerRadius: 24)
            UIColor(white: 0.97, alpha: 1).setFill()
            path.fill()
            path.lineWidth = 4
            UIColor(white: 0.55, alpha: 1).setStroke()
            path.stroke()

            context.cgContext.restoreGState()
        }
    }

    /// A plain gradient with no card rectangle.
    static func noCardImageData(size: CGSize = referenceSize) -> Data {
        render(size: size) { context, bounds in
            let colors = [
                UIColor(white: 0.20, alpha: 1).cgColor,
                UIColor(white: 0.42, alpha: 1).cgColor
            ]
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            ) else { return }
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: bounds.width, y: bounds.height),
                options: []
            )
        }
    }

    /// Neutral tiles used as extra album thumbnails.
    static func photoImageData(index: Int, size: CGSize = CGSize(width: 600, height: 600)) -> Data {
        render(size: size) { context, bounds in
            let hue = CGFloat(index % 6) / 6
            UIColor(hue: hue, saturation: 0.35, brightness: 0.65, alpha: 1).setFill()
            context.fill(bounds)
            UIColor(white: 0.95, alpha: 1).setFill()
            context.fill(bounds.insetBy(dx: bounds.width * 0.3, dy: bounds.height * 0.3))
        }
    }

    private static func render(
        size: CGSize,
        drawing: (UIGraphicsImageRendererContext, CGRect) -> Void
    ) -> Data {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            drawing(context, CGRect(origin: .zero, size: size))
        }
        return image.jpegData(compressionQuality: 0.95) ?? Data()
    }
}

/// Fixture photos for the fake album, including the generated card and no-card images.
enum PhotoFixtureFactory {
    static let cardAssetID = "fixture.card"
    static let noCardAssetID = "fixture.no-card"

    static func makeLibrary(
        accessState: PhotoAccessState,
        resolvedState: PhotoAccessState? = .full
    ) -> FakePhotoLibrary {
        let card = ScanFixtureFactory.cardImageData()
        let noCard = ScanFixtureFactory.noCardImageData()
        let extra = (0..<4).map { index in
            PhotoAsset(
                id: "fixture.photo.\(index)",
                thumbnailData: ScanFixtureFactory.photoImageData(index: index)
            )
        }
        let assets = [
            PhotoAsset(id: cardAssetID, thumbnailData: card),
            PhotoAsset(id: noCardAssetID, thumbnailData: noCard)
        ] + extra

        return FakePhotoLibrary(
            accessState: accessState,
            resolvedState: resolvedState,
            albums: [
                PhotoAlbum(id: "recents", title: "Recents", isRecents: true),
                PhotoAlbum(id: "fixture.album.1", title: "Business Cards", isRecents: false),
                PhotoAlbum(id: "fixture.album.2", title: "", isRecents: false)
            ],
            assets: assets,
            imageData: [cardAssetID: card, noCardAssetID: noCard]
        )
    }
}

