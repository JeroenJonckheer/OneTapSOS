import UIKit

class InfoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "About This App"

        // Voeg een "Close" knop toe
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeInfo))
        navigationItem.leftBarButtonItem = closeButton

        let label = UILabel()
        label.text = "SOS App v1.0\nBuilt by Jeroen Jonckheer\nAll rights reserved."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc func closeInfo() {
        dismiss(animated: true, completion: nil)
    }
}

