import UIKit

class PackingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var items: [PackingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定 TableView
        tableView.dataSource = self
        
        // 載入儲存的資料
        loadItems()
    }

    // MARK: - 資料儲存與讀取 (Data Persistence)
    
    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "SavedList"),
           let saved = try? JSONDecoder().decode([PackingItem].self, from: data) {
            items = saved
        } else {
            // 如果第一次打開沒資料，給預設值
            items = [
                PackingItem(name: "牙刷", isDone: false, isChecked: false, isDisabled: false),
                PackingItem(name: "護照",isDone: false, isChecked: false, isDisabled: false),
                PackingItem(name: "充電器", isDone: false, isChecked: false, isDisabled: false),
                PackingItem(name: "換洗衣物", isDone: false, isChecked: false, isDisabled: false)
            ]
        }
    }
    
    func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "SavedList")
        }
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            
            // 轉型成 PackingListCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PackingCell", for: indexPath) as? PackingListCell else {
                return UITableViewCell()
            }
            
            let item = items[indexPath.row]
            
            // 呼叫 Cell 裡的 configure 方法來更新畫面
            cell.configure(name: item.name, isDone: item.isDone)
            
            // 設定按鈕被按下去時要發生的事
            cell.toggleAction = { [weak self] in
                // 1. 切換該項目的 isDone 狀態
                self?.items[indexPath.row].isDone.toggle()
                
                // 2. 重新整理這一行
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        
        return cell
    }
    
    // MARK: - 功能: 新增物品 (Add Item)
    
    @IBAction func addItemTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "新增物品", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "輸入物品名稱" }
        
        let addAction = UIAlertAction(title: "新增", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                // 建立新物品
                let newItem = PackingItem(name: text, isDone: false, isChecked: false, isDisabled: false)
                self.items.append(newItem)
                
                // 儲存並更新畫面
                self.saveItems()
                self.tableView.reloadData()
                
                // 自動捲動到最下面
                let indexPath = IndexPath(row: self.items.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - 功能: 左滑刪除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { action, view, completionHandler in
            // 刪除資料
            self.items.remove(at: indexPath.row)
            self.saveItems() // 儲存
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - 功能: 右滑暫時關閉
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.row]
        let title = item.isDisabled ? "啟用" : "暫時關閉"
        
        let disableAction = UIContextualAction(style: .normal, title: title) { action, view, completionHandler in
            // 切換狀態
            self.items[indexPath.row].isDisabled.toggle()
            self.saveItems() // 儲存
            tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        disableAction.backgroundColor = item.isDisabled ? UIColor.systemBlue : UIColor.systemGray
        return UISwipeActionsConfiguration(actions: [disableAction])
    }
    
    // MARK: - 功能: 勾選動作 (Delegate)
    func didToggleCheckbox(on cell: PackingListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // 更新資料
        items[indexPath.row].isChecked.toggle()
        self.saveItems() //儲存
        
        // 更新畫面
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // 點擊整行勾選
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[indexPath.row].isDisabled {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        items[indexPath.row].isChecked.toggle()
        saveItems() //儲存
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
