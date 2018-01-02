import Foundation
import RealmSwift

struct DebtCategoryByPerson {
    var debtCategory: DebtCategory
    var cost: Double
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
        return realm.objects(Debt.self).filter("person = %@", person).map({ DebtCategoryByPerson(debtCategory: $0.debtCategory ?? defaultDebt, cost: $0.cost) })
    }
    
    static func getPersons(for debtCategory: DebtCategory) -> [PersonByDebtCategory] {
        let defaultPerson = Person()
        return realm.objects(Debt.self).filter("debtCategory = %@", debtCategory).map({ PersonByDebtCategory(person: $0.person ?? defaultPerson, cost: $0.cost)
        })
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
