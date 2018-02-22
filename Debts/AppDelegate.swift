import UIKit
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let rootVc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateInitialViewController(ofType: UITabBarController.self)
        
        print(userActivity.activityType)
        
        if userActivity.activityType == CSSearchableItemActionType {
            if let uuid = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if let debtCategory = RealmHelper.getDebtCategory(forUuid: uuid) {
                    rootVc.selectedIndex = debtCategory.isMyDebt ? 2 : 1
                    
                    let debtCategoryVc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: DebtCategoryDetailViewController.self, withIdentifier: Constants.Storyboard.debtCategoryDetailViewController)
                    debtCategoryVc.debtCategory = debtCategory
                    
                    (rootVc.selectedViewController as? UINavigationController)?.pushViewController(debtCategoryVc, animated: true)
                } else if let person = RealmHelper.getPerson(forUuid: uuid) {
                    rootVc.selectedIndex = 3
                    
                    let personVc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: PersonDetailViewController.self, withIdentifier: Constants.Storyboard.personDetailViewController)
                    personVc.person = person
                    
                    (rootVc.selectedViewController as? UINavigationController)?.pushViewController(personVc, animated: true)
                }
            }
        }
        
//        if userActivity.activityType == Person.domainIdentifer, let objectId = userActivity.userInfo?["id"] as? String {
//            rootVc.selectedIndex = 3
//
//            let personVc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: PersonDetailViewController.self, withIdentifier: Constants.Storyboard.personDetailViewController)
//            personVc.person = RealmHelper.getPerson(forUuid: objectId)
//
//            (rootVc.selectedViewController as? UINavigationController)?.pushViewController(personVc, animated: true)
//        } else if userActivity.activityType == DebtCategory.domainIdentifier, let objectId = userActivity.userInfo?["id"] as? String {
//            let debtCategory = RealmHelper.getDebtCategory(forUuid: objectId)
//            rootVc.selectedIndex = (debtCategory?.isMyDebt ?? false) ? 2 : 1
//
//            let debtCategoryVc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: DebtCategoryDetailViewController.self, withIdentifier: Constants.Storyboard.debtCategoryDetailViewController)
//            debtCategoryVc.debtCategory = debtCategory
//
//            (rootVc.selectedViewController as? UINavigationController)?.pushViewController(debtCategoryVc, animated: true)
//        } else {
//            return false
//        }
        
        self.window?.rootViewController = rootVc
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        RealmHelper.removeEmptyDebtCategories()
    }
    
}
