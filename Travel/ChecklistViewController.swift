import UIKit

// 自定義 Cell 類別 (記得在 Storyboard 的 Identity Inspector 綁定這個 Class)
class ChecklistCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var toggleAction: (() -> Void)? // 閉包回調
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        toggleAction?()
    }
}

class ChecklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var items: [PackingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadItems()
    }
    
    // MARK: - Data Persistence
    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "SavedList"),
           let saved = try? JSONDecoder().decode([PackingItem].self, from: data) {
            items = saved
        } else {
            // 預設清單
            items = [
                PackingItem(title: "護照", isChecked: false),
                PackingItem(title: "錢包 (含信用卡)", isChecked: false),
                PackingItem(title: "牙刷/盥洗用具", isChecked: false),
                PackingItem(title: "充電器/轉接頭", isChecked: false)
            ]
        }
    }
    
    func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "SavedList")
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 強制轉型為自定義 Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as? ChecklistCell else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        
        // 設定勾選圖示 (需使用 SF Symbols: square / checkmark.square.fill)
        let iconName = item.isChecked ? "checkmark.square.fill" : "square"
        cell.checkButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        // 處理按鈕點擊
        cell.toggleAction = { [weak self] in
            self?.items[indexPath.row].isChecked.toggle()
            self?.saveItems()
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
    
    // MARK: - Add Item (連線到 Bar Button Item)
    @IBAction func addItemTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "新增物品", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "物品名稱" }
        
        let add = UIAlertAction(title: "新增", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.items.append(PackingItem(title: text, isChecked: false))
                self.saveItems()
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(add)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}
