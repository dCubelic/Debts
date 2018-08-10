import UIKit

extension UIColor {
    open class var cellBackgroundColor: UIColor {
        return UIColor(white: 246/255, alpha: 1)
    }
    
    open class var cellBackgroundColorHighlighted: UIColor {
        return UIColor(white: 220/255, alpha: 1)
    }
    
    convenience init(for debtCategory: DebtCategory) {
        let colors = UIColor.hashStringToRGB(string: debtCategory.uuid)
        self.init(red: CGFloat(colors.0) / 255, green: CGFloat(colors.1) / 255, blue: CGFloat(colors.2) / 255, alpha: 1)
    }

    convenience init(for person: Person) {
        let colors = UIColor.hashStringToRGB(string: person.uuid)
        self.init(red: CGFloat(colors.0) / 255, green: CGFloat(colors.1) / 255, blue: CGFloat(colors.2) / 255, alpha: 1)
    }

    convenience init(for cost: Double) {
        let colors = UIColor.hashStringToRGB(string: cost.description)
        self.init(red: CGFloat(colors.0) / 255, green: CGFloat(colors.1) / 255, blue: CGFloat(colors.2) / 255, alpha: 1)
    }

    private static func hashStringToRGB(string: String) -> (Int, Int, Int) {
        let hash: Int = string.hashValue
        let red: Int = (hash & 0xFF0000) >> 16
        let green: Int = (hash & 0x00FF00) >> 8
        let blue: Int = (hash & 0x0000FF)
        return (red, green, blue)
    }
}
