import Foundation
import RealmSwift

class Person: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Person.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}

class Debt: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Debt.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}

class PersonDebt: Object {
    @objc dynamic var id = 0
    @objc dynamic var person: Person? = nil
    @objc dynamic var debt: Debt? = nil
    @objc dynamic var cost: Double = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(PersonDebt.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
