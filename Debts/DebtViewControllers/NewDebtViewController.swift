import UIKit

class NewDebtViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var splitAmountTextField: UITextField!
    @IBOutlet weak var splitSwitch: UISwitch!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var tableViewHeaderView: UIView!
    
    let searchController = UISearchController(searchResultsController: nil)

    var isSplitting = false
    var isMyDebt = false
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var selectedPeople: [Person] = []
    var costDict: [Person: Double] = [:]
    var debtCategory = DebtCategory()

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

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search People"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationController?.navigationBar.prefersLargeTitles = true

//        people = RealmHelper.getAllPersons()
        sortPeople()
        
        tableView.keyboardDismissMode = .interactive

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

    @IBAction func addPerson(_ sender: Any) {
        let newPerson = Person()
        let indexPath = IndexPath(row: 0, section: 0)

        people.insert(newPerson, at: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .none, animated: false)

        guard let cell = tableView.cellForRow(at: indexPath) as? NewDebtPersonTableViewCell else { return }
//        cell.editCo

//        state = .addingState
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
        RealmHelper.removeEmptyDebtCategories()
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
