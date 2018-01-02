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
        let person = realm.objects(Person.self).filter("name = %@", "dominik").first
//        person.id = person.incrementID()
//        person.name = textField.text ?? ""
        let debtCategory = DebtCategory()
//        debt.id = debt.incrementID()
        debtCategory.name = debtNameTextField.text ?? ""
        let pd = Debt()
        pd.person = person
        pd.debtCategory = debtCategory
        pd.cost = Double(costTextField.text ?? "") ?? 0

        try! realm.write {
            realm.add(pd, update: true)
        }
        
        
        view.endEditing(true)
    }
}
