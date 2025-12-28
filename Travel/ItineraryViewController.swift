import UIKit

class ItineraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // 假資料
    var events: [TripEvent] = [
        TripEvent(time: "09:00", title: "成田機場落地", location: "Terminal 2"),
        TripEvent(time: "11:30", title: "飯店寄放行李", location: "上野站前 APA"),
        TripEvent(time: "13:00", title: "淺草寺參拜", location: "淺草")
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
        cell.textLabel?.text = "\(event.time) - \(event.title)"
        cell.detailTextLabel?.text = "📍 \(event.location)"
        return cell
    }
    
    // MARK: - Add Action (連線到 Bar Button Item)
    @IBAction func addEventTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "新增行程", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "時間 (09:00)" }
        alert.addTextField { $0.placeholder = "活動名稱" }
        alert.addTextField { $0.placeholder = "地點" }
        
        let addAction = UIAlertAction(title: "加入", style: .default) { _ in
            guard let time = alert.textFields?[0].text,
                  let title = alert.textFields?[1].text,
                  let loc = alert.textFields?[2].text else { return }
            
            // 如果是做共同行程，這段要改成寫入 Firebase
            self.events.append(TripEvent(time: time, title: title, location: loc))
            self.events.sort { $0.time < $1.time } // 簡單排序
            self.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}
