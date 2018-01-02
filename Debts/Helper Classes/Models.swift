import Foundation
import RealmSwift

class UniqueObject: Object {
    
    @objc dynamic var uuid = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
}

class Person: UniqueObject {
    
    @objc dynamic var name = ""
    let debts = LinkingObjects(fromType: Debt.self, property: "person")
    
    var totalDebt: Double {
        let sum: Double = debts.sum(ofProperty: "cost")
        return sum
    }
    
}

class DebtCategory: UniqueObject {
    
    @objc dynamic var name = ""
    @objc dynamic var dateCreated = Date()
    
    let debts = LinkingObjects(fromType: Debt.self, property: "debtCategory")
    
    var totalDebt: Double {
        let sum: Double = debts.sum(ofProperty: "cost")
        return sum
    }
    
}

class Debt: UniqueObject {
    
    @objc dynamic var person: Person? = nil
    @objc dynamic var debtCategory: DebtCategory? = nil
    @objc dynamic var cost: Double = 0
    
}
