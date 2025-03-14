import UIKit
import Contacts

class ContactsViewController: UITableViewController {

    var contacts: [CNContact] = []
    var selectedContacts: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select contacts"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // Voeg een "Sluiten"-knop toe
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSettings))
        navigationItem.leftBarButtonItem = closeButton

        // Haal opgeslagen contacten op
        if let savedContacts = UserDefaults.standard.array(forKey: "selectedContacts") as? [String] {
            selectedContacts = savedContacts
        }

        fetchContacts()
    }
    
    func fetchContacts() {
        DispatchQueue.global(qos: .userInitiated).async { // Achtergrondthread
            let store = CNContactStore()
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)

            var fetchedContacts: [CNContact] = []

            do {
                try store.enumerateContacts(with: request) { (contact, _) in
                    if !contact.phoneNumbers.isEmpty {
                        fetchedContacts.append(contact)
                    }
                }
                
                // Terug naar de hoofdthread om de UI te updaten
                DispatchQueue.main.async {
                    self.contacts = fetchedContacts
                    self.tableView.reloadData()
                }

            } catch {
                print("Fout bij ophalen contacten: \(error)")
            }
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = contacts[indexPath.row]
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? "Geen nummer"

        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName) - \(phoneNumber)"
        cell.accessoryType = selectedContacts.contains(phoneNumber) ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""

        if selectedContacts.contains(phoneNumber) {
            selectedContacts.removeAll { $0 == phoneNumber }
        } else {
            selectedContacts.append(phoneNumber)
        }

        // Sla selectie op
        UserDefaults.standard.set(selectedContacts, forKey: "selectedContacts")

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // Sluit de instellingenpagina
    @objc func closeSettings() {
        dismiss(animated: true, completion: nil)
    }
}
