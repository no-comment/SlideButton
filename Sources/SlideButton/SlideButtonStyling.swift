//
//  SlideButtonStyling.swift
//  SlideButton by NO-COMMENT
//

import SwiftUI

///  A struct that defines the styling options for a `SlideButton`.
public struct SlideButtonStyling {
    /// Initializes a new `Styling` instance with the given options.
    /// - Parameters:
    ///   - indicatorSize: The size of the indicator. Default is `60`.
    ///   - indicatorSpacing: The spacing between the indicator and the border / button title. Default is `5`.
    ///   - indicatorColor: The color of the indicator. Default is `.accentColor`.
    ///   - indicatorShape: The shape type of the indicator. Default is `.circular`.
    ///   - indicatorRotatesForRTL: Whether to rotate the indicator for right-to-left layout or not. Default is `true`.
    ///   - indicatorBrightness: The brightness of the indicator if enabled. Default is `0.0`.
    ///   - backgroundColor: The color of the background. Default is `nil`, which sets the background color to a 30% opacity version of the indicator color.
    ///   - textColor: The color of the title text. Default is `.secondary`.
    ///   - indicatorSystemName: The system name of the icon used for the indicator. Default is `"chevron.right"`.
    ///   - indicatorDisabledSystemName: The system name of the icon used for the disabled indicator. Default is `"xmark"`.
    ///   - textAlignment: The alignment of the title text. Default is `.center`.
    ///   - textFadesOpacity: A Boolean value that determines whether the title text fades as the indicator is dragged. Default is `true`.
    ///   - textHiddenBehindIndicator: A Boolean value that determines whether the part of the title text that the indicator passes disappears. Default is `true`.
    ///   - textShimmers: A Boolean value that determines whether the text should have a shimmering effect. Default is `true`.
    public init(
        indicatorSize: CGFloat = 60,
        indicatorSpacing: CGFloat = 5,
        indicatorColor: Color = .accentColor,
        indicatorShape: ShapeType = .circular,
        indicatorRotatesForRTL: Bool = true,
        indicatorBrightness: Double = 0.0,
        backgroundColor: Color? = nil,
        textColor: Color = .secondary,
        indicatorSystemName: String = "chevron.right",
        indicatorDisabledSystemName: String = "xmark",
        textAlignment: SlideTextAlignment = .center,
        textFadesOpacity: Bool = true,
        textHiddenBehindIndicator: Bool = true,
        textShimmers: Bool = false
    ) {
        self.indicatorSize = indicatorSize
        self.indicatorSpacing = indicatorSpacing
        self.indicatorShape = indicatorShape
        self.indicatorBrightness = indicatorBrightness
        self.indicatorRotatesForRTL = indicatorRotatesForRTL

        self.indicatorColor = indicatorColor
        self.backgroundColor = backgroundColor ?? indicatorColor.opacity(0.3)
        self.textColor = textColor

        self.indicatorSystemName = indicatorSystemName
        self.indicatorDisabledSystemName = indicatorDisabledSystemName
        self.textAlignment = textAlignment
        self.textFadesOpacity = textFadesOpacity
        self.textHiddenBehindIndicator = textHiddenBehindIndicator
        self.textShimmers = textShimmers
    }

    var indicatorSize: CGFloat
    var indicatorSpacing: CGFloat
    var indicatorShape: ShapeType
    var indicatorRotatesForRTL: Bool
    var indicatorBrightness: Double

    var indicatorColor: Color
    var backgroundColor: Color
    var textColor: Color

    var indicatorSystemName: String
    var indicatorDisabledSystemName: String

    var textAlignment: SlideTextAlignment
    var textFadesOpacity: Bool
    var textHiddenBehindIndicator: Bool
    var textShimmers: Bool

    public static let `default`: Self = .init()
}

public enum ShapeType {
    case circular, rectangular(cornerRadius: Double? = 0)
}

///  An enumeration that defines the alignment options for the title text in a `SlideButton`.
public enum SlideTextAlignment {
    /// The title text is aligned to the leading edge of the title space.
    case leading
    /// The title text is aligned to the center of the button, not shifted for the indicator.
    case globalCenter
    /// The title text is aligned to the horizontal center of the title space.
    case center
    /// The title text is aligned to the trailing edge of the title space.
    case trailing

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .leading:
            return .leading
        case .center, .globalCenter:
            return .center
        case .trailing:
            return .trailing
        }
    }

    var textAlignment: TextAlignment {
        switch self {
        case .leading:
            return .leading
        case .center, .globalCenter:
            return .center
        case .trailing:
            return .trailing
        }
    }
}
