//
//  ViewController.swift
//  Sticky Links
//
//  Created by Samridh Agarwal on 29/09/21.
//

import UIKit
import CoreData
class LinksViewController: UITableViewController {
    
    var links=[Items]()
    var filteredLinksData: [Items] = []
    var searchInProgress: Bool = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Items> = Items.fetchRequest()
    var selectedProperty:Category?{
        didSet{
            loadLink()
        }
    }
  
    @IBOutlet weak var searchBar: UISearchBar!
 
    
//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.primaryBackgroundColor
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        filteredLinksData = links
        self.title = selectedProperty?.name
    }
}

//MARK: Table View
extension LinksViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchInProgress == true {
            return filteredLinksData.count
        } else {
            return links.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell", for: indexPath)
        if searchInProgress == true {
            cell.textLabel?.text = filteredLinksData[indexPath.row].title
        } else {
            cell.textLabel?.text = links[indexPath.row].title
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OpenLinkSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! WebViewController
        destinationVC.selectedLink = links[tableView.indexPathForSelectedRow!.row]

    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteContextualAction(forRowat: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    private func deleteContextualAction(forRowat indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            let title = self.links[indexPath.row].title!
            let alert = UIAlertController(title: "Are you sure you want to delete this item?", message: "\(title) will be deleted and can't be retrived afterwards", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                let link = self.links[indexPath.row]
                self.context.delete(link)
                self.links.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.saveLink()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        action.image = UIImage(systemName: "trash.fill")

        return action
    }
}

//MARK: Add Links
extension LinksViewController{
    @IBAction func addLinks(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        var linktextField = UITextField()
        let alert = UIAlertController(title: "Add your favourite Webpages", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let newLink = Items(context: self.context)
            newLink.title = textField.text!
            newLink.link = linktextField.text!
            newLink.parentCategory = self.selectedProperty
            self.links.append(newLink)
            self.saveLink()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add title for webpage"
            textField = alertTextField
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add link for webpage"
            linktextField = alertTextField
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: BOOKMARK BUTTON
extension LinksViewController{
    @IBAction func bookmarkLinksButton(_ sender: UIButton) {
    }
}

//MARK: SORTING
extension LinksViewController{
    @IBAction func sortLinksButton(_ sender: UIBarButtonItem) {
    }
}

//MARK: SEARCH BAR
extension LinksViewController: UISearchBarDelegate{
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        self.searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        if searchBar.text?.isEmpty == true {
            searchInProgress = false
            tableView.reloadData()
        } else {
            searchInProgress = true
            let textToSearch = searchBar.text!.lowercased()
            filteredLinksData = links.filter ({ $0.title!.lowercased().contains(textToSearch)})
            tableView.reloadData()
        }
    }
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchInProgress = false
            tableView.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchInProgress = true
            searchBar.showsCancelButton = true
            let caseInsensitiveText = searchText.lowercased()
            filteredLinksData = searchText.isEmpty ? links : links.filter ({ $0.title!.lowercased().contains(caseInsensitiveText)})
            tableView.reloadData()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchInProgress = true
            tableView.reloadData()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchInProgress = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.tableView.resignFirstResponder()
            self.searchBar.showsCancelButton = false
            tableView.reloadData()
        }
        
        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            return true
        }
}


//MARK: Helper Functions
extension LinksViewController{
    func saveLink(){
        do{
            try context.save()
        }
        catch{
            print("\(error)")
        }
        tableView.reloadData()
    }
    
    func loadLink(){
        do{
            links = try context.fetch(request)
        }catch{
            print("\(error)")
        }
        tableView.reloadData()
    }
    
}


