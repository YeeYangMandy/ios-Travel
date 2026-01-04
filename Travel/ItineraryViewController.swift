import UIKit


// 1. 定義一個輔助函式來轉換時間
func getTime(from string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // 設定格式為 24小時制的小時:分鐘
    // 注意：只設定時間時，日期部分會預設為 2000年1月1日 (這對假資料通常沒差)
    return formatter.date(from: string) ?? Date() // 如果轉換失敗就回傳現在時間
}

class ItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // 2. 你的假資料 (修改呼叫方式)
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
    
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
        let event = events[indexPath.row]
        
        // 需設定 Cell Style 為 Subtitle
        cell.textLabel?.text = "\(event.date) - \(event.title)"
        cell.detailTextLabel?.text = "📍 \(event.location)"
        // --- 這裡開始修改 ---
            
            // 1. 建立日期格式化工具
            let formatter = DateFormatter()
            // 設定你想要的格式，例如 "HH:mm" (只有時間) 或 "MM/dd HH:mm" (日期加時間)
            formatter.dateFormat = "MM/dd HH:mm"
            
            // 2. 將 Date 轉成漂亮的 String
            let timeString = formatter.string(from: event.date)
            
            // 3. 顯示在 Cell 上
            cell.textLabel?.text = "\(timeString) - \(event.title)"
            
            // --- 修改結束 ---
        return cell
    }
    // 支援編輯模式（包含刪除）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 步驟 A: 先從資料源陣列中移除資料
            events.remove(at: indexPath.row)
            
            // 步驟 B: 再從畫面上移除那一列 (動畫效果)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // (選用) 如果你有儲存功能（如 UserDefaults），記得這裡也要呼叫儲存
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 取消選取狀態
        
        let event = events[indexPath.row]
        let address = event.location
        
        // 建立選單讓使用者選地圖
        let sheet = UIAlertController(title: "導航至 \(event.title)", message: address, preferredStyle: .actionSheet)
        
        // 1. Google Maps
        let googleAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
            // 必須對地址進行 URL 編碼 (例如把空格變 %20)
            if let query = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "comgooglemaps://?q=\(query)") {
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    // 如果沒裝 App，改開網頁版
                    let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)")!
                    UIApplication.shared.open(webURL)
                }
            }
        }
        
        // 2. Apple Maps (iOS 內建)
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
        
        // 2. 建立一個彈出視窗
            let alert = UIAlertController(title: "編輯行程", message: "修改標題", preferredStyle: .alert)
            
            // 3. 加入輸入框，並填入原本的標題
            alert.addTextField { textField in
                textField.text = event.title
            }
            
            // 4. 加入「確定」按鈕
            let saveAction = UIAlertAction(title: "儲存", style: .default) { _ in
                // 取得輸入框的新文字
                if let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty {
                    // 修改資料源
                    self.events[indexPath.row].title = newTitle
                    
                    // 重新整理表格顯示
                    self.tableView.reloadData()
                }
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            // 5. 顯示視窗
            present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Add Action (連線到 Bar Button Item)
    @IBAction func addEventTapped(_ sender: UIBarButtonItem) {
        // 建立一個 View 來放 DatePicker (因為 UIAlertController 預設只能放文字框)
        let alert = UIAlertController(title: "新增行程", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        // message 放很多換行是為了撐開空間給 DatePicker
        
        // 1. 建立 DatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels // 滾輪風格比較適合嵌入
        datePicker.frame = CGRect(x: 0, y: 30, width: alert.view.bounds.width - 20, height: 150)
        alert.view.addSubview(datePicker)
        
        // 2. 建立文字輸入框 (這裡比較 trick，因為 ActionSheet 不能直接加 TextField，我們改用 Alert 樣式)
        // 為了簡單起見，我們改用 "Alert" Style，但 DatePicker 的處理方式不同
        // 下面提供一個 "InputView" 的最佳實作法：
        
        showCustomInputAlert()
    }

    // 這是更專業的做法：使用 TextField 的 inputView 替換成 DatePicker
    func showCustomInputAlert() {
        let alert = UIAlertController(title: "新增行程", message: nil, preferredStyle: .alert)
        
        // 標題輸入
        alert.addTextField { tf in tf.placeholder = "活動名稱 (例如: 淺草寺)" }
        
        // 地點輸入
        alert.addTextField { tf in tf.placeholder = "地址 (例如: 東京雷門)" }
        
        // 時間輸入 (將鍵盤變成 DatePicker)
        alert.addTextField { tf in
            tf.placeholder = "點擊選擇時間"
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .dateAndTime
            datePicker.preferredDatePickerStyle = .wheels
            tf.inputView = datePicker // 關鍵！點擊時跳出 DatePicker 而不是鍵盤
            
            // 增加一個 Toolbar 讓使用者按 "完成"
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(self.dateDonePressed))
            toolbar.setItems([doneButton], animated: true)
            tf.inputAccessoryView = toolbar
            
            // 暫存 DatePicker 給後面用 (透過 tag 或是全域變數，這裡簡化處理)
            datePicker.tag = 101
            // 實際開發建議把 datePicker 宣告為類別屬性
            datePicker.addTarget(self, action: #selector(self.dateChanged(sender:)), for: .valueChanged)
        }
        
        let addAction = UIAlertAction(title: "加入", style: .default) { _ in
            guard let title = alert.textFields?[0].text,
                  let location = alert.textFields?[1].text,
                  let dateStr = alert.textFields?[2].text else { return }
            
            // 這裡需要將字串轉回 Date，或是直接存字串
            // 為求簡單，我們假設使用者已經選好了
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            let date = formatter.date(from: dateStr) ?? Date()
            
            self.events.append(TripEvent(date: date, title: title, location: location))
            self.events.sort { $0.date < $1.date } // 依時間自動排序
            self.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    // 輔助函式：當 DatePicker 滾動時，更新 TextField 文字
    @objc func dateChanged(sender: UIDatePicker) {
        // 找到那個時間輸入框 (這需要一點技巧，通常建議把 alert 變成全域變數或用 tag)
        // 這裡示範簡單邏輯：
        if let alert = presentedViewController as? UIAlertController,
           let textField = alert.textFields?[2] {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            textField.text = formatter.string(from: sender.date)
        }
    }

    @objc func dateDonePressed() {
        view.endEditing(true) // 收起 DatePicker
    }
}
