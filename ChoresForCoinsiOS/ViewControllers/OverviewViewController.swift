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
    
    
    // MARK: Properties
    
    var userID: String?
    var parentID: String?
    var children = [ChildUser] ()
    var childrenCoinsTotal = [PieChartDataEntry] ()
    var childrenCoinsAllTimeTotal = [PieChartDataEntry] ()
    var childrenCompletedChores = [PieChartDataEntry] ()
    var childrenToDoChores = [PieChartDataEntry] ()
    var childrenWeeklyChores = [[Double]] ()
    let weeks = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8"]
    
    
    // MARK: ViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view.
        
        // get userid
        if let uid = Auth.auth().currentUser?.uid {
            userID = uid
        }
        
        getBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getParentId()
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
                        self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
                    case 1:
                        self.bgImage.image = #imageLiteral(resourceName: "orangeBG")
                    case 2:
                        self.bgImage.image = #imageLiteral(resourceName: "greenBG")
                    case 3:
                        self.bgImage.image = #imageLiteral(resourceName: "redBG")
                    case 4:
                        self.bgImage.image = #imageLiteral(resourceName: "purpleBG")
                    default:
                        self.bgImage.image = #imageLiteral(resourceName: "whiteBG")
                    }
                }
            }
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
                    self.getChildren()
                }
            }
        }
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
            }
            
            self.overviewTableView.reloadData()
            
            // set data for coins and chores piechart and week chart
            for _ in self.children {
                let currentCoins = PieChartDataEntry(value: 10)
                let totalCoins = PieChartDataEntry(value: 25)
                let completedChores = PieChartDataEntry(value: 5)
                let toDoChores = PieChartDataEntry(value: 7)
                
                self.childrenCoinsTotal.append(currentCoins)
                self.childrenCoinsAllTimeTotal.append(totalCoins)
                self.childrenCompletedChores.append(completedChores)
                self.childrenToDoChores.append(toDoChores)
                
                self.childrenWeeklyChores.append([5,8,4,7,5,50,4,6])
                
            }
        }
    }
    
//    struct ChildCoins {
//        var userId: String
//        var currentTotal: Int
//        var totalTotal: Int
//    }
//
//    struct ChildChores {
//        var userId: String
//        var completedChores: Int
//        var toDoChores: Int
//    }
    
    func updateCoinsChartData(index: Int) -> PieChartData {
        let chartDataSet = PieChartDataSet(values: [childrenCoinsTotal[index], childrenCoinsAllTimeTotal[index]], label: "Current/All")
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor(named: "CFCBlue"), UIColor(named: "CFCDarkBlue")]
        chartDataSet.colors = colors as! [NSUIColor]
        chartDataSet.selectionShift = 0
        
        return chartData
    }
    
    func updateChoresChartData(index: Int) -> PieChartData {
        let chartDataSet = PieChartDataSet(values: [childrenCompletedChores[index], childrenToDoChores[index]], label: "Completed/Incomplete")
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor(named: "CFCOrange"), UIColor(named: "CFCDarkOrange")]
        chartDataSet.colors = colors as! [NSUIColor]
        chartDataSet.selectionShift = 0
        
        return chartData
    }
    
    func updateWeeklyChart(index: Int, values: [Double]) -> LineChartData {
        var lineChartEntry = [ChartDataEntry] ()
        
        for i in 0..<values.count {
            let value = ChartDataEntry(x: Double(i + 1), y: values[i])
            
            lineChartEntry.append(value)
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Chores Completed Each Week")
        
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
            cell.weeklyChart.data = updateWeeklyChart(index: indexPath.row, values: childrenWeeklyChores[indexPath.row])
        }
        
        return cell
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            return 600.0
        }
        
        return 432.0
    }
    
    
    // MARK: Actions
}
