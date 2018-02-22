import Foundation
import RealmSwift
import CoreSpotlight

//struct DebtCategoryByPerson {
//    var debtCategory: DebtCategory
//    var cost: Double
//    var dateAdded: Date
//}
//
//struct PersonByDebtCategory {
//    var person: Person
//    var cost: Double
//}

class RealmHelper {
    
    static var realm: Realm {
        do {
            let realm = try Realm()
            return realm
        } catch {
            print("Could not access realm: \(error)")
        }
        return self.realm
    }
    
    public static func write(realm: Realm, writeClosure: () -> Void) {
        do {
            try realm.write {
                writeClosure()
            }
        } catch {
            print("Could not write to realm: \(error)")
        }
    }
    
    //    static let realm = try! Realm()
    
    static func getAllPersons() -> [Person] {
        return realm.objects(Person.self).toArray()
    }
    
    static func getAllDebtCategories() -> [DebtCategory] {
        return realm.objects(DebtCategory.self).filter("isMyDebt = false").toArray()
    }
    
    static func getAllMyDebtCategories() -> [DebtCategory] {
        return realm.objects(DebtCategory.self).filter("isMyDebt = true").toArray()
    }
    
    static func getDebts(for person: Person) -> [Debt] {
        //        let defaultDebt = DebtCategory()
        return realm.objects(Debt.self).filter("person = %@", person).toArray()
        //        return realm.objects(Debt.self).filter("person = %@", person).map({ DebtCategoryByPerson(debtCategory: $0.debtCategory ?? defaultDebt, cost: $0.cost, dateAdded: $0.dateAdded) })
    }
    
    static func getPerson(forUuid uuid: String) -> Person? {
        return realm.objects(Person.self).first(where: { $0.uuid == uuid })
    }
    
    static func getDebtCategory(forUuid uuid: String) -> DebtCategory? {
        return realm.objects(DebtCategory.self).first(where: { $0.uuid == uuid })
    }
    
    //    static func getPersons(for debtCategory: DebtCategory) -> [Debt] {
    ////        let defaultPerson = Person()
    //        return realm.objects(Debt.self).filter("debtCategory = %@", debtCategory).toArray()
    ////        return realm.objects(Debt.self).filter("debtCategory = %@", debtCategory).map({ PersonByDebtCategory(person: $0.person ?? defaultPerson, cost: $0.cost)})
    //    }
    
    //    static func getDebts(for person: Person) -> [Debt] {
    //        return realm.objects(Debt.self).filter("person = %@ AND debtCategory.isMyDebt = false", person).toArray()
    //    }
    //
    //    static func getMyDebts(for person: Person) -> [Debt] {
    //        return realm.objects(Debt.self).filter("person = %@ AND debtCategory.isMyDebt = true", person).toArray()
    //    }
    
    static func getDebts(for debtCategory: DebtCategory) -> [Debt] {
        return realm.objects(Debt.self).filter("debtCategory = %@", debtCategory).toArray()
    }
    
    static func getCost(for person: Person) -> Double {
        return person.totalDebt
    }
    
    static func getCost(for debtCategory: DebtCategory) -> Double {
        return debtCategory.totalDebt
    }
    
//    static func addPerson(name: String) -> Person {
//        let person = Person()
//        person.name = name
//
//        write(realm: realm) {
//            realm.add(person, update: true)
//        }
//
//        CSSearchableIndex.default().indexSearchableItems([person.searchableItem], completionHandler: nil)
//
//        return person
//    }
    
    static func add(debtCategory: DebtCategory, with people: [Person], and costDictionary: [Person: Double]) {
        write(realm: realm) {
            for person in people {
                guard let cost = costDictionary[person] else { continue }
                
                let debt = Debt()
                debt.debtCategory = debtCategory
                debt.person = person
                debt.cost = cost
                
                realm.add(debt)
            }
        }
        CSSearchableIndex.default().indexSearchableItems([debtCategory.searchableItem], completionHandler: nil)
    }
    
    static func removePerson(person: Person) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [person.uuid], completionHandler: nil)
        write(realm: realm) {
            realm.delete(person.debts)
            realm.delete(person)
        }
        removeEmptyDebtCategories()
    }
    
    static func removeDebtCategory(debtCategory: DebtCategory) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [debtCategory.uuid], completionHandler: nil)
        write(realm: realm) {
            realm.delete(debtCategory.debts)
            realm.delete(debtCategory)
        }
    }
    
    static func removeDebt(_ debt: Debt) {
        write(realm: realm) {
            realm.delete(debt)
        }
        
//        removeEmptyDebtCategories()
    }
    
    static func removeDebts(for person: Person) {
        write(realm: realm) {
            realm.delete(person.debts)
        }
        
        removeEmptyDebtCategories()
    }
    
    static func changeCost(for debt: Debt, cost: Double) {
        write(realm: realm) {
            debt.cost = cost
        }
    }
    
    static func updateName(for person: Person, name: String) {
        write(realm: realm) {
            person.name = name
            if !(realm.objects(Person.self).filter("uuid = %@", person.uuid).count == 1) {
                realm.add(person)
            }
        }
        CSSearchableIndex.default().indexSearchableItems([person.searchableItem], completionHandler: nil)
    }
    
    static func changeTitle(for debtCategory: DebtCategory, title: String) {
        write(realm: realm) {
            debtCategory.name = title
            if !(realm.objects(DebtCategory.self).filter("uuid = %@", debtCategory.uuid).count == 1) {
                realm.add(debtCategory)
            }
        }
    }
    
    static func getTotalOfAllDebts() -> Double {
        return getTotalOfDebts() - getTotalOfMyDebts()
    }
    
    static func getTotalOfMyDebts() -> Double {
        return realm.objects(Debt.self).filter("debtCategory.isMyDebt = true").sum(ofProperty: "cost")
    }
    
    static func getTotalOfDebts() -> Double {
        return realm.objects(Debt.self).filter("debtCategory.isMyDebt = false").sum(ofProperty: "cost")
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
    
    static func removeEmptyDebtCategories() {
        let debtCategories = realm.objects(DebtCategory.self)
        write(realm: realm) {
            for debtCategory in debtCategories where debtCategory.debts.isEmpty {
                realm.delete(debtCategory)
            }
        }
    }
    
    static func deleteAllData() {
        write(realm: realm) {
            realm.deleteAll()
        }
        CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: nil)
    }
    
}

extension Results {
    
    func toArray() -> [Element] {
        return self.map {$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [Element] {
        return self.map {$0}
    }
}
