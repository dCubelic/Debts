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

class RealmHelper: RealmFetchable {
    
    typealias T = Object
    
    static var realm: Realm = try! Realm()

    static func getAll<T>() -> [T] where T : Object {
        return realm.objects(T.self).toArray()
    }
    
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
            realm.delete(person)
        }
        // TODO: remove person's debts
        // TODO: remove debts with no debtees
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


protocol RealmFetchable {
    
    associatedtype T
    static var realm: Realm { get }
    static func getAll<T: Object>() -> [T]
}
