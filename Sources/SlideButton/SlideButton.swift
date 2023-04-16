//
//  SlideButton.swift
//  SlideButton by NO-COMMENT
//

import SwiftUI

/// A view that presents a slide button that can be swiped to unlock or perform an action.
public struct SlideButton: View {
    @Environment(\.isEnabled) private var isEnabled
    
    private let title: String
    private let callback: (() async -> Bool?)
    
    private let styling: Styling
    
    @GestureState private var offset: CGFloat
    @State private var swipeState: SwipeState = .start
    
    /// Initializes a slide button with the given title, styling options, and callback.
    ///
    /// Use this initializer to create a new instance of `SlideButton` with the given title, styling, and callback. The `styling` parameter allows you to customize the appearance of the slide button, such as changing the size and color of the indicator, the alignment of the title text, and whether the text fades or hides behind the indicator. The `callback` parameter is executed when the user successfully swipes the indicator, and returns a `Bool?` value that determines whether to provide success/error haptic feedback.
    ///
    /// - Parameters:
    ///   - title: The title of the slide button.
    ///   - styling: The styling options to customize the appearance of the slide button. Default is `.default`.
    ///   - callback: The async callback that is executed when the user successfully swipes the indicator. The callback returns a `Bool?` value that determines whether to provide success/error haptic feedback.
    public init(_ title: String, styling: Styling = .default, callback: @escaping () async -> Bool?) {
        self.title = title
        self.callback = callback
        self.styling = styling
        
        self._offset = .init(initialValue: styling.indicatorSpacing)
    }
    
    /// Initializes a slide button with the given title, styling options, and callback.
    ///
    /// Use this initializer to create a new instance of `SlideButton` with the given title, styling, and callback. The `styling` parameter allows you to customize the appearance of the slide button, such as changing the size and color of the indicator, the alignment of the title text, and whether the text fades or hides behind the indicator. The `callback` parameter is executed when the user successfully swipes the indicator.
    ///
    /// - Parameters:
    ///   - title: The title of the slide button.
    ///   - styling: The styling options to customize the appearance of the slide button. Default is `.default`.
    ///   - callback: The async callback that is executed when the user successfully swipes the indicator.
    public init(_ title: String, styling: Styling = .default, callback: @escaping () async -> Void) {
        self.title = title
        self.callback = {
            await callback()
            return nil
        }
        self.styling = styling
        
        self._offset = .init(initialValue: styling.indicatorSpacing)
    }
    
    public var body: some View {
        GeometryReader { reading in
            let calculatedOffset: CGFloat = swipeState == .swiping ? offset : (swipeState == .start ? styling.indicatorSpacing : (reading.size.width - styling.indicatorSize + styling.indicatorSpacing))
            ZStack(alignment: .leading) {
                styling.backgroundColor
                    .saturation(isEnabled ? 1 : 0)
                
                ZStack {
                    if styling.textAlignment == .globalCenter {
                        Text(title)
                            .multilineTextAlignment(styling.textAlignment.textAlignment)
                            .foregroundColor(styling.textColor)
                            .frame(maxWidth: reading.size.width - 2 * styling.indicatorSpacing, alignment: .center)
                            .padding(.horizontal, styling.indicatorSize)
                    } else {
                        Text(title)
                            .multilineTextAlignment(styling.textAlignment.textAlignment)
                            .foregroundColor(styling.textColor)
                            .frame(maxWidth: reading.size.width - 2 * styling.indicatorSpacing, alignment: Alignment(horizontal: styling.textAlignment.horizontalAlignment, vertical: .center))
                            .padding(.trailing, styling.indicatorSpacing)
                            .padding(.leading, styling.indicatorSize)
                    }
                }
                .opacity(styling.textFadesOpacity ? (1 - progress(from: styling.indicatorSpacing, to: reading.size.width - styling.indicatorSize + styling.indicatorSpacing, current: calculatedOffset)) : 1)
                .animation(.interactiveSpring(), value: calculatedOffset)
                .mask {
                    if styling.textHiddenBehindIndicator {
                        Rectangle()
                            .overlay(alignment: .leading) {
                                Color.red
                                    .frame(width: calculatedOffset + (0.5 * styling.indicatorSize - styling.indicatorSpacing))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .animation(.interactiveSpring(), value: swipeState)
                                    .blendMode(.destinationOut)
                            }
                    } else {
                        Rectangle()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Circle()
                    .frame(width: styling.indicatorSize - 2 * styling.indicatorSpacing, height: styling.indicatorSize - 2 * styling.indicatorSpacing)
                    .foregroundColor(isEnabled ? styling.indicatorColor : .gray)
                    .overlay(content: {
                        ZStack {
                            ProgressView().progressViewStyle(.circular)
                                .tint(.white)
                                .opacity(swipeState == .end ? 1 : 0)
                            Image(systemName: isEnabled ? styling.indicatorSystemName : styling.indicatorDisabledSystemName)
                                .foregroundColor(.white)
                                .font(.system(size: max(0.4 * styling.indicatorSize, 0.5 * styling.indicatorSize - 2 * styling.indicatorSpacing), weight: .semibold))
                                .opacity(swipeState == .end ? 0 : 1)
                        }
                    })
                    .offset(x: calculatedOffset)
                    .animation(.interactiveSpring(), value: swipeState)
                    .gesture(
                        DragGesture()
                            .updating($offset) { value, state, transaction in
                                guard swipeState != .end else { return }
                                
                                if swipeState == .start {
                                    DispatchQueue.main.async {
                                        swipeState = .swiping
                                        #if os(iOS)
                                        UIImpactFeedbackGenerator(style: .light).prepare()
                                        #endif
                                    }
                                }
                                state = clampValue(value: value.translation.width, min: styling.indicatorSpacing, max: reading.size.width - styling.indicatorSize + styling.indicatorSpacing)
                            }
                            .onEnded { value in
                                guard swipeState == .swiping else { return }
                                swipeState = .end
                                
                                if value.predictedEndTranslation.width > reading.size.width
                                    || value.translation.width > reading.size.width - styling.indicatorSize - 2 * styling.indicatorSpacing {
                                    Task {
                                        #if os(iOS)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        let successFeedbackGenerator = UINotificationFeedbackGenerator()
                                        successFeedbackGenerator.prepare()
                                        #endif
                                        
                                        if let success = await callback() {
                                            #if os(iOS)
                                            successFeedbackGenerator.notificationOccurred(success ? .success : .error)
                                            #endif
                                        }
                                        
                                        swipeState = .start
                                    }
                                } else {
                                    swipeState = .start
                                    #if os(iOS)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    #endif
                                }
                            }
                    )
            }
            .mask({ Capsule() })
        }
        .frame(height: styling.indicatorSize)
    }
    
    private func clampValue(value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        return max(minValue, min(maxValue, value))
    }
    
    private func progress(from start: Double, to end: Double, current: Double) -> Double {
        let clampedCurrent = max(min(current, end), start)
        return (clampedCurrent - start) / (end - start)
    }
    
    private enum SwipeState {
        case start, swiping, end
    }
    
    ///  A struct that defines the styling options for a `SlideButton`.
    public struct Styling {
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
        public init(
            indicatorSize: CGFloat = 60,
            indicatorSpacing: CGFloat = 5,
            indicatorColor: Color = .accentColor,
            backgroundColor: Color? = nil,
            textColor: Color = .secondary,
            indicatorSystemName: String = "chevron.right",
            indicatorDisabledSystemName: String = "xmark",
            textAlignment: SlideTextAlignment = .center,
            textFadesOpacity: Bool = true,
            textHiddenBehindIndicator: Bool = true
        ) {
            self.indicatorSize = indicatorSize
            self.indicatorSpacing = indicatorSpacing
            
            self.indicatorColor = indicatorColor
            self.backgroundColor = backgroundColor ?? indicatorColor.opacity(0.3)
            self.textColor = textColor
            
            self.indicatorSystemName = indicatorSystemName
            self.indicatorDisabledSystemName = indicatorDisabledSystemName
            self.textAlignment = textAlignment
            self.textFadesOpacity = textFadesOpacity
            self.textHiddenBehindIndicator = textHiddenBehindIndicator
        }
        
        fileprivate var indicatorSize: CGFloat
        fileprivate var indicatorSpacing: CGFloat
        
        fileprivate var indicatorColor: Color
        fileprivate var backgroundColor: Color
        fileprivate var textColor: Color
        
        fileprivate var indicatorSystemName: String
        fileprivate var indicatorDisabledSystemName: String
        
        fileprivate var textAlignment: SlideTextAlignment
        fileprivate var textFadesOpacity: Bool
        fileprivate var textHiddenBehindIndicator: Bool
        
        public static let `default`: Self = .init()
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
        
        fileprivate var horizontalAlignment: HorizontalAlignment {
            switch self {
            case .leading:
                return .leading
            case .center, .globalCenter:
                return .center
            case .trailing:
                return .trailing
            }
        }
        
        fileprivate var textAlignment: TextAlignment {
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

#if DEBUG
@available(iOS 16.0, *)
@available(macOS 16.0, *)
struct SlideButton_Previews: PreviewProvider {
    struct ContentView: View {
        var body: some View {
            ScrollView {
                VStack(spacing: 25) {
                    SlideButton("Centered text and lorem ipsum dolor sit", callback: sliderCallback)
                    SlideButton("Leading text and no fade", styling: .init(textAlignment: .leading, textFadesOpacity: false), callback: sliderCallback)
                    SlideButton("Center text and no mask", styling: .init(textHiddenBehindIndicator: false), callback: sliderCallback)
                    SlideButton("Remaining space center", styling: .init(indicatorColor: .red, indicatorSystemName: "trash"), callback: sliderCallback)
                    SlideButton("Trailing and immediate response", styling: .init(textAlignment: .trailing), callback: { .random() })
                    SlideButton("Global center", styling: .init(indicatorColor: .red, indicatorSystemName: "trash", textAlignment: .globalCenter), callback: sliderCallback)
                    SlideButton("Spacing 15", styling: .init(indicatorSpacing: 15), callback: sliderCallback)
                    SlideButton("Big", styling: .init(indicatorSize: 100), callback: sliderCallback)
                    SlideButton("disabled green", styling: .init(indicatorColor: .green), callback: sliderCallback)
                        .disabled(true)
                    SlideButton("disabled", callback: sliderCallback)
                        .disabled(true)
                }.padding(.horizontal)
            }
        }
        
        private func sliderCallback() async -> Bool? {
            try? await Task.sleep(for: .seconds(2))
            return .random()
        }
    }

    static var previews: some View {
        ContentView()
    }
}
#endif
