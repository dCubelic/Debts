import UIKit

protocol AddPersonViewControllerDelegate {
    func addPersonViewControllerDidAddPerson(_ vc: AddPersonViewController, person: Person)
}

class AddPersonViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    var delegate: AddPersonViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    }
    
    @objc func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneAction() {
        if let name = nameTextField.text, name.count > 0 {
            let person = RealmHelper.addPerson(name: name)
            delegate?.addPersonViewControllerDidAddPerson(self, person: person)
        }
        dismiss(animated: true, completion: nil)
    }

}
