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
import ViewAnimator

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var eventTableView: UITableView!
    
    var now = Date()
    var selectDate = Date()
    var selectDateText = ""
    let formatter: DateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var allEvents = [QueryDocumentSnapshot]()
    var selectDateEvents = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 讓app一啟動就是今天的日曆
        calendarView.scrollToDate(now, animateScroll: false)
        // 讓今天被選取
        calendarView.selectDates([now])
        
        //  設定日曆屬性（水平/垂直滑）、滑動方式
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
        
        selectDateText = formatter.string(from: now)
        dateLabel.text = selectDateText
        
        timeFormatter.dateFormat = "a hh:mm"
        timeFormatter.locale = Locale(identifier: "zh_TW")
        timeFormatter.timeZone = TimeZone(identifier: "zh_TW")
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addEventVC = segue.destination as! AddEventViewController
        addEventVC.selectDateText = selectDateText
        addEventVC.selectDate = selectDate
    }
    @IBAction func unwindSegueBack(segue: UIStoryboardSegue){
    }
    //  tableview顯示特效
    func animateTableView(){
        let animations = [AnimationType.from(direction: .left, offset: 10.0)]
        UIView.animate(views: eventTableView.visibleCells, animations: animations, reversed: false, initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, animationInterval: 1, duration: ViewAnimatorConfig.duration, completion: nil)
        eventTableView.reloadData()
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        //  設定dateFormatter格式
        /*
         這邊比viewdidload先執行，所以可以在這邊設定dateFormatter格式
         */
        formatter.dateFormat = "yyyy年M月dd日"
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
        
        //  判斷是不是點第二次，如果是點兩次的話跳出細項
        let cell = cell as! DateCell
        if cell.selectedView.isHidden == false{
            performSegue(withIdentifier: "addEventSegue", sender: self)
        }
        selectDate = date
        configureCell(view: cell, cellState: cellState)
        selectDateText = formatter.string(from: date)
        //  讓標籤改成選取到的日期
        dateLabel.text = selectDateText
        
        self.selectDateEvents = [QueryDocumentSnapshot]()
        let db = Firestore.firestore()
        db.collection("events").document(selectDateText).collection("dateEvents").order(by: "startDate", descending: false).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                if self.selectDateText == self.formatter.string(from: date){
                    self.selectDateEvents = querySnapshot.documents
                    self.animateTableView()
                }
            }
        }
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
            cell.dateLabel.textColor = .lightGray
        }
    }
    //  按日期讓日期上有粉色的圓圈
    func handleCellSelected(cell: DateCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    //  日期裡有事件的話，在日期下方標示
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        let everyCellDayDate = formatter.string(from: cellState.date)
        let db = Firestore.firestore()
        db.collection("events").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot{
                var dateDic = [String : String]()
                for event in querySnapshot.documents{
                    if let eventDate = event.data()["date"] as? String{
                        dateDic[eventDate] = "yes"
                    }
                }
                if dateDic[everyCellDayDate] == nil {
                    cell.dotView.isHidden = true
                }
                else{
                    cell.dotView.isHidden = false
                }
            }
        }
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectDateEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        let startTimestamp = selectDateEvents[indexPath.row].data()["startDate"] as! Timestamp
        let startDate = startTimestamp.dateValue()
        cell.startTimeLabel.text = timeFormatter.string(from: startDate)
        let endTimeTimestamp = selectDateEvents[indexPath.row].data()["endDate"] as! Timestamp
        let endDate = endTimeTimestamp.dateValue()
        cell.endTimeLabel.text = timeFormatter.string(from: endDate)
        cell.eventTitleLabel.text = selectDateEvents[indexPath.row].data()["title"] as? String
        return cell
    }
    
    //  在 tableView 上往左滑可以刪除
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //    }
}

