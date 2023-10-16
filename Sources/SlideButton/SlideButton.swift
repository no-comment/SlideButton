//
//  SlideButton.swift
//  SlideButton by NO-COMMENT
//

import SwiftUI

//this maintains backcompat
public struct SlideButton: View {
    public var title: String
    public var styling: Styling = .default
    public var callback: () async -> Void
    
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
        self.styling = styling
        self.callback = callback
    }
    
    public var body: some View {
        GenericSlideButton(Text(title), styling: styling, callback: callback)
        
    }
    
    
}
/// A view that presents a slide button that can be swiped to unlock or perform an action.
public struct GenericSlideButton<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    public typealias Styling = SlideButton.Styling
    
    @ViewBuilder  private let title: Label
    private let callback: () async -> Void
    
    private let styling: Styling
    
    @GestureState private var offset: CGFloat
    @State private var swipeState: SwipeState = .start
    
    /// Initializes a slide button with the given title, styling options, and callback.
    ///
    /// Use this initializer to create a new instance of `SlideButton` with the given title, styling, and callback. The `styling` parameter allows you to customize the appearance of the slide button, such as changing the size and color of the indicator, the alignment of the title text, and whether the text fades or hides behind the indicator. The `callback` parameter is executed when the user successfully swipes the indicator.
    ///
    /// - Parameters:
    ///   - title: The title of the slide button.
    ///   - styling: The styling options to customize the appearance of the slide button. Default is `.default`.
    ///   - callback: The async callback that is executed when the user successfully swipes the indicator.
    public init(_ title: Label, styling: Styling = .default, callback: @escaping () async -> Void) {
        self.title = title
        self.callback = callback
        self.styling = styling
        
        self._offset = .init(initialValue: styling.indicatorSpacing)
    }
    
    
    @ViewBuilder
    private var indicatorShape : some View {
        switch styling.indicatorShape {
        case .circular:
            Circle()
        case .rectangular:
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
        }
        
    }
    
    @ViewBuilder
    private var mask : some View {
        switch styling.indicatorShape {
        case .circular:
            Capsule()
        case .rectangular:
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
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
                    SlideButton("Trailing and immediate response", styling: .init(textAlignment: .trailing), callback: sliderCallback)
                    SlideButton("Global center", styling: .init(indicatorColor: .red, indicatorSystemName: "trash", textAlignment: .globalCenter, textShimmers: true), callback: sliderCallback)
                    SlideButton("Spacing 15", styling: .init(indicatorSpacing: 15), callback: sliderCallback)
                    SlideButton("Big", styling: .init(indicatorSize: 100), callback: sliderCallback)
                    SlideButton("disabled green", styling: .init(indicatorColor: .green), callback: sliderCallback)
                        .disabled(true)
                    SlideButton("disabled", callback: sliderCallback)
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
