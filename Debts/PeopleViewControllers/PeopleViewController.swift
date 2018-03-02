import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var people: [Person] = []
    var filteredPeople: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "People"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search People"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.keyboardDismissMode = .onDrag
        
        reloadPeople()
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
    
    func reloadPeople() {
//        people = RealmHelper.getAllPersons()
        people = RealmHelper.getAll()
        sortPeople()
        tableView.reloadData()
    }
    
    func sortPeople() {
        people.sort { (firstPerson, secondPerson) -> Bool in
            return firstPerson.name < secondPerson.name
        }
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
    
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPeople.count
        }
        
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: Constants.detailCell)
        
        var person: Person
        if isFiltering() {
            person = filteredPeople[indexPath.row]
        } else {
            person = people[indexPath.row]
        }
        
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = String(RealmHelper.getCost(for: person))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.personDetailViewController) as! PersonDetailViewController
        
        var person: Person
        if isFiltering() {
            person = filteredPeople[indexPath.row]
        } else {
            person = people[indexPath.row]
        }
        
        vc.person = person
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var person: Person
        if isFiltering() {
            person = filteredPeople[indexPath.row]
        } else {
            person = people[indexPath.row]
        }
        
        if editingStyle == .delete {
            if isFiltering() {
                if let index = people.index(of: filteredPeople[indexPath.row]) {
                    people.remove(at: index)
                }
                filteredPeople.remove(at: indexPath.row)
            } else {
                people.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            RealmHelper.removePerson(person: person)
        }
    }
}

extension PeopleViewController: AddPersonViewControllerDelegate {
    func addPersonViewControllerDidAddPerson(_ vc: AddPersonViewController, person: Person) {
        reloadPeople()
    }
}

extension PeopleViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterPeople(for: searchText)
        }
    }
    
}
