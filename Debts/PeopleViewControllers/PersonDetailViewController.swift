import UIKit
import RealmSwift

class PersonDetailViewController: UIViewController {

    let realm = try! Realm()
    
    var person: Person?
    var debts: [DebtByPerson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let person = person else { return }
        
        title = person.name
        debts = RealmHelper.getDebts(for: person.id)
    }

}

extension PersonDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DetailCell")
        
        cell.selectionStyle = .none
        cell.textLabel?.text = debts[indexPath.row].debt.name
        cell.detailTextLabel?.text = String(debts[indexPath.row].cost)
        
        return cell
    }
}
