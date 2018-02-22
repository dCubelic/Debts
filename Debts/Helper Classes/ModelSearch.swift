import Foundation
import MobileCoreServices
import CoreSpotlight

extension Person {
    public static let domainIdentifer = "com.dcubelic.debts.person"
    
    public var userActivityUserInfo: [NSObject: AnyObject] {
        return ["id" as NSObject: uuid as AnyObject]
    }
    
//    public var userActivity: NSUserActivity {
//        let activity = NSUserActivity(activityType: Person.domainIdentifer)
//        activity.title = name
//        activity.userInfo = userActivityUserInfo
//        activity.contentAttributeSet = attributeSet
//        return activity
//    }
    
    public var searchableItem: CSSearchableItem {
        return CSSearchableItem(uniqueIdentifier: uuid, domainIdentifier: Person.domainIdentifer, attributeSet: attributeSet)
    }
    
    public var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = name
        attributeSet.contentDescription = "\(Currency.stringWithSelectedCurrency(for: totalDebt)), \(debts.count) debt\(debts.count == 1 ? "" : "s")"
        return attributeSet
    }
}

extension DebtCategory {
    public static let domainIdentifier = "com.dcubelic.debts.debtcategory"
    
    public var userActivityUserInfo: [NSObject: AnyObject] {
        return ["id" as NSObject: uuid as AnyObject]
    }
    
//    public var userActivity: NSUserActivity {
//        let activity = NSUserActivity(activityType: DebtCategory.domainIdentifier)
//        activity.title = name
//        activity.userInfo = userActivityUserInfo
//        activity.contentAttributeSet = attributeSet
//        return activity
//    }

    public var searchableItem: CSSearchableItem {
        return CSSearchableItem(uniqueIdentifier: uuid, domainIdentifier: DebtCategory.domainIdentifier, attributeSet: attributeSet)
    }
    
    public var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = name
        attributeSet.contentDescription = "\(Currency.stringWithSelectedCurrency(for: totalDebt)), \(debts.count) \(debts.count == 1 ? "person" : "people")"
        return attributeSet
    }
}
