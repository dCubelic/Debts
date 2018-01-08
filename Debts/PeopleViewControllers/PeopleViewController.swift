import UIKit

enum ControllerState {
    case defaultState, addingState
}

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var sortComparator = nameComparator
    var state: ControllerState = .defaultState {
        didSet {
            if state == .defaultState {
                rightBarButtonItem.isEnabled = true
                leftBarButtonItem.image = #imageLiteral(resourceName: "Sort")
            } else if state == .addingState {
                rightBarButtonItem.isEnabled = false
                leftBarButtonItem.image = nil
                
                leftBarButtonItem.title = "Cancel"
            }
        }
    }
    
    private static let nameComparator: (Person, Person) -> Bool = { $0.name.lowercased() < $1.name.lowercased() }
    private static let totalDebtComparator: (Person, Person) -> Bool = { $0.totalDebt > $1.totalDebt }
    
    var keyboardObserver: NSObjectProtocol? = nil
    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
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
    
    @objc func tapAction() {
        view.endEditing(true)
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

    @IBAction func addPerson(_ sender: Any) {
////        let newPerson = RealmHelper.addPerson(name: "")
//        let newPerson = Person()
//        let indexPath = IndexPath(row: 0, section: 0)
////
//        people.insert(newPerson, at: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//
////
//////        let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as! PersonTableViewCell
//        let cell = tableView.cellForRow(at: indexPath) as! PersonTableViewCell
//        cell.editName()
//        tableView.isUserInteractionEnabled = false
//
//        state = .addingState

        
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.addPersonViewController) as! AddPersonViewController
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)

        present(navVC, animated: true, completion: nil)
    }
    
//    @IBAction func editAction(_ sender: Any) {
//        guard let barButton = sender as? UIBarButtonItem else { return }
//        
//        if tableView.isEditing {
//            navigationItem.rightBarButtonItem?.isEnabled = true
//            navigationItem.rightBarButtonItem?.tintColor = nil
//            barButton.style = .plain
//            barButton.title = "Edit"
//            tableView.setEditing(false, animated: true)
//        } else {
//            navigationItem.rightBarButtonItem?.isEnabled = false
//            navigationItem.rightBarButtonItem?.tintColor = .clear
//            barButton.style = .done
//            barButton.title = "Cancel"
//            tableView.setEditing(true, animated: true)
//        }
//
//    }
    
    @IBAction func leftBarButtonAction(_ sender: Any) {
        if state == .defaultState {
            let actionSheet = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Name", style: .default, handler: { (alertAction) in
                self.sortComparator = PeopleViewController.nameComparator
                self.sortPeople()
            }))
            actionSheet.addAction(UIAlertAction(title: "Total Debt", style: .default, handler: { (alertAction) in
                self.sortComparator = PeopleViewController.totalDebtComparator
                self.sortPeople()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            reloadPeople()
            tableView.isUserInteractionEnabled = true
            state = .defaultState
        }
    }
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPeople.count
        }
        
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.personCell, for: indexPath) as! PersonTableViewCell
        
        var person: Person
        if isFiltering() {
            person = filteredPeople[indexPath.row]
        } else {
            person = people[indexPath.row]
        }
        
        cell.delegate = self
        cell.setup(with: person)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.personDetailViewController) as! PersonDetailViewController
        
        var person: Person
        if isFiltering() {
            person = filteredPeople[indexPath.row]
        } else {
            person = people[indexPath.row]
        }
        
        vc.person = person
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            var person: Person
            if self.isFiltering() {
                person = self.filteredPeople[indexPath.row]
            } else {
                person = self.people[indexPath.row]
            }
            
            RealmHelper.removePerson(person: person)
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
            
            completionHandler(true)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit\nName") { (action, view, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath) as! PersonTableViewCell

            cell.editName()
            
            completionHandler(true)
        }
        
        delete.backgroundColor = .red
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }

}

extension PeopleViewController: AddPersonViewControllerDelegate {
    func addPersonViewController(_ vc: AddPersonViewController, didAdd person: Person) {
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
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
    func personTableViewCell(_ cell: PersonTableViewCell, didChangeNameTo name: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        var person: Person
        if self.isFiltering() {
            person = self.filteredPeople[indexPath.row]
        } else {
            person = self.people[indexPath.row]
        }
        
        RealmHelper.changeName(for: person, name: name)
        
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        tableView.isUserInteractionEnabled = true
        state = .defaultState
    }
    
    func personTableViewCellDidCancel(_ cell: PersonTableViewCell) {
        tableView.isUserInteractionEnabled = true
        state = .defaultState
        reloadPeople()
    }
}
