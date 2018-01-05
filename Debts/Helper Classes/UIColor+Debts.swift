import UIKit

extension UIColor {
    convenience init(for debtCategory: DebtCategory) {
        let colors = UIColor.hashStringToRGB(string: debtCategory.uuid)
        self.init(red: CGFloat(colors.0) / 255, green: CGFloat(colors.1) / 255, blue: CGFloat(colors.2) / 255, alpha: 1)
    }
    
    convenience init(for person: Person) {
        let colors = UIColor.hashStringToRGB(string: person.uuid)
        self.init(red: CGFloat(colors.0) / 255, green: CGFloat(colors.1) / 255, blue: CGFloat(colors.2) / 255, alpha: 1)
    }
    
    private static func hashStringToRGB(string: String) -> (Int, Int, Int) {
        let hash: Int = string.hashValue
        let r: Int = (hash & 0xFF0000) >> 16
        let g: Int = (hash & 0x00FF00) >> 8
        let b: Int = (hash & 0x0000FF)
        return (r, g, b)
    }
    
}
