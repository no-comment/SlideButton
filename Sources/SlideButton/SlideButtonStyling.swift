//
//  SlideButtonStyling.swift
//  SlideButton by NO-COMMENT
//

import SwiftUI

public extension SlideButton {
    ///  A struct that defines the styling options for a `SlideButton`.
    struct Styling {
        /// Initializes a new `Styling` instance with the given options.
        /// - Parameters:
        ///   - indicatorSize: The size of the indicator. Default is `60`.
        ///   - indicatorSpacing: The spacing between the indicator and the border / button title. Default is `5`.
        ///   - indicatorColor: The color of the indicator. Default is `.accentColor`.
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
            indicatorBrightness : Double = 0.0,
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
        
        internal var indicatorSize: CGFloat
        internal var indicatorSpacing: CGFloat
        internal var indicatorShape: ShapeType
        internal var indicatorBrightness: Double
        
        internal var indicatorColor: Color
        internal var backgroundColor: Color
        internal var textColor: Color
        
        internal var indicatorSystemName: String
        internal var indicatorDisabledSystemName: String
        
        internal var textAlignment: SlideTextAlignment
        internal var textFadesOpacity: Bool
        internal var textHiddenBehindIndicator: Bool
        internal var textShimmers: Bool
        
        public static let `default`: Self = .init()
        
    }
    
    enum ShapeType: Int {
        case circular, rectangular
        
    }
    
    
    
    ///  An enumeration that defines the alignment options for the title text in a `SlideButton`.
    enum SlideTextAlignment {
        /// The title text is aligned to the leading edge of the title space.
        case leading
        /// The title text is aligned to the center of the button, not shifted for the indicator.
        case globalCenter
        /// The title text is aligned to the horizontal center of the title space.
        case center
        /// The title text is aligned to the trailing edge of the title space.
        case trailing
        
        internal var horizontalAlignment: HorizontalAlignment {
            switch self {
            case .leading:
                return .leading
            case .center, .globalCenter:
                return .center
            case .trailing:
                return .trailing
            }
        }
        
        internal var textAlignment: TextAlignment {
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
}
