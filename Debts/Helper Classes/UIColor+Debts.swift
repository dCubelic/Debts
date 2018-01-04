import UIKit

extension UIColor {
    convenience init(for debtCategory: DebtCategory) {
        self.init(
            red: (CGFloat(debtCategory.uuid.hashValue % 155) + 100) / 255,
            green: CGFloat(debtCategory.name.hashValue % 255) / 255,
            blue: CGFloat(debtCategory.dateCreated.hashValue % 255) / 255,
            alpha: 1
        )
    }
    
    convenience init(for person: Person) {
        self.init(
            red: (CGFloat(person.uuid.hashValue % 155) + 100) / 255,
            green: CGFloat(person.name.hashValue % 255) / 255,
            blue: CGFloat(person.hashValue % 255) / 255,
            alpha: 1
        )
    }
}
