//
//  ChoresMasterTableViewController.swift
//  ChoresForCoinsiOS
//
//  Created by Andrew Harrington on 7/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase

protocol ChoreSelectionDelegate: class {
    func choreSelected(_ choreID: String)
}

class ChoresMasterTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    weak var delegate: ChoreSelectionDelegate?
    
    var ref: DatabaseReference?
    var chores: [Chore] = [Chore]()
    var userID: String?
    var parentID: String?
    var choreIDNum: String?
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var detailViewController: ChoresDetailSplitViewController?

    
    // MARK: - ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let svc = self.splitViewController {
            let leftNavController = svc.viewControllers.first as! UINavigationController
            let masterViewController = leftNavController.topViewController as! ChoresMasterTableViewController
            
            masterViewController.delegate = svc.viewControllers.last as! ChoresDetailSplitViewController
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //gets the custom parent id created in the registration
        getParentId()
        
        //cresates chore list
        createChores()
    }

    override func viewWillDisappear(_ animated: Bool) {
        ref?.removeAllObservers()
    }
    
    
    // MARK: - Custom Methods
    
    //gets the parent generated id from the user's node in the database
    func getParentId(){
        if let actualUID = userID{
            _ = Database.database().reference().child("user").child(actualUID).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let id = value?["parent_id"] as? String
                if let actualID = id{
                    self.parentID = actualID
                    self.getChildren()
                }
            }
        }
    }
    
    func isUserParent(){
        
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Bool {
                self.isActiveUserParent = val
            }
        }
    }
    
    func createChores(){
        //database reference
        ref = Database.database().reference()
        
        self.ref?.observe(.value) { (snapshot) in
            self.chores.removeAll()
            
            let dictRoot = snapshot.value as? [String : AnyObject] ?? [:]
            let dictChores = dictRoot["chores"] as? [String : AnyObject] ?? [:]
            
            for key in Array(dictChores.keys){
                
                self.chores.append(Chore(dictionary: (dictChores[key] as? [String : AnyObject])!, key: key))
                
                self.chores = self.chores.filter({$0.parentID == self.parentID })
            }
            
            self.chores.sort(by: { $0.dueDate! < $1.dueDate!})
            self.tableView.reloadData()
            
            return
        }
    }
    
    // gets all children with same parent id as user
    func getChildren() {
        children.removeAll()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictUsers = dictRoot["user"] as? [String:AnyObject] ?? [:]
            
            for key in Array(dictUsers.keys) {
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent == false})
            }
            
            self.tableView.reloadData()
        }
    }
    
    func markChoreAsPastDue(key: String){
        ref?.child("chores/\(key)/past_due").setValue("yes")
        ref?.child("chores/\(key)/user_name").setValue("Failed to Complete")
        
    }
    
    func alertCompletedAddNote(chore: Chore){
        if let completedNotifyString = chore.choreCompletedNotified {
            if completedNotifyString == "yes" {
                //parent was already notified
                return
            }
            // if completedNotify String does not exist
        } else {
            let key = chore.key
            if let childName = chore.choreUsername{
                let addNoteAlert = UIAlertController(title: "Chore Completed", message: "The chore named \(chore.name!) was completed by \(childName). Please write a note regarding the completion of this chore.", preferredStyle: UIAlertControllerStyle.alert)
                let saveNote = UIAlertAction(title: "Save", style: .default) { (saveAction) in
                    //read text from the alert box
                    let noteTextField = addNoteAlert.textFields![0] as UITextField
                    if let noteString = noteTextField.text {
                        //save text to the chore.
                        self.ref?.child("chores/\(key)/chore_note").setValue(noteString)
                        self.ref?.child("chores/\(key)/chore_completed_notified").setValue("yes")
                        
                        addNoteAlert.dismiss(animated: true, completion: nil)
                        
                    } else {
                        
                        AlertController.showAlert(self, title: "Missing Text", message: "Please type in text into the note box.")
                        
                    }
                    
                }
                
                addNoteAlert.addTextField { (textField) in
                    textField.placeholder = "Enter chore note"
                }
                addNoteAlert.addAction(saveNote)
                
                present(addNoteAlert, animated: true, completion: nil)
                
                chore.choreCompletedNotified = "yes"
                
            }
        }
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chores.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChoresMasterTableViewCell

        let choreItem = chores[indexPath.row]
        
        cell.choreNameCellLabel.text = choreItem.name
        
        if let completed = choreItem.completed {
            if completed {
                cell.completedImageCellImageView.image = #imageLiteral(resourceName: "checkmark")
                if isActiveUserParent{
                    alertCompletedAddNote(chore: choreItem)
                    choreItem.choreCompletedNotified = "yes"
                }
            } else {
                if let dueDateString = choreItem.dueDate{
                    
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "MM/dd/yyyy"
                    dateFormatterGet.dateStyle = .medium
                    if let dueDate = dateFormatterGet.date(from: dueDateString){
                        let dateNow = Date()
                        if dueDate <= dateNow {
                            markChoreAsPastDue(key: choreItem.key)
                            if isActiveUserParent{
                                if let parentNotified = choreItem.choreParentNotified{
                                    if parentNotified == "yes"{
                                        //parent notified
                                    } else {
                                        
                                        AlertController.showAlert(self, title: "Chore Past Due", message: "The chore named \(choreItem.name!) is now past due.")
                                        ref?.child("chores/\(choreItem.key)/past_due_notified").setValue("yes")
                                        choreItem.choreParentNotified = "yes"
                                    }
                                } else {
                                    AlertController.showAlert(self, title: "Chore Past Due", message: "The chore named \(choreItem.name!) is now past due.")
                                    ref?.child("chores/\(choreItem.key)/past_due_notified").setValue("yes")
                                    choreItem.choreParentNotified = "yes"
                                }
                            }
                            if let _ = choreItem.choreUsername {
                                
                                //choreItem has a username else
                            } else {
                                //set the username for the choreItem Object
                                choreItem.choreUsername = "Failed to Complete"
                            }
                            
                        }
                        
                    }
                }
                
                cell.completedImageCellImageView.image = #imageLiteral(resourceName: "redX")
            }
        }
        
        cell.usernameCellLabel.text = choreItem.choreUsername
        cell.dueDateCellLabel.text = choreItem.dueDate
        
        if let choreVal = choreItem.choreValue {
            cell.choreValueCellLabel.text = "Chore Value: \(choreVal)"
        } else {
            cell.choreValueCellLabel.text = "Chore Value: 0"
        }
        
        //gets the image URL from the chores array
        if let choreImageURL =  chores[indexPath.row].choreURL{
            
            
            let url = URL(string: choreImageURL)
            ImageService.getImage(withURL: url!, completion: { (image) in
                
                
                cell.imageCellImageView.image = image
            })
            
            
            
        } else {
            cell.imageCellImageView.image = nil
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choreIDNum = chores[indexPath.row].key
        
        if choreIDNum != nil {
            let choreid = choreIDNum!
            delegate?.choreSelected(choreid)
        }
    }
}
