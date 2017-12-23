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
        let person = realm.objects(Person.self).filter("id = 1").first
//        person.id = person.incrementID()
//        person.name = textField.text ?? ""
        let debt = Debt()
        debt.id = debt.incrementID()
        debt.name = debtNameTextField.text ?? ""
        let pd = PersonDebt()
        pd.id = pd.incrementID()
        pd.person = person
        pd.debt = debt
        pd.cost = Double(costTextField.text ?? "") ?? 0
        
        try! realm.write {
            realm.add(pd, update: true)
        }
        
        view.endEditing(true)
    }
}
