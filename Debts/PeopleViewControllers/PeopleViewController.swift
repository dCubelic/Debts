import UIKit
import RealmSwift

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var people: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadPeople()
    }
    
    func reloadPeople() {
        people = RealmHelper.getAllPersons()
        tableView.reloadData()
    }

    @IBAction func addPerson(_ sender: Any) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.addPersonViewController) as! AddPersonViewController
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        
        present(navVC, animated: true, completion: nil)
    }
}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DetailCell")
        
        cell.textLabel?.text = people[indexPath.row].name
        cell.detailTextLabel?.text = String(RealmHelper.getCost(for: people[indexPath.row]))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.personDetailViewController) as! PersonDetailViewController
        
        vc.person = people[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            RealmHelper.removePerson(person: people[indexPath.row])
            people.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension PeopleViewController: AddPersonViewControllerDelegate {
    func addPersonViewControllerDidAddPerson(_ vc: AddPersonViewController, person: Person) {
        reloadPeople()
    }
}
