import SwiftUI

enum SwipeDirection {
    case up
    case down
    case left
    case right

    init(start: CGSize, end: CGSize) {
        let delta = CGSize(
            width: end.width - start.width,
            height: end.height - start.height
        )

        if abs(delta.width) > abs(delta.height) {
            self = delta.width < 0 ? .left : .right
        }
        else {
            self = delta.height < 0 ? .up : .down
        }
    }
}
