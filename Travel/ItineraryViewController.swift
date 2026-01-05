import UIKit


// 轉換時間
func getTime(from string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // 設定格式
    return formatter.date(from: string) ?? Date() // 轉換失敗就回傳現在時間
}

class ItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var events: [TripEvent] = [
        TripEvent(date: getTime(from: "09:00"), title: "成田機場落地", location: "Terminal 2"),
        TripEvent(date: getTime(from: "11:30"), title: "飯店寄放行李", location: "上野站前 APA"),
        TripEvent(date: getTime(from: "13:00"), title: "淺草寺參拜", location: "淺草")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        let event = events[indexPath.row]
        
        cell.textLabel?.text = "\(event.date) - \(event.title)"
        cell.detailTextLabel?.text = "📍 \(event.location)"
            
            // 日期格式化
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            
            // Date轉成String
            let timeString = formatter.string(from: event.date)
            
            cell.textLabel?.text = "\(timeString) - \(event.title)"
            
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //取消選取的狀態
        
        let event = events[indexPath.row]
        let address = event.location
        
        // 建立選單
        let sheet = UIAlertController(title: "導航至 \(event.title)", message: address, preferredStyle: .actionSheet)
        
        // Google Maps
        let googleAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
            if let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "comgooglemaps://?q=\(query)") {
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    // Google Maps網頁版
                    let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)")!
                    UIApplication.shared.open(webURL)
                }
            }
        }
        
        // Apple Maps
        let appleAction = UIAlertAction(title: "Apple Maps", style: .default) { _ in
            if let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "http://maps.apple.com/?q=\(query)") {
                UIApplication.shared.open(url)
            }
        }
        
        sheet.addAction(googleAction)
        sheet.addAction(appleAction)
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(sheet, animated: true)
        
            let alert = UIAlertController(title: "編輯行程", message: "修改標題", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = event.title
            }
            
            let saveAction = UIAlertAction(title: "儲存", style: .default) { _ in
                if let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty {
                    self.events[indexPath.row].title = newTitle
                    self.tableView.reloadData()
                }
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addEventTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "新增行程", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 0, y: 30, width: alert.view.bounds.width - 20, height: 150)
        alert.view.addSubview(datePicker)
        
        showCustomInputAlert()
    }

    func showCustomInputAlert() {
        let alert = UIAlertController(title: "新增行程", message: nil, preferredStyle: .alert)
        
        // 輸入標題
        alert.addTextField { tf in tf.placeholder = "活動名稱 (例如: 淺草寺)" }
        
        // 輸入地點
        alert.addTextField { tf in tf.placeholder = "地址 (例如: 東京雷門)" }
        
        // 輸入時間
        alert.addTextField { tf in
            tf.placeholder = "點擊選擇時間"
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .dateAndTime
            datePicker.preferredDatePickerStyle = .wheels
            tf.inputView = datePicker
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(self.dateDonePressed))
            toolbar.setItems([doneButton], animated: true)
            tf.inputAccessoryView = toolbar
            
            // 暫存
            datePicker.tag = 101
            datePicker.addTarget(self, action: #selector(self.dateChanged(sender:)), for: .valueChanged)
        }
        
        let addAction = UIAlertAction(title: "加入", style: .default) { _ in
            guard let title = alert.textFields?[0].text,
                  let location = alert.textFields?[1].text,
                  let dateStr = alert.textFields?[2].text else { return }
            
            // 將String轉回Date
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            let date = formatter.date(from: dateStr) ?? Date()
            
            self.events.append(TripEvent(date: date, title: title, location: location))
            self.events.sort { $0.date < $1.date } // 依時間排序
            self.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    @objc func dateChanged(sender: UIDatePicker) {
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?[2] {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            textField.text = formatter.string(from: sender.date)
        }
    }

    @objc func dateDonePressed() {
        view.endEditing(true)
    }
}
