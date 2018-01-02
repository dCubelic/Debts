import UIKit

class PersonDetailViewController: UIViewController {

    
    var person: Person?
    var debtCategories: [DebtCategoryByPerson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        guard let person = person else { return }
        
        title = person.name
        debtCategories = RealmHelper.getDebtCategories(for: person)
    }

}

extension PersonDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debtCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DetailCell")
        
        cell.selectionStyle = .none
        cell.textLabel?.text = debtCategories[indexPath.row].debtCategory.name
        cell.detailTextLabel?.text = String(debtCategories[indexPath.row].cost)
        
        return cell
    }
}
