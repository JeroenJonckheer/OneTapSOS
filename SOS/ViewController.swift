import UIKit
import MessageUI
import CoreLocation

class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request location access
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Add Settings button
        let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(openSettings))
        navigationItem.rightBarButtonItem = settingsButton

        // Add Info button (i-icon)
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(openInfo))
        navigationItem.leftBarButtonItem = infoButton

        // Add the SOS button
        addSOSButton()
    }

    func addSOSButton() {
        let sosImageView = UIImageView(image: UIImage(named: "sos_button"))
        sosImageView.translatesAutoresizingMaskIntoConstraints = false
        sosImageView.contentMode = .scaleAspectFit

        // Add shadow for 3D effect
        sosImageView.layer.shadowColor = UIColor.black.cgColor
        sosImageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        sosImageView.layer.shadowOpacity = 0.7
        sosImageView.layer.shadowRadius = 10

        view.addSubview(sosImageView)

        NSLayoutConstraint.activate([
            sosImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sosImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sosImageView.widthAnchor.constraint(equalToConstant: 150),
            sosImageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        // Transparent button overlay
        let sosButton = UIButton(type: .custom)
        sosButton.backgroundColor = .clear
        sosButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sosButton)

        NSLayoutConstraint.activate([
            sosButton.centerXAnchor.constraint(equalTo: sosImageView.centerXAnchor),
            sosButton.centerYAnchor.constraint(equalTo: sosImageView.centerYAnchor),
            sosButton.widthAnchor.constraint(equalTo: sosImageView.widthAnchor),
            sosButton.heightAnchor.constraint(equalTo: sosImageView.heightAnchor)
        ])

        // Add press animations
        sosButton.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        sosButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchDragExit])

        // Add SOS action
        sosButton.addTarget(self, action: #selector(sosButtonPressed), for: .touchUpInside)
    }

    @objc func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) // Knop iets kleiner maken
        })
    }

    @objc func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform.identity // Knop terug naar normaal
        })
    }

    @objc func sosButtonPressed(_ sender: UIButton) {
        // Speel eerst de druk-animatie af
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                sender.transform = CGAffineTransform.identity
            }) { _ in
                // Hierna pas de melding en verdere logica uitvoeren
                self.continueSOSProcess(sender)
            }
        }
    }

    func continueSOSProcess(_ sender: UIButton) {
        #if targetEnvironment(simulator)
        let canSend = false
        #else
        let canSend = MFMessageComposeViewController.canSendText()
        #endif

        if canSend {
            guard let savedContacts = UserDefaults.standard.array(forKey: "selectedContacts") as? [String],
                  !savedContacts.isEmpty else {
                let alert = UIAlertController(title: "No contact selected",
                                              message: "Please select a contact before sending an SOS message.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }

            sender.isEnabled = false

            let feedbackLabel = UILabel()
            feedbackLabel.text = "Help has been notified!"
            feedbackLabel.textAlignment = .center
            feedbackLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            feedbackLabel.textColor = UIColor.white
            feedbackLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            feedbackLabel.layer.cornerRadius = 10
            feedbackLabel.clipsToBounds = true
            feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(feedbackLabel)

            NSLayoutConstraint.activate([
                feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                feedbackLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                feedbackLabel.widthAnchor.constraint(equalToConstant: 250),
                feedbackLabel.heightAnchor.constraint(equalToConstant: 50)
            ])

            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                feedbackLabel.removeFromSuperview()
                sender.isEnabled = true
            }

            let messageVC = MFMessageComposeViewController()
            var messageBody = "I have an emergency, please help!"

            if let location = currentLocation {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                let locationURL = "https://maps.google.com/?q=\(latitude),\(longitude)"
                messageBody += "\nMy location: \(locationURL)"
            }

            messageVC.recipients = savedContacts
            messageVC.body = messageBody
            messageVC.messageComposeDelegate = self
            present(messageVC, animated: true, completion: nil)

        } else {
            let alert = UIAlertController(title: "Simulation",
                                          message: "SMS cannot be sent on the simulator, but this would work on a real iPhone.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }

    @objc func openSettings() {
        let contactsVC = ContactsViewController()
        let navController = UINavigationController(rootViewController: contactsVC)
        present(navController, animated: true, completion: nil)
    }

    @objc func openInfo() {
        let infoVC = InfoViewController()
        let navController = UINavigationController(rootViewController: infoVC)
        present(navController, animated: true, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
