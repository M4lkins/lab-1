import Foundation

// MARK: - Протокол Shape

protocol Shape {
    func area() throws -> Double
    func perimeter() -> Double
}

// MARK: - Помилки ініціалізації

enum LineError: Error {
    case invalidLength
}

enum TriangleError: Error {
    case notATriangle
}

enum RectangleError: Error {
    case invalidDimensions
}

// MARK: - Помилка під час виконання

enum ShapeError: Error {
    case negativeArea
}

// MARK: - Класи фігур

class Line: Shape {
    let length: Double

    init(length: Double) throws {
        guard length > 0 else {
            throw LineError.invalidLength
        }
        self.length = length
    }

    func area() throws -> Double {
        return 0
    }

    func perimeter() -> Double {
        return length
    }
}

class Triangle: Shape {
    let a: Double
    let b: Double
    let c: Double

    init(a: Double, b: Double, c: Double) throws {
        guard a + b > c && a + c > b && b + c > a else {
            throw TriangleError.notATriangle
        }
        self.a = a
        self.b = b
        self.c = c
    }

    func area() throws -> Double {
        let s = (a + b + c) / 2
        let result = sqrt(s * (s - a) * (s - b) * (s - c))
        if result <= 0 {
            throw ShapeError.negativeArea
        }
        return result
    }

    func perimeter() -> Double {
        return a + b + c
    }
}

class Rectangle: Shape {
    let width: Double
    let height: Double

    init(width: Double, height: Double) throws {
        guard width > 0 && height > 0 else {
            throw RectangleError.invalidDimensions
        }
        self.width = width
        self.height = height
    }

    func area() throws -> Double {
        return width * height
    }

    func perimeter() -> Double {
        return 2 * (width + height)
    }
}

class Square: Rectangle {
    init(side: Double) throws {
        try super.init(width: side, height: side)
    }
}

// MARK: - Калькулятор площі для будь-якої фігури

class AreaCalculator {
    func calculate(for shape: Shape) {
        do {
            let area = try shape.area()
            print("🔷 Площа фігури: \(area)")
        } catch {
            print("⚠️ Помилка обчислення площі: \(error)")
        }
    }
}

// MARK: - Приклад використання

func testShapes() {
    do {
        let line = try Line(length: 5)
        let triangle = try Triangle(a: 3, b: 4, c: 5)
        let rectangle = try Rectangle(width: 6, height: 2)
        let square = try Square(side: 4)

        let calculator = AreaCalculator()

        let shapes: [Shape] = [line, triangle, rectangle, square]
        for shape in shapes {
            calculator.calculate(for: shape)
        }

    } catch LineError.invalidLength {
        print("❌ Лінія має недійсну довжину")
    } catch TriangleError.notATriangle {
        print("❌ Неможливо створити трикутник з заданими сторонами")
    } catch RectangleError.invalidDimensions {
        print("❌ Розміри прямокутника некоректні")
    } catch {
        print("❌ Невідома помилка: \(error)")
    }
}

// Запуск
testShapes()
