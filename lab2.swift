import Foundation

// MARK: - Протоколи

protocol Shape: CustomStringConvertible {
    func area() -> Double
    func perimeter() -> Double
    var name: String? { get }
}

protocol MathematicsDelegate: AnyObject {
    func didProcess(shapeDescription: String)
}

// MARK: - Фігури

struct Point {
    var x: Double
    var y: Double
}

struct Line: Shape {
    var start: Point
    var end: Point
    var name: String?

    func area() -> Double { 0 }
    func perimeter() -> Double {
        sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2))
    }

    var description: String {
        return "Line '\(name ?? "Unnamed")' length: \(perimeter())"
    }
}

struct Triangle: Shape {
    var points: [Point]
    var name: String?

    func area() -> Double {
        guard points.count == 3 else { return 0 }
        let a = Line(start: points[0], end: points[1]).perimeter()
        let b = Line(start: points[1], end: points[2]).perimeter()
        let c = Line(start: points[2], end: points[0]).perimeter()
        let s = (a + b + c) / 2
        return sqrt(s * (s - a) * (s - b) * (s - c))
    }

    func perimeter() -> Double {
        guard points.count == 3 else { return 0 }
        let a = Line(start: points[0], end: points[1]).perimeter()
        let b = Line(start: points[1], end: points[2]).perimeter()
        let c = Line(start: points[2], end: points[0]).perimeter()
        return a + b + c
    }

    var description: String {
        return "Triangle '\(name ?? "Unnamed")' area: \(area())"
    }
}

class Quadrilateral: Shape {
    var name: String?
    var sideA: Double
    var sideB: Double
    var sideC: Double
    var sideD: Double

    init(name: String?, a: Double, b: Double, c: Double, d: Double) {
        self.name = name
        self.sideA = a
        self.sideB = b
        self.sideC = c
        self.sideD = d
    }

    func area() -> Double { 0 } // переопреділяється у наслідниках
    func perimeter() -> Double {
        return sideA + sideB + sideC + sideD
    }

    var description: String {
        return "Quadrilateral '\(name ?? "Unnamed")' perimeter: \(perimeter())"
    }
}

class Rhombus: Quadrilateral {
    var height: Double
    init(name: String?, side: Double, height: Double) {
        self.height = height
        super.init(name: name, a: side, b: side, c: side, d: side)
    }

    override func area() -> Double {
        return sideA * height
    }

    override var description: String {
        return "Rhombus '\(name ?? "Unnamed")' area: \(area())"
    }
}

class Rectangle: Quadrilateral {
    init(name: String?, width: Double, height: Double) {
        super.init(name: name, a: width, b: height, c: width, d: height)
    }

    override func area() -> Double {
        return sideA * sideB
    }

    override var description: String {
        return "Rectangle '\(name ?? "Unnamed")' area: \(area())"
    }
}

class Square: Quadrilateral {
    init(name: String?, side: Double) {
        super.init(name: name, a: side, b: side, c: side, d: side)
    }

    override func area() -> Double {
        return sideA * sideA
    }

    override var description: String {
        return "Square '\(name ?? "Unnamed")' area: \(area())"
    }
}

// MARK: - Mathematics

class Mathematics {
    var shapes: [Shape] = []
    weak var delegate: MathematicsDelegate?

    typealias ShapeStatsClosure = (_ longest: String, _ shortest: String, _ largest: String, _ smallest: String) -> Void
    private var statsClosure: ShapeStatsClosure?

    init(shapes: [Shape], statsClosure: ShapeStatsClosure? = nil) {
        self.shapes = shapes
        self.statsClosure = statsClosure
        if let closure = statsClosure {
            computeShapeStats(using: closure)
        }
    }

    func addShape(_ shape: Shape) {
        shapes.append(shape)
    }

    func computeShapeStatsAsync(using closure: @escaping ShapeStatsClosure) {
        DispatchQueue.global().async {
            let result = self.computeShapeStatsSync()
            DispatchQueue.main.async {
                closure(result.longest, result.shortest, result.largest, result.smallest)
            }
        }
    }

    func computeShapeStats(using closure: ShapeStatsClosure) {
        let result = computeShapeStatsSync()
        closure(result.longest, result.shortest, result.largest, result.smallest)
    }

    private func computeShapeStatsSync() -> (longest: String, shortest: String, largest: String, smallest: String) {
        let descriptions = shapes.map { "\($0)" }

        let longest = descriptions.max(by: { $0.count < $1.count }) ?? ""
        let shortest = descriptions.min(by: { $0.count < $1.count }) ?? ""
        let largest = shapes.max(by: { $0.area() < $1.area() })?.description ?? ""
        let smallest = shapes.min(by: { $0.area() < $1.area() })?.description ?? ""

        delegate?.didProcess(shapeDescription: largest)
        return (longest, shortest, largest, smallest)
    }

    func applyKTimes(_ k: Int, action: () -> Void) {
        guard k > 0 else { return }
        for _ in 1...k {
            action()
        }
    }

    func maxValue(in array: [Int]) -> Int? {
        return array.reduce(nil) { maxVal, next in
            return maxVal == nil ? next : max(maxVal!, next)
        }
    }

    func concatenate(strings: [String]) -> String {
        return strings.reduce("") { $0 + $1 }
    }

    func forEach(array: [Int], _ closure: (Int) -> Void) {
        for element in array {
            closure(element)
        }
    }
}

// MARK: - Делегат

class MathLogger: MathematicsDelegate {
    func didProcess(shapeDescription: String) {
        print("Delegate повідомлення: Найбільша фігура — \(shapeDescription)")
    }
}

// MARK: - Тестування

let p1 = Point(x: 0, y: 0)
let p2 = Point(x: 3, y: 0)
let p3 = Point(x: 0, y: 4)

let triangle = Triangle(points: [p1, p2, p3], name: "T1")
let line = Line(start: p1, end: p3, name: "L1")
let square = Square(name: "S1", side: 4)
let rect = Rectangle(name: "R1", width: 3, height: 6)
let rhombus = Rhombus(name: "Rh1", side: 5, height: 4)

let logger = MathLogger()
let math = Mathematics(shapes: [triangle, line, square, rect, rhombus])
math.delegate = logger

// Асинхронний виклик
math.computeShapeStatsAsync { longest, shortest, largest, smallest in
    print("🔹 Longest description: \(longest)")
    print("🔹 Shortest description: \(shortest)")
    print("🔹 Largest area shape: \(largest)")
    print("🔹 Smallest area shape: \(smallest)")
}

// applyKTimes
print("\nПовторення через applyKTimes:")
math.applyKTimes(3) {
    print("🌀 Виконано дію")
}

// reduce
let numbers = [1, 10, 3, 99, 4]
if let maxVal = math.maxValue(in: numbers) {
    print("\nМаксимум в масиві чисел: \(maxVal)")
}

let words = ["Swift", " ", "is", " ", "awesome!"]
print("Об'єднаний рядок: \(math.concatenate(strings: words))")

// forEach
print("\nВивід кожного елемента масиву:")
math.forEach(array: numbers) { num in
    print("➡️ \(num)")
}
