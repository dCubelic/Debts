import UIKit

class NewDebtViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var splitAmountTextField: UITextField!
    @IBOutlet weak var splitSwitch: UISwitch!
    @IBOutlet weak var underlineView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSplitting = false
    var isMyDebt = false
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var selectedPeople: [Person] = []
    var costDict: [Person: Double] = [:]
    var debtCategory = DebtCategory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        debtCategory.isMyDebt = isMyDebt
        
        title = debtCategory.name
        
        splitAmountTextField.isHidden = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search People"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        people = RealmHelper.getAllPersons()
        sortPeople()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        tableView.register(UINib(nibName: Constants.newDebtPersonCell, bundle: nil), forCellReuseIdentifier: Constants.newDebtPersonCell)
        
        underlineView.backgroundColor = UIColor(for: debtCategory)
    }
    
    func sortPeople() {
        people.sort { $0.name < $1.name }
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
        tableView.reloadData()
        
        if isSplitting {
            splitAmountTextField.isEnabled = true
            view.endEditing(true)
            splitAmountTextField.becomeFirstResponder()
        } else {
            splitAmountTextField.isEnabled = false
            view.endEditing(true)
//            splitAmountTextField.resignFirstResponder()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        RealmHelper.removeDebtCategory(debtCategory: debtCategory)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        view.endEditing(true)
        RealmHelper.add(debtCategory: debtCategory, with: selectedPeople, and: costDict)
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
        cell.delegate = self
        
        let person = getPerson(for: indexPath)
        
        cell.setup(with: person, selected: selectedPeople.contains(person))
        if isSplitting {
            cell.costTextField.isEnabled = false
            cell.costTextField.alpha = 0.1
//            cell.costTextField.isHidden = true
        } else {
            cell.costTextField.isEnabled = true
            cell.costTextField.alpha = 1
//            cell.costTextField.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NewDebtPersonTableViewCell
        cell.switchSelection()
        
        let person = getPerson(for: indexPath)
        
        if cell.isCellSelected {
            if !isSplitting {
                cell.costTextField.becomeFirstResponder()
            }
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

extension NewDebtViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterPeople(for: searchText)
        }
    }
}

extension NewDebtViewController: NewDebtPersonTableViewCellDelegate {
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, didChangeCostTo cost: Double) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let person = getPerson(for: indexPath)
        costDict[person] = cost
    }
}
