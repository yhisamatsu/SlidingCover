import SwiftUI

@available(iOS 13.0, *)
public struct SlidingCoverConfig {
    public let direction: SlidingDirection
    public let amount: CGFloat
    public let animation: Animation?
    
    public init(
        direction: SlidingDirection,
        amount: CGFloat,
        animation: Animation? = .easeOut
    ) {
        self.direction = direction
        self.amount = amount
        self.animation = animation
    }
}

@available(iOS 13.0, *)
public enum SlidingDirection {
    case down
    case up
    case right
    case left
    
    func toAlignment(layoutDirection: LayoutDirection = .leftToRight) -> Alignment {
        switch self {
        case .down:
            return .top
        case .up:
            return .bottom
        case .right:
            return layoutDirection == .leftToRight ? .leading : .trailing
        case .left:
            return layoutDirection == .leftToRight ? .trailing : .leading
        }
    }
}

@available(iOS 13.0, *)
private struct SlidingSize {
    let direction: SlidingDirection
    let amount: CGFloat
    let originalSize: CGSize
    private var rangedAmount: CGFloat {
        min(1.0, max(0.0, amount))
    }
    var width: CGFloat {
        switch direction {
        case .down, .up:
            return originalSize.width
        case .right, .left:
            return originalSize.width * (1.0 - rangedAmount)
        }
    }
    var height: CGFloat {
        switch direction {
        case .down, .up:
            return originalSize.height * (1.0 - rangedAmount)
        case .right, .left:
            return originalSize.height
        }
    }
    var offsetX: CGFloat {
        switch direction {
        case .down, .up:
            return 0.0
        case .right:
            return originalSize.width - width
        case .left:
            return width - originalSize.width
        }
    }
    var offsetY: CGFloat {
        switch direction {
        case .down:
            return originalSize.height - height
        case .up:
            return height - originalSize.height
        case .right, .left:
            return 0.0
        }
    }
}

@available(iOS 13.0, *)
public struct SlidingCover<SlidingView: View, CoveredView: View>: View {
    public var config: SlidingCoverConfig = SlidingCoverConfig(
        direction: .down,
        amount: 0.33
    )
    @Binding public var isSlided: Bool
    public var sliding: () -> SlidingView
    public var covered: () -> CoveredView
    
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    
    public init(
        config: SlidingCoverConfig?,
        isSlided: Binding<Bool>,
        sliding: @escaping () -> SlidingView,
        covered: @escaping () -> CoveredView
    ) {
        if let config = config {
            self.config = config
        }
        self._isSlided = isSlided
        self.sliding = sliding
        self.covered = covered
    }
    
    public var body: some View {
        GeometryReader { g in
            let slidingSize = SlidingSize(
                direction: config.direction,
                amount: config.amount,
                originalSize: g.size
            )
            let alignment = config.direction.toAlignment(layoutDirection: layoutDirection)
            let offsetX = isSlided ? slidingSize.offsetX : 0.0
            let offsetY = isSlided ? slidingSize.offsetY : 0.0
            let width = isSlided ? slidingSize.width : g.size.width
            let height = isSlided ? slidingSize.height : g.size.height
            
            ZStack(alignment: alignment) {
                covered()
                sliding()
                    .offset(
                        x: offsetX, y: offsetY
                    )
                    .frame(
                        width: width, height: height
                    )
                    .animation(config.animation, value: isSlided)
            }
        }
    }
}

struct SlidingCover_Previews: PreviewProvider {
    
    @available(iOS 13.0, *)
    struct PreviewView: View {
        @State var isSlided = false
        var body: some View {
            let frontView = rect("Front", .green)
                .opacity(0.5)
            let backView = rect("Back", .yellow, .bottom)
            let width = 200.0
            let height = 200.0
            
            VStack {
                Toggle("Is slided", isOn: $isSlided)
                    .frame(width: width, height: height)
                
                HStack {
                    SlidingCover(
                        config: SlidingCoverConfig(
                            direction: .down, amount: 0.4
                        ),
                        isSlided: $isSlided,
                        sliding: { frontView },
                        covered: { backView }
                    )
                    .frame(width: width, height: height)
                    
                    SlidingCover(
                        config: SlidingCoverConfig(
                            direction: .up, amount: 0.33,
                            animation: .easeInOut(duration: 0.5)
                        ),
                        isSlided: $isSlided,
                        sliding: { frontView },
                        covered: { backView }
                    )
                    .frame(width: width, height: height)
                }
                HStack {
                    SlidingCover(
                        config: SlidingCoverConfig(
                            direction: .right, amount: 0.5,
                            animation: .linear(duration: 0.15)
                        ),
                        isSlided: $isSlided,
                        sliding: { frontView },
                        covered: { backView }
                    )
                    .frame(width: width, height: height)
                    SlidingCover(
                        config: SlidingCoverConfig(
                            direction: .left, amount: 0.45,
                            animation: .spring(response: 0.25, dampingFraction: 0.4)
                        ),
                        isSlided: $isSlided,
                        sliding: { frontView },
                        covered: { backView }
                    )
                    .frame(width: width, height: height)
                }
            }
        }
    }
    @available(iOS 13.0.0, *)
    static var previews: some View {
        PreviewView()
    }
}

@available(iOS 13.0, *)
private func rect(_ msg: String, _ color: Color, _ alignment: Alignment = .center) -> some View {
    Rectangle()
        .foregroundColor(color)
        .overlay(
            Text(msg).padding(),
            alignment: alignment
        )
}
