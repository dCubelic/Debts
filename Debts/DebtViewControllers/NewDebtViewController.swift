import UIKit

class NewDebtViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var splitAmountTextField: UITextField!
    @IBOutlet weak var splitSwitch: UISwitch!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var tableViewHeaderView: UIView!
    @IBOutlet weak var addPersonBarButton: UIBarButtonItem!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var numberOfPeopleLabel: UILabel!
    
    let searchController = UISearchController(searchResultsController: nil)

    var isSplitting = false
    var isMyDebt = false
    var didCancel = false
    
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var selectedPeople: [Person] = []
    
    var costDict: [Person: Double] = [:]
    var costDictBackup: [Person: Double] = [:]
    
    var debtCategory = DebtCategory()
    
    var splittingAmount: Double = 0
    
    var state: ControllerState = .defaultState {
        didSet {
            if state == .defaultState {
                addPersonBarButton.isEnabled = true
            } else if state == .addingState {
                addPersonBarButton.isEnabled = false
            }
        }
    }

    var keyboardObserver: NSObjectProtocol?

    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewHeaderView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {

                self.tableViewBottomConstraint.constant = UIScreen.main.bounds.height - endFrameValue.cgRectValue.minY

                UIView.animate(withDuration: durationValue.doubleValue, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)), animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })

        title = debtCategory.name

        splitAmountTextField.isHidden = false
        splitAmountTextField.delegate = self

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search People"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        sortPeople()
        
        tableView.keyboardDismissMode = .interactive

        tableView.register(UINib(nibName: Constants.newDebtPersonCell, bundle: nil), forCellReuseIdentifier: Constants.newDebtPersonCell)

        underlineView.backgroundColor = UIColor(for: debtCategory)
        
        updateHeaderLabels()
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

    @IBAction func addPerson(_ sender: Any) {
        let newPerson = Person()
        let indexPath = IndexPath(row: 0, section: 0)

        people.insert(newPerson, at: 0)
        selectedPeople.insert(newPerson, at: 0)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        
        splitAmountOverSelectedPeople()

        guard let cell = tableView.cellForRow(at: indexPath) as? NewDebtPersonTableViewCell else { return }
        cell.editName()
        cell.isCellSelected = true
        
        state = .addingState
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        isSplitting = splitSwitch.isOn
        tableView.reloadData()

        if isSplitting {
            costDictBackup = costDict
            
            splitAmountTextField.isEnabled = true
            splitAmountTextField.alpha = 1
            splitAmountTextField.becomeFirstResponder()
            
            splitAmountOverSelectedPeople()
        } else {
            costDict = costDictBackup
            updateHeaderLabels()
            
            splitAmountTextField.isEnabled = false
            splitAmountTextField.alpha = 0.4
            
            view.endEditing(true)
        }
    }

    @IBAction func cancelAction(_ sender: Any) {
        if state == .defaultState {
            RealmHelper.removeDebtCategory(debtCategory: debtCategory)
            dismiss(animated: true, completion: nil)
        } else if state == .addingState {
            didCancel = true
            view.endEditing(true)
        }
    }

    @IBAction func doneAction(_ sender: Any) {
        view.endEditing(true)
        RealmHelper.add(debtCategory: debtCategory, with: selectedPeople, and: costDict)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func updateHeaderLabels() {
        var totalCost: Double = 0
        selectedPeople.forEach { (person) in
            if let cost = costDict[person] {
                totalCost += cost
            }
        }
        
        totalCostLabel.text = Currency.stringWithSelectedCurrency(for: totalCost)
        
        let numberOfPeople = selectedPeople.count
        numberOfPeopleLabel.text = "over \(numberOfPeople) \(numberOfPeople == 1 ? "person" : "people")"
    }
    
    func splitAmountOverSelectedPeople() {
        for person in selectedPeople {
            costDict[person] = splittingAmount/Double(selectedPeople.count)
        }
        updateHeaderLabels()
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(ofType: NewDebtPersonTableViewCell.self, withIdentifier: Constants.newDebtPersonCell, for: indexPath)
        cell.delegate = self

        let person = getPerson(for: indexPath)

        cell.setup(with: person, selected: selectedPeople.contains(person), cost: costDict[person])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewDebtPersonTableViewCell else { return }
        cell.switchSelection()
        view.endEditing(true)
        
        let person = getPerson(for: indexPath)

        if cell.isCellSelected {
            if !isSplitting {
                cell.costTextField.becomeFirstResponder()
            }
            selectedPeople.append(person)
        } else {
            if let index = selectedPeople.index(of: person) {
                selectedPeople.remove(at: index)
            }
        }
        
        if selectedPeople.count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        if isSplitting {
            splitAmountOverSelectedPeople()
        }
        
        updateHeaderLabels()
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
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, didChangeNameTo name: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if !name.isEmpty && !didCancel {
            RealmHelper.changeName(for: people[indexPath.row], name: name)
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            selectedPeople.remove(at: 0)
            people.remove(at: 0)
            tableView.reloadData()
        }
        
        if !isSplitting {
            cell.costTextField.becomeFirstResponder()
        }
        
        didCancel = false
        state = .defaultState
    }
    
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, didChangeCostTo cost: Double) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let person = getPerson(for: indexPath)
        costDict[person] = cost
    }
    
    func newDebtPersonTableViewCell(_ cell: NewDebtPersonTableViewCell, changingCostTo cost: Double) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let person = people[indexPath.row]
        costDict[person] = cost
        
        updateHeaderLabels()
    }
}

extension NewDebtViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        let text = updatedText.replacingOccurrences(of: ",", with: ".")
        if let amount = Double(text) {
            splittingAmount = amount
            splitAmountOverSelectedPeople()
            return true
        } else if text.count == 0 {
            splittingAmount = 0
            splitAmountOverSelectedPeople()
            return true
        }
        
        return false
    }
}
