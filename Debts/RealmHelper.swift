import Foundation
import RealmSwift

struct DebtByPerson {
    var debt: Debt
    var cost: Double
}

struct PersonByDebt {
    var person: Person
    var cost: Double
}

typealias PersonID = Int
typealias DebtID = Int

class RealmHelper {

    static let realm = try! Realm()
    
    static func getAllPersons() -> [Person] {
        return realm.objects(Person.self).toArray()
    }
    
    static func getAllDebts() -> [Debt] {
        return realm.objects(Debt.self).toArray()
    }
    
    static func getDebts(for personID: PersonID) -> [DebtByPerson] {
        let defaultDebt = Debt()
        return realm.objects(PersonDebt.self).filter("person.id = %@", personID).map({ DebtByPerson(debt: $0.debt ?? defaultDebt, cost: $0.cost)
        })
    }
    
    static func getPersons(for debtID: DebtID) -> [PersonByDebt] {
        let defaultPerson = Person()
        return realm.objects(PersonDebt.self).filter("debt.id = %@", debtID).map({ PersonByDebt(person: $0.person ?? defaultPerson, cost: $0.cost)
        })
    }
    
    static func getCost(for person: Person) -> Double {
        let personDebts = realm.objects(PersonDebt.self).filter("person.id = %@", person.id).toArray()
        
        var cost: Double = 0
        for personDebt in personDebts {
            cost += personDebt.cost
        }
        
        return cost
    }
    
    static func getCost(for debt: Debt) -> Double {
        let personDebts = realm.objects(PersonDebt.self).filter("debt.id = %@", debt.id).toArray()
        
        var cost: Double = 0
        for personDebt in personDebts {
            cost += personDebt.cost
        }
        
        return cost
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
