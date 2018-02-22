import UIKit
import CoreSpotlight

enum ControllerState {
    case defaultState, addingState
}

class PeopleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var sortComparator = totalDebtComparator
    var state: ControllerState = .defaultState {
        didSet {
            if state == .defaultState {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
                leftBarButtonItem.image = #imageLiteral(resourceName: "Sort")
            } else if state == .addingState {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditting))
                leftBarButtonItem.image = nil
                leftBarButtonItem.title = "Cancel"
            }
        }
    }
    var didCancel = false
    
    private static let nameComparator: (Person, Person) -> Bool = { $0.name.lowercased() < $1.name.lowercased() }
    private static let totalDebtComparator: (Person, Person) -> Bool = {
        if $0.totalDebt >= 0 && $1.totalDebt >= 0 {
            return $0.totalDebt > $1.totalDebt
        } else {
            return $0.totalDebt < $1.totalDebt
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
        
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
                    self.tableViewBottomConstraint.constant = UIScreen.main.bounds.height - endFrameValue.cgRectValue.minY - tabBarHeight
                }
                
                UIView.animate(withDuration: durationValue.doubleValue, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)), animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doneEditting))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        title = "People"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search People"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.register(UINib(nibName: Constants.personCell, bundle: nil), forCellReuseIdentifier: Constants.personCell)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPeople), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        reloadPeople()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = nil
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
    
    @objc func reloadPeople() {
        people = RealmHelper.getAllPersons()
        sortPeople()
        if let searchText = searchController.searchBar.text {
            filterPeople(for: searchText)
        }
    }
    
    func sortPeople() {
        people.sort(by: sortComparator)
        tableView.reloadData()
    }
    
    @objc func doneEditting() {
        view.endEditing(true)
    }
    
    @objc func addPerson() {
        let newPerson = Person()
        let indexPath = IndexPath(row: 0, section: 0)
        
        tableView.beginUpdates()
        people.insert(newPerson, at: 0)
        tableView.insertRows(at: [indexPath], with: .top)
        tableView.endUpdates()
        
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath) as? PersonTableViewCell
        cell?.editName()
        
        state = .addingState
    }
    
    @IBAction func leftBarButtonAction(_ sender: Any) {
        if state == .defaultState {
            let actionSheet = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Name", style: .default, handler: { (_) in
                self.sortComparator = PeopleViewController.nameComparator
                self.sortPeople()
            }))
            actionSheet.addAction(UIAlertAction(title: "Total Debt", style: .default, handler: { (_) in
                self.sortComparator = PeopleViewController.totalDebtComparator
                self.sortPeople()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
        } else if state == .addingState {
            didCancel = true
            view.endEditing(true)
//            reloadPeople()
            //            tableView.isUserInteractionEnabled = true
//            state = .defaultState
        }
    }
    
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if people.count == 0 {
            emptyTableViewLabel.isHidden = false
        } else {
            emptyTableViewLabel.isHidden = true
        }
        
        if isFiltering() {
            return filteredPeople.count
        }
        
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: PersonTableViewCell.self, withIdentifier: Constants.personCell, for: indexPath)
        
        let person = getPerson(for: indexPath)
        
        cell.delegate = self
        cell.setup(with: person)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: PersonDetailViewController.self, withIdentifier: Constants.Storyboard.personDetailViewController)
        
        let person = getPerson(for: indexPath)
        
        vc.person = person
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
            let person = self.getPerson(for: indexPath)
            
            let alert = UIAlertController(title: "Remove Person?", message: "Are you sure you wish to remove '\(person.name)' and all of their debts?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [person.uuid], completionHandler: nil)
                RealmHelper.removePerson(person: person)
                NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)

            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            completionHandler(false)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit\nName") { (_, _, completionHandler) in
            guard let cell = tableView.cellForRow(at: indexPath) as? PersonTableViewCell else { return }
            
            cell.editName()
            self.state = .addingState
            
            completionHandler(true)
        }
        
        delete.backgroundColor = .red
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
}

extension PeopleViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterPeople(for: searchText)
        }
    }
}

extension PeopleViewController: PersonTableViewCellDelegate {
    func personTableViewCellDidEndEditing(_ cell: PersonTableViewCell, name: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if didCancel || name.isEmpty {
            didCancel = false
            reloadPeople()
            state = .defaultState
            return
        }
        
        let person = getPerson(for: indexPath)
        RealmHelper.updateName(for: person, name: name)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        didCancel = false
        state = .defaultState
    }
}
