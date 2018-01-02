import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var debtNameTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func action(_ sender: Any) {
        let person = realm.objects(Person.self).filter("name = %@", textField.text ?? "").first
        
        let debtCategory = DebtCategory()
        debtCategory.name = debtNameTextField.text ?? ""
        debtCategory.dateCreated = Date()
        
        let pd = Debt()
        pd.person = person
        pd.debtCategory = debtCategory
        pd.cost = Double(costTextField.text ?? "") ?? 0

        try! realm.write {
            realm.add(pd, update: true)
        }
        
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        view.endEditing(true)
    }
}
