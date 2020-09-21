import UIKit
import PlaygroundSupport

extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
view.backgroundColor = .black
PlaygroundPage.current.liveView = view

view.bounceOut(duration: 1)

extension Int {
    func times(_ action: ()->()) {
        guard self > 0 else { return }
        for _ in 0..<self {
            action()
        }
    }
}

5.times { print("hello!") }
0.times { print("fail!") }
Int(-1).times { print("Another fail!") }

extension Array where Element: Equatable {
    mutating func removeFirst(item: Element) {
        guard let index = self.firstIndex(of: item) else { return }
        self.remove(at: index)
    }
}

var arr = [5, 4, 3, 4, 3]
arr.removeFirst(item: 4)
print(arr)
