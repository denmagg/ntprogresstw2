import UIKit

enum ModelSortingParameter: Int {
  case date
  case instrument
  case price
  case amount
  case side
}

final class ViewController: UIViewController {
  
  //MARK: Properties
  @IBOutlet private weak var tableView: UITableView!
  
  private let server = Server()
  private var model: [Deal] = []
  private var currentModel: [Deal] = []
  
  private var firstPacketLoading = true
  private var isAscending = true
  private var currentSortParameter: ModelSortingParameter = .date
  
  private var vSpinner: UIView?
  
  
  //MARK: LC
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    
    server.subscribeToDeals { [weak self] deals in
      guard let self = self else { return }
      self.model.append(contentsOf: deals)
      if self.firstPacketLoading {
        self.currentModel = self.model
        self.sortCurrentModel {
          self.tableView.reloadData()
        }
        self.removeSpinner()
        self.firstPacketLoading = false
      }
    }
  }
  
  //MARK: LC helpers
  private func setup() {
    navigationItem.title = "Deals"
    
    showSpinner(onView: view)
    
    tableView.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil), forCellReuseIdentifier: DealCell.reuseIidentifier)
    tableView.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  //MARK: Methods
  
  private func sortCurrentModel(completion: @escaping () -> ()) {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      switch self.currentSortParameter {
      case .date:
        self.isAscending ? (self.currentModel = self.currentModel.sorted { $0.dateModifier < $1.dateModifier}) : (self.currentModel = self.currentModel.sorted { $0.dateModifier > $1.dateModifier})
      case .instrument:
        self.isAscending ? (self.currentModel = self.currentModel.sorted { $0.instrumentName < $1.instrumentName}) : (self.currentModel = self.currentModel.sorted { $0.instrumentName > $1.instrumentName})
      case .price:
        self.isAscending ? (self.currentModel = self.currentModel.sorted { $0.price < $1.price}) : (self.currentModel = self.currentModel.sorted { $0.price > $1.price})
      case .amount:
        self.isAscending ? (self.currentModel = self.currentModel.sorted { $0.amount < $1.amount}) : (self.currentModel = self.currentModel.sorted { $0.amount > $1.amount})
      case .side:
        self.isAscending ? (self.currentModel = self.currentModel.sorted { $0.side < $1.side}) : (self.currentModel = self.currentModel.sorted { $0.side > $1.side})
      }
      DispatchQueue.main.async {
        completion()
      }
    }
  }
  
  @objc func refresh(sender: UIRefreshControl) {
      if self.currentModel.count != self.model.count {
        self.currentModel = self.model
      }
    sortCurrentModel { [weak self] in
      sender.endRefreshing()
      self?.tableView.reloadData()
    }
  }
  
}


//MARK: TableView DataSource/Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentModel.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.reuseIidentifier, for: indexPath) as? DealCell else { return  UITableViewCell() }
    cell.configure(with: currentModel[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderCell.reuseIidentifier) as? HeaderCell else { return UITableViewCell() }
    cell.delegate = self
    return cell
  }
}


extension ViewController: HeaderCellDelegate {
  func sortData(by parameter: ModelSortingParameter, isAscending: Bool) {
    currentSortParameter = parameter
    self.isAscending = isAscending
    showSpinner(onView: self.view)
    sortCurrentModel { [weak self] in
      self?.tableView.reloadData()
      self?.removeSpinner()
    }
  }
}


private extension ViewController {
  func showSpinner(onView : UIView) {
    let spinnerView = UIView.init(frame: onView.bounds)
    spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    let ai = UIActivityIndicatorView.init(style: .large)
    ai.color = .white
    ai.startAnimating()
    ai.center = spinnerView.center
    
    DispatchQueue.main.async {
      spinnerView.addSubview(ai)
      onView.addSubview(spinnerView)
    }
    
    vSpinner = spinnerView
  }
  
  func removeSpinner() {
    DispatchQueue.main.async { [weak self] in
      self?.vSpinner?.removeFromSuperview()
      self?.vSpinner = nil
    }
  }
}

