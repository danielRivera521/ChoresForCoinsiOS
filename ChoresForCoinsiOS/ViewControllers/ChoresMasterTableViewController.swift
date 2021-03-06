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

class ChoresMasterTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    // MARK: - Properties
    
    weak var delegate: ChoreSelectionDelegate?
    
    var ref: DatabaseReference?
    var chores: [Chore] = [Chore]()
    var userID: String?
    var parentID: String?
    var choreIDNum: String?
    var isActiveUserParent = false
    var children = [ChildUser] ()
    var masterViewController: ChoresMasterTableViewController?
    var detailViewController: ChoresDetailSplitViewController?
    var notifyString = "no"
    
    var bgImage: UIImage?
    
    // MARK: - ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            splitViewController?.preferredDisplayMode = .allVisible
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            splitViewController?.preferredDisplayMode = .automatic
        }
    

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let svc = self.splitViewController {
            let leftNavController = svc.viewControllers.first as! UINavigationController
            masterViewController = leftNavController.topViewController as? ChoresMasterTableViewController
            detailViewController = svc.viewControllers.last as? ChoresDetailSplitViewController
            
            masterViewController?.delegate = detailViewController!
        }
        
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!
        
        //gets the custom parent id created in the registration
        getParentId()
        
        isUserParent()
        
        
        //cresates chore list
        createChores()
        // set background color to the table
        getBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //gets the firebase generated id
        userID = (Auth.auth().currentUser?.uid)!

        //gets the custom parent id created in the registration
        getParentId()

        isUserParent()


        //cresates chore list
        createChores()
        // set background color to the table
        getBackground()
        
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
    
    func getBackground() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("user/\(uid)/bg_image").observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? Int {
                    switch value {
                    case 0:
                        self.bgImage = #imageLiteral(resourceName: "whiteBG")
                        
                        let imageView = UIImageView(image: self.bgImage)
                        self.tableView.backgroundView = imageView
                    case 1:
                        self.bgImage = #imageLiteral(resourceName: "orangeBG")
                        
                        let imageView = UIImageView(image: self.bgImage)
                        self.tableView.backgroundView = imageView
                    case 2:
                        self.bgImage = #imageLiteral(resourceName: "greenBG")
                        
                        let imageView = UIImageView(image: self.bgImage)
                        self.tableView.backgroundView = imageView
                    case 3:
                        self.bgImage = #imageLiteral(resourceName: "redBG")
                        
                        let imageView = UIImageView(image: self.bgImage)
                        self.tableView.backgroundView = imageView
                    case 4:
                        self.bgImage = #imageLiteral(resourceName: "purpleBG")
                        
                        let imageView = UIImageView(image: self.bgImage)
                        self.tableView.backgroundView = imageView
                    default:
                        self.bgImage = #imageLiteral(resourceName: "whiteBG")
                        
                        let imageView = UIImageView(image: self.bgImage)
                        self.tableView.backgroundView = imageView
                    }
                }
            }
        }
        
        let imageView = UIImageView(image: self.bgImage)
        self.tableView.backgroundView = imageView
        //self.tableView.reloadData()
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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chores.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChoresMasterTableViewCell

        let choreItem = chores[indexPath.row]
        if addRedDotToChore(chore: choreItem){
            cell.choreNotifyDot.isHidden = false
        } else {
            cell.choreNotifyDot.isHidden = true
        }
        cell.choreNameCellLabel.text = choreItem.name
        cell.imageCellImageView.isHidden = true
    
        cell.completedImageCellImageView.image = #imageLiteral(resourceName: "redX")
        if let completed = choreItem.completed {
            if completed {
                cell.completedImageCellImageView.image = #imageLiteral(resourceName: "checkmark")
                if isActiveUserParent{
                    alertCompletedAndAddNote(chore: choreItem)
                    choreItem.choreCompletedNotified = "yes"
                }
            } else {
                if let dueDateString = choreItem.dueDate{
                    
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "MM/dd/yyyy"
                    dateFormatterGet.dateStyle = .medium
                    if let dueDate = dateFormatterGet.date(from: dueDateString){
                        let dateNow = Date()
                        
                        let dateCheck = Calendar.current.date(byAdding: .day, value: 1, to: dueDate)
                        
                        if dateCheck! < dateNow {
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
                                choreItem.choreUsername = "Past Due"
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
        
        if choreItem.choreUsername == nil {
            ref?.child("chores/\(choreItem.key)/user_name").observeSingleEvent(of: .value, with: { (snapshot) in
                if let val = snapshot.value as? String {
                    cell.usernameCellLabel.text = val
                }
            })
        } else {
            cell.usernameCellLabel.text = choreItem.choreUsername
        }
        
        cell.dueDateCellLabel.text = choreItem.dueDate
        
        if let choreVal = choreItem.choreValue {
            cell.choreValueCellLabel.text = "\(choreVal)"
        } else {
            cell.choreValueCellLabel.text = "0"
        }
        
        //gets the image URL from the chores array
        if let choreImageURL =  chores[indexPath.row].choreURL{
            cell.imageCellImageView.isHidden = false
            
            let url = URL(string: choreImageURL)
            ImageService.getImage(withURL: url!, completion: { (image) in
                
                
                cell.imageCellImageView.image = image
                
                if let cid = self.choreIDNum {
                    self.delegate?.choreSelected(cid)
                }
            })
            
        } else {
            cell.imageCellImageView.image = nil
        }
        
         cell.backgroundColor = UIColor(white: 1, alpha: 0.5)

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
        
        if let detailViewController = delegate as? ChoresDetailSplitViewController {
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }
    func addRedDotToChore(chore: Chore) -> Bool{
        if let uid = chore.assignChild {
            if userID! == uid {
                if let notifiedChore = chore.notifyAssigned{
                    return !notifiedChore
                }
            }
        }
        
        return false
    }
    
    func alertCompletedAndAddNote(chore: Chore){
        notifyString = "no"
        if let completedNotifyString = chore.choreCompletedNotified {
            notifyString = completedNotifyString
            if notifyString == "yes" {
                //parent was already notified
                return
            }
        }
        // if notifyString is "no"
        if notifyString == "no" {
            let key = chore.key
            if let childName = chore.choreUsername{
                let addNoteAlert = UIAlertController(title: "Chore Completed", message: "The chore named \(chore.name!) was completed by \(childName). Please write a note regarding the completion of this chore.", preferredStyle: UIAlertControllerStyle.alert)
                let saveNote = UIAlertAction(title: "Save", style: .default) { (saveAction) in
                    //read text from the alert box
                    var choreNoteString: String = ""
                    let noteTextField = addNoteAlert.textFields![0] as UITextField
                    if let noteString = noteTextField.text {
                        choreNoteString = noteString
                        if noteString.isEmpty {
                            if let oldNote = chore.choreNote {
                                choreNoteString = oldNote
                            }
                        }
                        //save text to the chore.
                        self.ref?.child("chores/\(key)/chore_note").setValue(choreNoteString)
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
                notifyString = "yes"
                
            }
        }
    }
    
    @IBAction func unwindToChoreList(segue:UIStoryboardSegue) {}
}
