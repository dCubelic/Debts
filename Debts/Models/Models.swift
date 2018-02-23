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

        return td - tmd
    }
}

class DebtCategory: UniqueObject {
    @objc dynamic var name = ""
    @objc dynamic var dateCreated = Date()
    @objc dynamic var isMyDebt: Bool = false

    let debts = LinkingObjects(fromType: Debt.self, property: "debtCategory")

    var totalDebt: Double {
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

class Currency: NSObject, NSCoding {
    var name: String
    var symbol: String
    var beforeValue: Bool
    
    static var currencies: [Currency] = [
        Currency(name: "USD", symbol: "$", beforeValue: true),
        Currency(name: "HRK", symbol: "kn", beforeValue: false),
        Currency(name: "EUR", symbol: "€", beforeValue: true)
    ]
    
    init(name: String, symbol: String, beforeValue: Bool) {
        self.name = name
        self.symbol = symbol
        self.beforeValue = beforeValue
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.symbol = decoder.decodeObject(forKey: "symbol") as? String ?? ""
        self.beforeValue = decoder.decodeBool(forKey: "beforeValue")
    }
    
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.name == rhs.name && lhs.symbol == rhs.symbol && lhs.beforeValue == rhs.beforeValue
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(symbol, forKey: "symbol")
        aCoder.encode(beforeValue, forKey: "beforeValue")
    }
    
    static func saveCurrency(currency: Currency) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: currency)
        UserDefaults.standard.set(encodedData, forKey: Constants.UserDefaults.currency)
    }
    
    static func loadCurrency() -> Currency {
        if let data = UserDefaults.standard.data(forKey: Constants.UserDefaults.currency),
            let currency = NSKeyedUnarchiver.unarchiveObject(with: data) as? Currency {
            return currency
        }
        return Currency(name: "Dollar", symbol: "$", beforeValue: true)
    }
    
    static func stringWithSelectedCurrency(for cost: Double) -> String {
        let currency = loadCurrency()
        return String(
            format: "%@%.2f%@",
            currency.beforeValue ? currency.symbol : "",
            cost,
            currency.beforeValue ? "" : currency.symbol
        )
    }
}
