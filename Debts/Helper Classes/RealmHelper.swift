import Foundation
import RealmSwift

struct DebtCategoryByPerson {
    var debtCategory: DebtCategory
    var cost: Double
    var dateAdded: Date
}

struct PersonByDebtCategory {
    var person: Person
    var cost: Double
}

class RealmHelper {

    static let realm = try! Realm()
    
    static func getAllPersons() -> [Person] {
        return realm.objects(Person.self).toArray()
    }
    
    static func getAllDebtCategories() -> [DebtCategory] {
        return realm.objects(DebtCategory.self).toArray()
    }
    
    static func getDebtCategories(for person: Person) -> [DebtCategoryByPerson] {
        let defaultDebt = DebtCategory()
        return realm.objects(Debt.self).filter("person = %@", person).map({ DebtCategoryByPerson(debtCategory: $0.debtCategory ?? defaultDebt, cost: $0.cost, dateAdded: $0.dateAdded) })
    }
    
    static func getPersons(for debtCategory: DebtCategory) -> [PersonByDebtCategory] {
        let defaultPerson = Person()
        return realm.objects(Debt.self).filter("debtCategory = %@", debtCategory).map({ PersonByDebtCategory(person: $0.person ?? defaultPerson, cost: $0.cost)
        })
    }
    
    static func getDebts(for person: Person) -> [Debt] {
        return realm.objects(Debt.self).filter("person = %@ AND isMyDebt = false", person).toArray()
    }
    
    static func getMyDebts(for person: Person) -> [Debt] {
        return realm.objects(Debt.self).filter("person = %@ AND isMyDebt = true", person).toArray()
    }
    
    static func getDebts(for debtCategory: DebtCategory) -> [Debt] {
        return realm.objects(Debt.self).filter("debtCategory = %@ AND isMyDebt = false", debtCategory).toArray()
    }
    
    static func getMyDebts(for debtCategory: DebtCategory) -> [Debt] {
        return realm.objects(Debt.self).filter("debtCategory = %@ AND isMyDebt = false", debtCategory).toArray()
    }
    
    static func getCost(for person: Person) -> Double {
        return person.totalDebt
    }
    
    static func getCost(for debtCategory: DebtCategory) -> Double {
        return debtCategory.totalDebt
    }
    
    static func addPerson(name: String) -> Person {
        let person = Person()
        person.name = name
        
        try! realm.write {
            realm.add(person, update: true)
        }
        
        return person
    }
    
    static func removePerson(person: Person) {
        try! realm.write {
            realm.delete(person.debts)
            realm.delete(person)
        }
        removeEmptyDebtCategories()
    }
    
    static func removeDebtCategory(debtCategory: DebtCategory) {
        try! realm.write {
            realm.delete(debtCategory.debts)
            realm.delete(debtCategory)
        }
    }
    
    static func removeDebt(_ debt: Debt) {
        try! realm.write {
            realm.delete(debt)
        }
        
        removeEmptyDebtCategories()
    }
    
    static func removeDebts(for person: Person) {
        try! realm.write {
            realm.delete(person.debts)
        }
        
        removeEmptyDebtCategories()
    }
    
    static func changeCost(for debt: Debt, cost: Double) {
        try! realm.write {
            debt.cost = cost
        }
    }
    
    static func changeName(for person: Person, name: String) {
        try! realm.write {
            person.name = name
        }
    }
    
    static func changeTitle(for debtCategory: DebtCategory, title: String) {
        try! realm.write {
            debtCategory.name = title
        }
    }
    
    static func getTotalOfAllDebts() -> Double {
        return getTotalOfDebts() - getTotalOfMyDebts()
    }
    
    static func getTotalOfMyDebts() -> Double {
        return realm.objects(Debt.self).filter("isMyDebt = true").sum(ofProperty: "cost")
    }
    
    static func getTotalOfDebts() -> Double {
        return realm.objects(Debt.self).filter("isMyDebt = false").sum(ofProperty: "cost")
    }
    
    static func getNumberOfDebtCategories() -> Int {
        return realm.objects(DebtCategory.self).count
    }
    
    static func getNumberOfPeople() -> Int {
        return realm.objects(Person.self).count
    }
    
    static func getNumberOfDebts() -> Int {
        return realm.objects(Debt.self).count
    }
    
    private static func removeEmptyDebtCategories() {
        let debtCategories = realm.objects(DebtCategory.self)
        
        for debtCategory in debtCategories {
            if debtCategory.debts.count == 0 {
                try! realm.write {
                    realm.delete(debtCategory)
                }
            }
        }
        
    }
 
}

extension Results {
    
    func toArray() -> [Element] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [Element] {
        return self.map{$0}
    }
}
