import Foundation

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
            format: "%@%@%.2f%@",
            cost < 0 ? "-" : "",
            currency.beforeValue ? currency.symbol : "",
            abs(cost),
            currency.beforeValue ? "" : currency.symbol
        )
    }
}
