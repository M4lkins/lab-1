import Foundation

// MARK: - Point
struct Point {
    var x: Double
    var y: Double
}

// MARK: - Shape Protocol
protocol Shape {
    var name: String? { get }
    var points: [Point] { get }
    func perimeter() -> Double
    func area() -> Double
}

// MARK: - Line
class Line: Shape {
    var name: String?
    var points: [Point]
    
    init(start: Point, end: Point, name: String? = nil) {
        self.points = [start, end]
        self.name = name
    }
    
    func length() -> Double {
        let dx = points[1].x - points[0].x
        let dy = points[1].y - points[0].y
        return sqrt(dx * dx + dy * dy)
    }
    
    func vector() -> (dx: Double, dy: Double) {
        return (dx: points[1].x - points[0].x, dy: points[1].y - points[0].y)
    }
    
    func perimeter() -> Double {
        return length()
    }
    
    func area() -> Double {
        return 0
    }
}

// MARK: - Triangle
class Triangle: Shape {
    var name: String?
    var points: [Point]
    
    init(points: [Point], name: String? = nil) {
        guard points.count == 3 else {
            fatalError("A triangle must have exactly 3 points.")
        }
        self.points = points
        self.name = name
    }
    
    func perimeter() -> Double {
        let a = Line(start: points[0], end: points[1]).length()
        let b = Line(start: points[1], end: points[2]).length()
        let c = Line(start: points[2], end: points[0]).length()
        return a + b + c
    }
    
    func area() -> Double {
        let a = points[0]
        let b = points[1]
        let c = points[2]
        return abs((a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2)
    }
}

// MARK: - Quadrilateral
class Quadrilateral: Shape {
    var name: String?
    var points: [Point]
    
    init(points: [Point], name: String? = nil) {
        guard points.count == 4 else {
            fatalError("A quadrilateral must have exactly 4 points.")
        }
        self.points = points
        self.name = name
    }
    
    func perimeter() -> Double {
        let a = Line(start: points[0], end: points[1]).length()
        let b = Line(start: points[1], end: points[2]).length()
        let c = Line(start: points[2], end: points[3]).length()
        let d = Line(start: points[3], end: points[0]).length()
        return a + b + c + d
    }
    
    func area() -> Double {
        let triangle1 = Triangle(points: [points[0], points[1], points[2]])
        let triangle2 = Triangle(points: [points[0], points[2], points[3]])
        return triangle1.area() + triangle2.area()
    }
}

// MARK: - Mathematics
class Mathematics {
    var shapes: [Shape] = []
    
    func addShape(_ shape: Shape) {
        shapes.append(shape)
    }
    
    func shapeWithLargestArea() -> Shape? {
        return shapes.max(by: { $0.area() < $1.area() })
    }
    
    func shapeWithSmallestArea() -> Shape? {
        return shapes.min(by: { $0.area() < $1.area() })
    }
    
    func shapeWithLongestPerimeter() -> Shape? {
        return shapes.max(by: { $0.perimeter() < $1.perimeter() })
    }
    
    func shapeWithShortestPerimeter() -> Shape? {
        return shapes.min(by: { $0.perimeter() < $1.perimeter() })
    }
}