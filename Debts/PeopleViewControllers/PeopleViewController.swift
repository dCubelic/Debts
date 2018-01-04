import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var people: [Person] = []
    var filteredPeople: [Person] = []
    var sortComparator = nameComparator
    
    private static let nameComparator: (Person, Person) -> Bool = { $0.name.lowercased() < $1.name.lowercased() }
    private static let totalDebtComparator: (Person, Person) -> Bool = { $0.totalDebt > $1.totalDebt }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.addPersonViewController) as! AddPersonViewController
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        
        present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: Any) {
        guard let barButton = sender as? UIBarButtonItem else { return }
        
        if tableView.isEditing {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = nil
            barButton.style = .plain
            barButton.title = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .clear
            barButton.style = .done
            barButton.title = "Cancel"
            tableView.setEditing(true, animated: true)
        }

    }
    
    @IBAction func sortAction(_ sender: Any) {
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
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath) as! PersonTableViewCell
            tableView.scrollToNearestSelectedRow(at: .top, animated: true)
//            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)

            cell.editName()
            
            completionHandler(true)
        }
        
        delete.backgroundColor = .red
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [edit, delete])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }

}

extension PeopleViewController: AddPersonViewControllerDelegate {
    func addPersonViewControllerDidAddPerson(_ vc: AddPersonViewController, person: Person) {
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
    }
}
