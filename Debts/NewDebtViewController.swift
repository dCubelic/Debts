import UIKit

class NewDebtViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var splitAmountTextField: UITextField!
    @IBOutlet weak var splitSwitch: UISwitch!
    
    var isSplitting: Bool = false
    var people: [Person] = []
    var selectedPeople: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        people = RealmHelper.getAllPersons()
        
        titleTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
        
        tableView.register(UINib(nibName: Constants.personCell, bundle: nil), forCellReuseIdentifier: Constants.personCell)
        
        titleTextField.becomeFirstResponder()
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        isSplitting = splitSwitch.isOn
        
        if isSplitting {
            splitAmountTextField.isHidden = false
            splitAmountTextField.becomeFirstResponder()
        } else {
            splitAmountTextField.isHidden = true
            splitAmountTextField.resignFirstResponder()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
    }
}

extension NewDebtViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.personCell, for: indexPath) as! PersonTableViewCell
        
        cell.setup(with: people[indexPath.row])
        
        return cell
    }
}

extension NewDebtViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleTextField {
            title = textField.text
        }
    }
}
