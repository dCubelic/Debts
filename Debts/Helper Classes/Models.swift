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
    let debts = List<Debt>()
    
    var totalDebt: Double {
        return debts.sum(ofProperty: "cost")
    }
    
}

class DebtCategory: UniqueObject {
    
    @objc dynamic var name = ""
    let debts = List<Debt>()
    
    var totalDebt: Double {
        return debts.sum(ofProperty: "cost")
    }
    
}

class Debt: UniqueObject {
    
    @objc dynamic var person: Person? = nil
    @objc dynamic var debtCategory: DebtCategory? = nil
    @objc dynamic var cost: Double = 0
    
}
