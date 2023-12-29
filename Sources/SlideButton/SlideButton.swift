//
//  SlideButton.swift
//  SlideButton by NO-COMMENT
//

import SwiftUI

/// A view that presents a slide button that can be swiped to unlock or perform an action.
public struct SlideButton<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    private let title: Label
    private let callback: () async -> Void

    public typealias Styling = SlideButtonStyling
    private let styling: Styling

    @GestureState private var offset: CGFloat
    @State private var swipeState: SwipeState = .start

    @Environment(\.layoutDirection) private var layoutDirection

    // When layoutdirection is RTL, the indicatorshape will be right aligned
    // instead of left aligned and values need to be negated
    private var layoutDirectionMultiplier: Double {
        self.layoutDirection == .rightToLeft ? -1 : 1
    }

    /// Initializes a slide button with the given title, styling options, and action.
    ///
    /// Use this initializer to create a new instance of `SlideButton` with the given title, styling, and callback. The `styling` parameter allows you to customize the appearance of the slide button, such as changing the size and color of the indicator, the alignment of the title text, and whether the text fades or hides behind the indicator. The `action` parameter is executed when the user successfully swipes the indicator.
    ///
    /// - Parameters:
    ///   - styling: The styling options to customize the appearance of the slide button. Default is `.default`.
    ///   - action: The async callback action that is executed when the user successfully swipes the indicator.
    ///   - label: The function creating a label view
    public init(styling: Styling = .default, action: @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self.title = label()
        self.callback = action
        self.styling = styling

        self._offset = .init(initialValue: styling.indicatorSpacing)
    }

    @ViewBuilder
    private var indicatorShape: some View {
        switch styling.indicatorShape {
        case .circular:
            Circle()
        case let .rectangular(cornerRadius):
            RoundedRectangle(cornerRadius: max(0, (cornerRadius ?? 0) - styling.indicatorSpacing))
        }
    }

    @ViewBuilder
    private var mask: some View {
        switch styling.indicatorShape {
        case .circular:
            Capsule()
        case let .rectangular(cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius ?? 0)
        }
    }

    public var body: some View {
        GeometryReader { reading in
            let calculatedOffset: CGFloat = swipeState == .swiping ? offset : (swipeState == .start ? styling.indicatorSpacing : (reading.size.width - styling.indicatorSize + styling.indicatorSpacing))
            ZStack(alignment: .leading) {
                styling.backgroundColor
                    .saturation(isEnabled ? 1 : 0)

                ZStack {
                    if styling.textAlignment == .globalCenter {
                        title
                            .multilineTextAlignment(styling.textAlignment.textAlignment)
                            .foregroundColor(styling.textColor)
                            .frame(maxWidth: max(0, reading.size.width - 2 * styling.indicatorSpacing), alignment: .center)
                            .padding(.horizontal, styling.indicatorSize)
                            .shimmerEffect(isEnabled && styling.textShimmers)
                    } else {
                        title
                            .multilineTextAlignment(styling.textAlignment.textAlignment)
                            .foregroundColor(styling.textColor)
                            .frame(maxWidth: max(0, reading.size.width - 2 * styling.indicatorSpacing), alignment: Alignment(horizontal: styling.textAlignment.horizontalAlignment, vertical: .center))
                            .padding(.trailing, styling.indicatorSpacing)
                            .padding(.leading, styling.indicatorSize)
                            .shimmerEffect(isEnabled && styling.textShimmers)
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

                indicatorShape
                    .brightness(isEnabled ? styling.indicatorBrightness : 0)
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
                                .rotationEffect(Angle(degrees: styling.indicatorRotatesForRTL && self.layoutDirection == .rightToLeft ? 180 : 0))
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

                                let val = value.translation.width * layoutDirectionMultiplier

                                state = clampValue(value: val, min: styling.indicatorSpacing, max: reading.size.width - styling.indicatorSize + styling.indicatorSpacing)
                            }
                            .onEnded { value in
                                guard swipeState == .swiping else { return }
                                swipeState = .end

                                let predictedVal = value.predictedEndTranslation.width * layoutDirectionMultiplier
                                let val = value.translation.width * layoutDirectionMultiplier

                                if predictedVal > reading.size.width
                                    || val > reading.size.width - styling.indicatorSize - 2 * styling.indicatorSpacing {
                                    Task {
                                        #if os(iOS)
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        #endif

                                        await callback()
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
            .mask({ mask })
        }
        .frame(height: styling.indicatorSize)
        .accessibilityRepresentation {
            Button(action: {
                swipeState = .end

                Task {
                    await callback()
                    swipeState = .start
                }
            }, label: {
                title
            })
            .disabled(swipeState != .start)
        }
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
}

public extension SlideButton where Label == Text {
    @available(*, deprecated, renamed: "init(_:styling:action:)")
    init(_ titleKey: LocalizedStringKey, styling: Styling = .default, callback: @escaping () async -> Void) {
        self.init(styling: styling, action: callback, label: { Text(titleKey) })
    }

    init(_ titleKey: LocalizedStringKey, styling: Styling = .default, action: @escaping () async -> Void) {
        self.init(styling: styling, action: action, label: { Text(titleKey) })
    }

    @available(*, deprecated, renamed: "init(_:styling:action:)")
    init<S>(_ title: S, styling: Styling = .default, callback: @escaping () async -> Void) where S: StringProtocol {
        self.init(styling: styling, action: callback, label: { Text(title) })
    }

    init<S>(_ title: S, styling: Styling = .default, action: @escaping () async -> Void) where S: StringProtocol {
        self.init(styling: styling, action: action, label: { Text(title) })
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
                        SlideButton("Centered text and lorem ipsum dolor sit", action: sliderCallback)
                        SlideButton("Leading text and no fade", styling: .init(textAlignment: .leading, textFadesOpacity: false), action: sliderCallback)
                        SlideButton("Center text and no mask", styling: .init(textHiddenBehindIndicator: false), action: sliderCallback)
                        SlideButton("Remaining space center", styling: .init(indicatorColor: .red, indicatorSystemName: "trash"), action: sliderCallback)
                        SlideButton("Trailing and immediate response", styling: .init(textAlignment: .trailing), action: sliderCallback)
                        SlideButton("Global center", styling: .init(indicatorColor: .red, indicatorSystemName: "trash", textAlignment: .globalCenter, textShimmers: true), action: sliderCallback)
                        SlideButton("Spacing 15", styling: .init(indicatorSpacing: 15), action: sliderCallback)
                        SlideButton("Big", styling: .init(indicatorSize: 100), action: sliderCallback)
                        SlideButton("disabled green", styling: .init(indicatorColor: .green), action: sliderCallback)
                            .disabled(true)
                        SlideButton("disabled", action: sliderCallback)
                            .disabled(true)
                    }.padding(.horizontal)
                }
            }

            private func sliderCallback() async {
                try? await Task.sleep(for: .seconds(2))
            }
        }

        static var previews: some View {
            ContentView()
        }
    }
#endif
