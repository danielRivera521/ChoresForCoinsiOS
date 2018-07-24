//
//  OverviewViewController.swift
//  ChoresForCoinsiOS
//

//  Created by Andrew Harrington on 6/16/18.
//  Copyright © 2018 Daniel Rivera, Andrew Harrington. All rights reserved.
//

import UIKit
import Firebase
import Charts

class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var overviewTableView: UITableView!
    @IBOutlet weak var childRedeemView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinAmtLabel: UILabel!
    @IBOutlet weak var redDot: UIImageView!
    
    
    // MARK: Properties
    
    var userID: String?
    var parentID: String?
    var children = [ChildUser] ()
    var chores: [Chore] = [Chore]()
    var childrenCoinsTotal = PieChartDataEntry ()
    var childrenCoinsAllTimeTotal = PieChartDataEntry ()
    var childrenCompletedChores = PieChartDataEntry ()
    var childrenToDoChores = PieChartDataEntry ()
    var childrenWeeklyChores = [[Double]] ()
    var monthName: String = ""
    
    var coinValue = 0
    var ref: DatabaseReference?
    var runningTotal = 0
    var isParent = true
    var isActiveUserParent = false
    var coinTotals = [RunningTotal] ()
    var coinConversion: Double = 1
    var bgImg: UIImage?
    var animRedeemView: UIImageView?
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // get animation ready
        animRedeemView = AnimationHelper.createRedeemAnim(vc: self)
        
        // get userid
        if let uid = Auth.auth().currentUser?.uid {
            userID = uid
        }
        
        getBackground()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadPage()
        isUserParent()
        
    }
    func loadPage(){
        
        childRedeemView.isHidden = true
        
        if (Auth.auth().currentUser?.displayName) != nil{
            displayHeaderName()
            ref = Database.database().reference()
            
            //acquire parent ID
            getParentId()
            
            //create choreList
            createChores()
            
            // get profile pic
            getPhoto()
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            monthName = dateFormatter.string(from: currentDate)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Custom Methods
    
    func getBackground() {
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("user/\(uid)/bg_image").observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? Int {
                    switch value {
                    case 0:
                        self.bgImg = #imageLiteral(resourceName: "whiteBG")
                    case 1:
                        self.bgImg = #imageLiteral(resourceName: "orangeBG")
                    case 2:
                        self.bgImg = #imageLiteral(resourceName: "greenBG")
                    case 3:
                        self.bgImg = #imageLiteral(resourceName: "redBG")
                    case 4:
                        self.bgImg = #imageLiteral(resourceName: "purpleBG")
                    default:
                        self.bgImg = #imageLiteral(resourceName: "whiteBG")
                    }
                }
            }
        }
        
        let imageView = UIImageView(image: self.bgImg)
        self.overviewTableView.backgroundView = imageView
    }
    
    func getPhoto() {
        
        let DatabaseRef = Database.database().reference()
        if let uid = userID{
            DatabaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                //gets the image URL from the user database
                if let profileURL = value?["profile_image_url"] as? String{
                    
                    let url = URL(string: profileURL)
                    ImageService.getImage(withURL: url!, completion: { (image) in
                        
                        self.profileButton.setBackgroundImage(image, for: .normal)
                    })
                    
                    //  self.profileButton.loadImagesUsingCacheWithUrlString(urlString: profileURL, inViewController: self)
                    //turn button into a circle
                    self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                    self.profileButton.layer.masksToBounds = true
                }
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
            
            return
        }
    }
    //gets the parent generated id from the user's node in the database
    func getParentId(){
        if let actualUID = userID{
            _ = Database.database().reference().child("user").child(actualUID).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let id = value?["parent_id"] as? String
                if let actualID = id{
                    self.parentID = actualID
                    //self.getChildren()
                }
            }
        }
    }
    
    func getCoinGraphData(uid: String) -> (Double, Double){
        var unwrappedTotalCoins: Double = 0
        var unwrappedCurrentCoins: Double = 0
//        ref?.child("running_total").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            if let totalCoins = value?["redeemed_coins"] as? Double {
//                unwrappedTotalCoins = totalCoins
//            }
//            if let currentCoins = value?["coin_total"] as? Double {
//                unwrappedCurrentCoins = currentCoins
//            }
//        })

        for coinAmt in coinTotals{
            if coinAmt.key == uid {
                if let redeemed = coinAmt.redeemedTotal{
                unwrappedTotalCoins = Double(redeemed)
                }
                if let currentCoin = coinAmt.cointotal{
                    unwrappedCurrentCoins = Double(currentCoin)
                }
            }
        }
        return (unwrappedCurrentCoins, unwrappedTotalCoins)
        
    }
    
    func getChoreCompletedData(uid: String)->(Double,Double){
        var completedChores: Double = 0
        var incompleteChores: Double = 0
        
        for chore in chores{
            
//            if let _ = chore.chorePastDue{
//                incompleteChores += 1
//            }
            
            if let cID = chore.childID{
                if cID == uid {
                    
                    if let complete = chore.completed{
                        if complete{
                            completedChores += 1
                        } else {
                            incompleteChores += 1
                        }
                    }
                }
            }
        }
        
        return (completedChores, incompleteChores)
        
    }
    
    func getChorePerWeekData(uid: String){
        
        let calendar = Calendar.current
        var week1: Int = 0
        var week2: Int = 0
        var week3: Int = 0
        var week4: Int = 0
        var week5: Int = 0
        
        
        for chore in chores {
            if let cID = chore.childID {
                if cID == uid {
                    if let completedDate = chore.choreCompletedDate{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        dateFormatter.dateStyle = .medium
                        let choreDate = dateFormatter.date(from: completedDate)
                        let month = calendar.component(.month, from: choreDate!)
                        let day = calendar.component(.day, from: choreDate!)
                        
                        let currentDate = Date()
                        let currentMonth = calendar.component(.month, from: currentDate)
                        dateFormatter.dateFormat = "LLLL"
                        self.monthName = dateFormatter.string(from: currentDate)
                        if  currentMonth == month{
                            switch day{
                            case 1...7:
                                week1 += 1
                            case 8...14:
                                week2 += 1
                            case 15...21:
                                week3 += 1
                            case 22...28:
                                week4 += 1
                            default:
                                week5 += 1
                            }
                        }
                    }
                }
            }
        }
        self.childrenWeeklyChores.append([Double(week1),Double(week2),Double(week3),Double(week4),Double(week5)])
        
        
        
        
    }
    
    // gets all children with same parent id as user
    func getChildren() {
        children.removeAll()
        
        Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictUsers = dictRoot["user"] as? [String:AnyObject] ?? [:]
            
            for key in Array(dictUsers.keys) {
                self.children.append(ChildUser(dictionary: (dictUsers[key] as? [String:AnyObject])!, key: key))
                self.children = self.children.filter({$0.parentid == self.parentID})
                self.children = self.children.filter({$0.userparent == false})
                if !self.isActiveUserParent {
                    self.children = self.children.filter({$0.key == self.userID!})
                }
            }
            
            self.overviewTableView.reloadData()
        }
    }
    
    
    
    func displayHeaderName(){
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("user").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if let name = value?["user_name"] as? String{
                    self.usernameLabel.text = name
                }
            }
        }
    }
    
    func isUserParent(){
        
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Bool {
                self.isActiveUserParent = val
                
                if self.isActiveUserParent {
                    self.getRunningTotalParent()
                } else {
                    self.getRunningTotal()
                    self.getCoinTotals()
                }
            }
        }
    }
    
    func getRunningTotal(){
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            databaseRef.child("running_total").child(uid).child("coin_total").observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                self.coinValue = snapshot.value as? Int ?? 0
                self.coinAmtLabel.text = "\(self.coinValue)"
            }
        }
        
    }
    
    func getRunningTotalParent(){
        //getChildren()
        getCoinTotals()
    }
    
    func getCoinTotals() {
        coinTotals.removeAll()
        
        self.getChildren()
        
        _ = Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            let dictRoot = snapshot.value as? [String:AnyObject] ?? [:]
            let dictRunningTotal = dictRoot["running_total"] as? [String:AnyObject] ?? [:]
            
            for key in Array(dictRunningTotal.keys) {
                for child in self.children {
                    if key == child.userid {
                        self.coinTotals.append(RunningTotal(dictionary: (dictRunningTotal[key] as? [String:AnyObject])!, key: key))
                    }
                }
            }
            
            var sumTotal = 0
            
            for coinTotal in self.coinTotals {
                for child in self.children {
                    if coinTotal.key == child.userid {
                        if let total = coinTotal.cointotal {
                            sumTotal += total
                        }
                    }
                }
            }
            
            self.coinAmtLabel.text = String(sumTotal)
            self.overviewTableView.reloadData()
        }
    }
    
    func getConversionRate(){
        if let unwrappedParentID = parentID{
            
            ref?.child("app_settings").child(unwrappedParentID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                if let conversionValue = value?["coin_dollar_value"] as? Double{
                    
                    self.coinConversion = conversionValue
                }
                
            })
        }
        
    }
    
    func checkRedeem(children: [ChildUser]) {
        self.redDot.isHidden = true
        for child in children {
            if let childuid = child.userid {
                Database.database().reference().child("user/\(childuid)/isRedeem").observeSingleEvent(of: .value) { (snapshot) in
                    if let isRedeem = snapshot.value as? Bool {
                        if isRedeem && self.isActiveUserParent {
                            self.redDot.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    func updateCoinsChartData(index: Int) -> PieChartData {
        
        let uid = children[index].key
        let coinData = getCoinGraphData(uid: uid)
        childrenCoinsTotal.value = coinData.0
        childrenCoinsAllTimeTotal.value = coinData.1
        
        let chartDataSet = PieChartDataSet(values: [childrenCoinsTotal, childrenCoinsAllTimeTotal], label: "Current/Redeemed")
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor(named: "CFCBlue"), UIColor(named: "CFCDarkBlue")]
        chartDataSet.colors = colors as! [NSUIColor]
        chartDataSet.selectionShift = 0
        
        return chartData
    }
    
    func updateChoresChartData(index: Int) -> PieChartData {
        let uid = children[index].key
        let choreData = getChoreCompletedData(uid: uid)
        
        childrenCompletedChores.value = choreData.0
        childrenToDoChores.value = choreData.1
        
        let chartDataSet = PieChartDataSet(values: [childrenCompletedChores, childrenToDoChores], label: "Completed/Incomplete")
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor(named: "CFCOrange"), UIColor(named: "CFCDarkOrange")]
        chartDataSet.colors = colors as! [NSUIColor]
        chartDataSet.selectionShift = 0
        
        return chartData
    }
    
    func updateWeeklyChart(index: Int, values: [Double]) -> LineChartData {
        var lineChartEntry = [ChartDataEntry] ()
        let xVal: [String] = ["Week 1","Week 2","Week 3","Week 4","Week 5"]
        for i in 0..<values.count {
            
            let value = ChartDataEntry(x: Double(i + 1), y: values[i], data: xVal[i] as AnyObject)
            
            lineChartEntry.append(value)
        }
        
        
        
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Chores Completed for \(monthName)")
        let data = LineChartData()
        data.addDataSet(line1)
        
        
        return data
    }
    
    
    // MARK: TableView setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! OverviewTableViewCell
        
        if children.count > 0 {
            cell.usernameCellHeader.text = children[indexPath.row].username
            
            // set up coins piechart
            cell.coinsPieChart.chartDescription?.text = ""
            cell.coinsPieChart.centerText = "Coins"
            cell.coinsPieChart.data = updateCoinsChartData(index: indexPath.row)
            
            // set up chores piechart
            cell.choresPieChart.chartDescription?.text = ""
            cell.choresPieChart.centerText = "Chores"
            cell.choresPieChart.data = updateChoresChartData(index: indexPath.row)
            
            // set up weekly chore line chart
            cell.weeklyChart.chartDescription?.text = ""
            getChorePerWeekData(uid: children[indexPath.row].key)
            cell.weeklyChart.data = updateWeeklyChart(index: indexPath.row, values: childrenWeeklyChores[indexPath.row])
    
        }
        cell.backgroundColor = UIColor(white: 1, alpha: 0.7)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            return 800.0
        }
        
        return 432.0
    }
    
    
    // MARK: Actions
    
    @IBAction func toCoinView(_ sender: UIButton) {
        // checks if user is parent. If yes, go to parent coin view, else show redeem view
        Database.database().reference().child("user/\(userID!)/user_parent").observeSingleEvent(of: .value, with: { (snapshot) in
            if let isParent = snapshot.value as? Bool {
                if isParent {
                    self.performSegue(withIdentifier: "toCoinFromOverview", sender: nil)
                } else {
                    self.childRedeemView.isHidden = false
                }
            }
        })
    }
    
    @IBAction func childRedeem(_ sender: UIButton) {
        if coinValue <= 0 {
            AlertController.showAlert(self, title: "Cannot Redeem", message: "YOu do not have any coins to redeem. Try completing some chores to get some coins")
        } else {
            getConversionRate()
            let convertedValue = coinConversion * Double(coinValue)
            let dollarValueString = String(format: "$%.02f", convertedValue)
            
            let alert = UIAlertController(title: "Coin Redemption Requested", message: "You are currently requesting to have your coins redeemed. At the current rate you will receive \(dollarValueString) for the coins you have acquired.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                if let uid = self.userID {
                    self.ref?.child("user/\(uid)/isRedeem").setValue(true)
                    
                    self.childRedeemView.isHidden = true
                    
                    if let animRedeemView = self.animRedeemView {
                        AnimationHelper.startAnimation(vc: self, animView: animRedeemView, anim: 0)
                    }
                    
                    // AlertController.showAlert(self, title: "Redeemed", message: "Your coin redeem has been requested. We'll let your parent know!")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.childRedeemView.isHidden = true
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
        }
    }
}
