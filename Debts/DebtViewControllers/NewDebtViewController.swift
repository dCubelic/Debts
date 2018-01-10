import UIKit

class NewDebtViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var splitAmountTextField: UITextField!
    @IBOutlet weak var splitSwitch: UISwitch!
    @IBOutlet weak var underlineView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSplitting = false
    var isMyDebt = false
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var selectedPeople: [Person] = []
    var debtCategory = DebtCategory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debtCategory.isMyDebt = isMyDebt
        
        splitAmountTextField.isHidden = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem?.isEnabled = false
//        navigationController?.navigationBar.prefersLargeTitles = true
        
        people = RealmHelper.getAllPersons()
        
        titleTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        tableView.register(UINib(nibName: Constants.newDebtPersonCell, bundle: nil), forCellReuseIdentifier: Constants.newDebtPersonCell)
        
        titleTextField.becomeFirstResponder()
        
        underlineView.backgroundColor = UIColor(for: debtCategory)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterPeople(for searchText: String) {
        filteredPeople = people.filter({ (person) -> Bool in
            return person.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func getPerson(for indexPath: IndexPath) -> Person {
        var person: Person
        if isFiltering() {
            person = filteredPeople[indexPath.row]
        } else {
            person = people[indexPath.row]
        }
        
        return person
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        isSplitting = splitSwitch.isOn
        
        if isSplitting {
            splitAmountTextField.isEnabled = true
            splitAmountTextField.becomeFirstResponder()
        } else {
            splitAmountTextField.isEnabled = false
            splitAmountTextField.resignFirstResponder()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        RealmHelper.add(debtCategory: debtCategory, with: selectedPeople)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        dismiss(animated: true, completion: nil)
    }
}

extension NewDebtViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPeople.count
        }
        
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.newDebtPersonCell, for: indexPath) as! NewDebtPersonTableViewCell
        
        let person = getPerson(for: indexPath)
        
        cell.setup(with: person, selected: selectedPeople.contains(person))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NewDebtPersonTableViewCell
        cell.switchSelection()
        
        let person = getPerson(for: indexPath)
        
        if cell.isCellSelected {
            selectedPeople.append(person)
            if selectedPeople.count > 0 {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        } else {
            if let index = selectedPeople.index(of: person) {
                selectedPeople.remove(at: index)
            }
            if selectedPeople.count == 0 {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
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
            debtCategory.name = textField.text ?? ""
        }
    }
}

extension NewDebtViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterPeople(for: searchText)
        }
    }
}
