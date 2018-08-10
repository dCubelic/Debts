import UIKit

extension UIStoryboard {
    func instantiateInitialViewController<T: UIViewController>(ofType: T.Type) -> T {
        guard let viewController = instantiateInitialViewController() as? T else {
            fatalError("Storyboard \(self) doesn't contain an initial view controller of type \(ofType)")
        }
        
        return viewController
    }
    
    func instantiateViewController<T: UIViewController>(ofType: T.Type, withIdentifier: String? = nil) -> T {
        let identifier = withIdentifier ?? String(describing: ofType)
        
        guard let viewController = instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Storyboard \(self) doesn't contain a view controller of type \(ofType) for identifier \(identifier)")
        }
        
        return viewController
    }
}
