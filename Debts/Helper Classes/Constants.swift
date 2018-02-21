import Foundation

struct Constants {

    struct Storyboard {
        static let main = "Main"
        static let personDetailViewController = "PersonDetailViewController"
        static let personDetail2ViewController = "PersonDetail2ViewController"
        static let debtCategoryDetailViewController = "DebtCategoryDetailViewController"
        static let homeViewController = "HomeViewController"
        static let newDebtViewController = "NewDebtViewController"
    }

    struct Notifications {
        static let updatedDatabase = "updatedDatabase"
    }

    struct TableViewHeights {
//        static let categoryCell: CGFloat = 80
    }
    
    struct UserDefaults {
        static let currency = "currency"
    }

    static let categoryCell = "DebtCategoryTableViewCell"
    static let debtDetailCell = "DebtDetailTableViewCell"
    static let personCell = "PersonTableViewCell"
    static let newDebtPersonCell = "NewDebtPersonTableViewCell"
    
}

//struct Currency {
//    static var symbol = "kn"
//    static var beforeValue = false
//    
//    static func stringWithCurrency(for cost: Double) -> String {
//        return String(
//            format: "%@%.2f%@",
//            beforeValue ? symbol : "",
//            cost,
//            beforeValue ? "" : symbol
//        )
//    }
//}

