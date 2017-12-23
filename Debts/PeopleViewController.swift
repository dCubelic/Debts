import UIKit
import RealmSwift

class PeopleViewController: UIViewController {

    let realm = try! Realm()
    
    var persons: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        persons = RealmHelper.getAllPersons()
    }

}

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DetailCell")
        cell.textLabel?.text = persons[indexPath.row].name
        cell.detailTextLabel?.text = String(RealmHelper.getCost(for: persons[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.personDetailViewController) as! PersonDetailViewController
        vc.personId = persons[indexPath.row].id
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
