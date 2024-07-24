//
//  AboutTableViewController.swift
//  Food Pin
//
//  Created by Dzmitry Hlushchuk on 23.07.24.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {
    
    enum Section {
        case feedback, followUs
    }
    
    struct LinkItem: Hashable {
        var text: String
        var link: String
        var image: String
    }
    
    var sectionContent = [
        [
            LinkItem(
                text: String(localized: "Rate us on App Store"),
                link: "https://www.apple.com/ios/app-store/",
                image: "store"
            ),
            LinkItem(
                text: String(localized: "Tell us your feedback"),
                link: "https://www.appcoda.com/contact",
                image: "chat"
            )
        ],
        [
            LinkItem(
                text: "Twitter",
                link: "https://twitter.com/appcodamobile",
                image: "twitter"
            ),
            LinkItem(
                text: "Facebook",
                link: "https://facebook.com/appcodamobile",
                image: "facebook"
            ),
            LinkItem(
                text: "Instagram",
                link: "https://www.instagram.com/appcodadotcom",
                image: "instagram"
            )
        ]
    ]
    
    lazy var dataSource = configureDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        updateSnapshot()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
//        guard let linkItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
//        if let url = URL(string: linkItem.link) {
//            UIApplication.shared.open(url)
//        }
        switch indexPath.section {
        case 0:
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            performSegue(withIdentifier: "showWebView", sender: cell)
        case 1:
            openWithSafariViewController(indexPath: indexPath)
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            let webVC = segue.destination as! WebViewController
            if let indexPath = tableView.indexPathForSelectedRow,
               let linkItem = dataSource.itemIdentifier(for: indexPath) {
                webVC.targetURL = linkItem.link
            }
        }
    }

    func configureDataSource() -> UITableViewDiffableDataSource<Section, LinkItem> {
        let cellIdentifier = "aboutcell"
        let dataSource = UITableViewDiffableDataSource<Section, LinkItem>(tableView: tableView) { tableView, indexPath, linkItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            var configure = cell.defaultContentConfiguration()
            configure.text = linkItem.text
            configure.image = UIImage(named: linkItem.image)
            cell.contentConfiguration = configure
            return cell
        }
        return dataSource
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, LinkItem>()
        snapshot.appendSections([.feedback, .followUs])
        snapshot.appendItems(sectionContent[0], toSection: .feedback)
        snapshot.appendItems(sectionContent[1], toSection: .followUs)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func openWithSafariViewController(indexPath: IndexPath) {
        guard let linkItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
        if let url = URL(string: linkItem.link) {
            let safariController = SFSafariViewController(url: url)
            present(safariController, animated: true)
        }
    }

}
