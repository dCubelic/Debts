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
        let td: Double = debts.filter("debtCategory.isMyDebt = false").sum(ofProperty: "cost")
        let tmd: Double = debts.filter("debtCategory.isMyDebt = true").sum(ofProperty: "cost")
//        let sum: Double = debts.sum(ofProperty: "cost")

        return td - tmd
    }

}

class DebtCategory: UniqueObject {

    @objc dynamic var name = ""
    @objc dynamic var dateCreated = Date()
    @objc dynamic var isMyDebt: Bool = false

    let debts = LinkingObjects(fromType: Debt.self, property: "debtCategory")

    var totalDebt: Double {
//        let td: Double = debts.filter("debtCategory.isMyDebt = false").sum(ofProperty: "cost")
//        let tmd: Double = debts.filter("debtCategory.isMyDebt = true").sum(ofProperty: "cost")
//        //        let sum: Double = debts.sum(ofProperty: "cost")
//        
//        return td - tmd
        let sum: Double = debts.sum(ofProperty: "cost")
        return sum
    }

}

class Debt: UniqueObject {

    @objc dynamic var person: Person?
    @objc dynamic var debtCategory: DebtCategory?
    @objc dynamic var cost: Double = 0
    @objc dynamic var dateAdded: Date = Date()

}
