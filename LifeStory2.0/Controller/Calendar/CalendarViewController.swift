//
//  ViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/23.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Firebase
import FirebaseAuth
import ViewAnimator

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var eventTableView: UITableView!
    
    var selectDate = Date()
    var selectDateText: String?
    let formatter: DateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var dateDic = [String : String]()
    
    var allEvents = [QueryDocumentSnapshot]()
    var allUserEvents = [QueryDocumentSnapshot]()
    var allCoEditEvents = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDotView()
        
        // 讓app一啟動就是今天的日曆
        calendarView.scrollToDate(Date(), animateScroll: false)
        // 讓今天被選取
        calendarView.selectDates([Date()])
        
        //  設定日曆屬性（水平/垂直滑）、滑動方式
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        
        selectDateText = formatter.string(from: Date())
        if let selectDateText = selectDateText{
            dateLabel.text = selectDateText
        }
        
        timeFormatter.dateFormat = "a hh:mm"
        timeFormatter.locale = Locale(identifier: "zh_TW")
        timeFormatter.timeZone = TimeZone(identifier: "zh_TW")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addEventVC = segue.destination as! AddEventViewController
        if let selectDateText = selectDateText{
            addEventVC.selectDateText = selectDateText
        }
    }
    //  tableview顯示特效
    func animateTableView(){
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        eventTableView.reloadData()
        UIView.animate(views: eventTableView.visibleCells, animations: animations, completion: nil)
    }
    
    func getDotView(){
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let coEditID = userData["coEditID"] as? String,
                        let coEditStatus = userData["coEditStatus"] as? String,
                        coEditStatus == "共同編輯中"{
                        
                        db.collection("LifeStory").document(userID).collection("calendar").addSnapshotListener { (user, error) in
                            
                            if let user = user{
                                if user.documents.isEmpty == false{
                                    let documentChange = user.documentChanges[0]
                                    if documentChange.type == .added {
                                        for event in user.documents{
                                            if let eventDate = event.data()["date"] as? String{
                                                self.dateDic[eventDate] = "yes"
                                                self.calendarView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        db.collection("LifeStory").document(coEditID).collection("calendar").addSnapshotListener { (coEdit, error) in
                            
                            if let coEdit = coEdit{
                                if coEdit.documents.isEmpty == false{
                                    let documentChange = coEdit.documentChanges[0]
                                    if documentChange.type == .added {
                                        for event in coEdit.documents{
                                            if let eventDate = event.data()["date"] as? String{
                                                self.dateDic[eventDate] = "yes"
                                                self.calendarView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        db.collection("LifeStory").document(userID).collection("calendar").addSnapshotListener { (userEvent, error) in
                            if let userEvent = userEvent{
                                if userEvent.documents.isEmpty == false{
                                    let documentChange = userEvent.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.dateDic.removeAll()
                                        for event in userEvent.documents{
                                            if let eventDate = event.data()["date"] as? String{
                                                self.dateDic[eventDate] = "yes"
                                                self.calendarView.reloadData()
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getEvents(date: String){
        
        allEvents.removeAll()
        eventTableView.reloadData()
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let selectDateText = selectDateText{
            
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let coEditID = userData["coEditID"] as? String,
                        let coEditStatus = userData["coEditStatus"] as? String,
                        coEditStatus == "共同編輯中"{
                        db.collection("LifeStory").document(userID).collection("calendar").document(date).collection("events").addSnapshotListener { (userEvent, error) in
                            print(1)
                           
                            if let userEvent = userEvent{
                                if userEvent.documents.isEmpty{
                                    print(2)
                                    self.allUserEvents.removeAll()
                                    self.allEvents.removeAll()
                                    self.eventTableView.reloadData()
                                    if self.allCoEditEvents.isEmpty == false{
                                        print(3)
                                        for coEditEvent in self.allCoEditEvents{
                                            if let date = coEditEvent.data()["date"] as? String{
                                                self.dateDic[date] = "yes"
                                            }
                                            self.allEvents.append(coEditEvent)
                                            self.eventTableView.reloadData()
                                            self.calendarView.reloadData()
                                        }
                                    }
                                }
                                else{
                                    print(4)
                                    let documentChange = userEvent.documentChanges[0]
                                    if documentChange.type == .added {
                                        print(6)
//                                        self.allCoEditEvents.removeAll()    //  加這行才不會顯示殘留的事件
                                        self.allEvents.removeAll()
                                        self.eventTableView.reloadData()
                                        self.allUserEvents = userEvent.documents
                                        for userEvent in self.allUserEvents{
                                            if let date = userEvent.data()["date"] as? String{
                                                self.dateDic[date] = "yes"
                                            }
                                            self.calendarView.reloadData()
                                            print(5)
                                            print(userEvent.data()["title"] as! String)
                                            self.allEvents.append(userEvent)
                                            self.eventTableView.reloadData()
                                        }
                                        if self.allCoEditEvents.isEmpty{
                                            print(7)
                                            self.allCoEditEvents.removeAll()
                                        }
                                        else{
                                            print(8)
                                            for coEditEvent in self.allCoEditEvents{
                                                if let date = coEditEvent.data()["date"] as? String{
                                                    self.dateDic[date] = "yes"
                                                }
                                                self.calendarView.reloadData()
                                                self.allEvents.append(coEditEvent)
                                                self.eventTableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        db.collection("LifeStory").document(coEditID).collection("calendar").document(date).collection("events").addSnapshotListener { (coEditEvent, error) in
                            
                            print(9)
                            
                            if let coEditEvent = coEditEvent{
                                if coEditEvent.documents.isEmpty{
                                    print(10)
                                    self.allCoEditEvents.removeAll()
                                    self.allEvents.removeAll()
                                    self.eventTableView.reloadData()
                                    if self.allUserEvents.isEmpty == false{
                                        print(11)
                                        for userEvent in self.allUserEvents{
                                            if let date = userEvent.data()["date"] as? String{
                                                self.dateDic[date] = "yes"
                                            }
                                            self.calendarView.reloadData()
                                            self.allEvents.append(userEvent)
                                            self.eventTableView.reloadData()
                                        }
                                    }
                                }
                                else{
                                    print(12)
                                    let documentChange = coEditEvent.documentChanges[0]
                                    if documentChange.type == .added {
                                        print(13)
                                        self.allEvents.removeAll()
                                        self.eventTableView.reloadData()
                                        self.allCoEditEvents = coEditEvent.documents
                                        for coEditEvent in self.allCoEditEvents{
                                            if let date = coEditEvent.data()["date"] as? String{
                                                self.dateDic[date] = "yes"
                                            }
                                            self.calendarView.reloadData()
                                            self.allEvents.append(coEditEvent)
                                            self.eventTableView.reloadData()
                                        }
                                        if self.allUserEvents.isEmpty{
                                            print(14)
                                            self.allUserEvents.removeAll()
                                        }
                                        else{
                                            print(15)
                                            for userEvent in self.allUserEvents{
                                                if let date = userEvent.data()["date"] as? String{
                                                    self.dateDic[date] = "yes"
                                                }
                                                self.calendarView.reloadData()
                                                self.allEvents.append(userEvent)
                                                self.eventTableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else{
                        db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).collection("events").order(by: "startDate", descending: false).addSnapshotListener { (events, error) in
                            if let events = events {
                                if events.documents.isEmpty{
                                    self.allEvents.removeAll()
                                    self.eventTableView.reloadData()
                                }
                                else{
                                    let documentChange = events.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allEvents = events.documents
                                        self.eventTableView.reloadData()
                                        for event in self.allEvents{
                                            if let date = event.data()["date"] as? String{
                                                self.dateDic[date] = "yes"
                                            }
                                            self.calendarView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        //  設定dateFormatter格式
        /*
         這邊比viewdidload先執行，所以可以在這邊設定dateFormatter格式
         */
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone(identifier: "zh_TW")
        //  設定日曆起始日期和最終日期
        let startDate = formatter.date(from: "2019年1月01日")!
        let endDate = formatter.date(from: "2030年12月31日")!
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid)
        
    }
    
    /*
     cellForItemAt 和 willDisplay 裡面要放的東西幾乎一樣
     除了 cell 在 cellForItemAt 要做重複利用（dequeueReusableJTAppleCell）
     */
    //  每一格cell要呈現的日期
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    //  滑動日曆的話
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        //  讓 navigation 的 title 顯示現在的年跟月
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        if let slideYearMonth = visibleDates.monthDates.first?.date{
            let yearMonth = formatter.string(from: slideYearMonth)
            dateLabel.text = "\(yearMonth)"
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        //  判斷是不是點第二次，如果是點兩次的話跳出加事件
        let cell = cell as! DateCell
        if cell.selectedView.isHidden == false{
            performSegue(withIdentifier: "addEventSegue", sender: self)
        }
        selectDate = date
        configureCell(view: cell, cellState: cellState)
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone(identifier: "zh_TW")
        selectDateText = formatter.string(from: date)
        //  讓標籤改成選取到的日期
        if let selectDateText = selectDateText{
            dateLabel.text = selectDateText
        }
        
        getEvents(date: formatter.string(from: date))
    }
    
    
    
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell else{return}
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    //  讓不是這個月的日期變灰色
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = .black
            cell.isHidden = false
        } else {
            cell.dateLabel.textColor = UIColor.flatWhiteColorDark()
        }
    }
    //  按日期讓日期上有粉色的圓圈
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.isHidden = false
            cell.dateLabel.textColor = .white
        } else {
            cell.selectedView.isHidden = true
            if cellState.dateBelongsTo == .thisMonth{
                cell.dateLabel.textColor = .black
            }
        }
    }
    //  日期裡有事件的話，在日期下方標示
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        
        let everyCellDayDate = formatter.string(from: cellState.date)
        print(everyCellDayDate)
        print(dateDic)
        if self.dateDic[everyCellDayDate] == nil {
            cell.dotView.isHidden = true
        }
        else{
            cell.dotView.isHidden = false
        }
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        
        let events = allEvents[indexPath.row]
        let startTimestamp = events.data()["startDate"] as! Timestamp
        let startDate = startTimestamp.dateValue()
        cell.startTimeLabel.text = timeFormatter.string(from: startDate)
        let endTimeTimestamp = events.data()["endDate"] as! Timestamp
        let endDate = endTimeTimestamp.dateValue()
        cell.endTimeLabel.text = timeFormatter.string(from: endDate)
        cell.eventTitleLabel.text = events.data()["title"] as? String
        cell.userLabel.text = events.data()["userID"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            let event = allEvents[indexPath.row]
            let db = Firestore.firestore()
            if let userID = Auth.auth().currentUser?.email,
                let selectDateText = selectDateText,
                let documentID = event.data()["documentID"] as? String{
                
                db.collection("LifeStory").document(userID).getDocument { (user, error) in
                    if let userData = user?.data(){
                        if let coEditID = userData["coEditID"] as? String,
                            let coEditStatus = userData["coEditStatus"] as? String,
                            coEditStatus == "共同編輯中"{
                            
                            db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).collection("events").document(documentID).delete()
                            db.collection("LifeStory").document(coEditID).collection("calendar").document(selectDateText).collection("events").document(documentID).delete()
                            
                            self.allEvents.remove(at: indexPath.row)
                            self.eventTableView.reloadData()
                            db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).collection("events").getDocuments { (events, error) in
                                if let events = events{
                                    if events.documents.isEmpty{
                                        db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).delete()
                                        self.dateDic[selectDateText] = nil
                                        self.calendarView.reloadData()
                                    }
                                }
                            }
                            db.collection("LifeStory").document(coEditID).collection("calendar").document(selectDateText).collection("events").getDocuments { (events, error) in
                                if let events = events{
                                    if events.documents.isEmpty{
                                        db.collection("LifeStory").document(coEditID).collection("calendar").document(selectDateText).delete()
                                        self.dateDic[selectDateText] = nil
                                        self.calendarView.reloadData()
                                    }
                                }
                            }
                        }
                        else{
                            db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).collection("events").document(documentID).delete()
                            self.allEvents.remove(at: indexPath.row)
                            self.eventTableView.reloadData()
                            db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).collection("events").addSnapshotListener { (events, error) in
                                if let events = events{
                                    if events.documents.isEmpty{
                                        db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).delete()
                                        self.dateDic[selectDateText] = nil
                                        self.calendarView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

