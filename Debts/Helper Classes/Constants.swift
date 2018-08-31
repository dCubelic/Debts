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
    
    struct UserDefaults {
        static let currency = "currency"
        static let peopleSortComparator = "peopleSortComparator"
        static let debtCategoriesSortComparator = "debtCategoriesSortComparator"
        static let myDebtCategoriesSortComparator = "myDebtCategoriesSortComparator"
        static let debtCategoryDetailsSortComparator = "debtCategoryDetailsSortComparator"
        static let personDetailSortComparator = "personDetailSortComparator"
    }
    
    struct Cells {
        static let categoryCell = "DebtCategoryTableViewCell"
        static let debtDetailCell = "DebtDetailTableViewCell"
        static let personCell = "PersonTableViewCell"
        static let newDebtPersonCell = "NewDebtPersonTableViewCell"
    }
    
}
