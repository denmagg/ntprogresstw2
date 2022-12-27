import UIKit

enum SortStatus {
    case ascending
    case descending
    case none
}

protocol HeaderCellDelegate: AnyObject {
  func sortData(by parameter: ModelSortingParameter, isAscending: Bool)
}

final class HeaderCell: UITableViewHeaderFooterView {
  static let reuseIidentifier = "HeaderCell"
  
  @IBOutlet private var buttunsArray: [UIButton]!
  
  weak var delegate: HeaderCellDelegate?
  private var sortStatusArray: [SortStatus] = [.ascending, .none, .none, .none, .none]
  
  @IBAction private func sortButtonPressed(_ sender: UIButton) {
    for button in buttunsArray {
      button.setImage(UIImage(systemName: "arrow.up.and.down"), for: .normal)
    }
    
    guard let parameter = ModelSortingParameter(rawValue: sender.tag) else { return }
    
    switch sortStatusArray[sender.tag] {
    case .ascending:
      sortStatusArray = [.none, .none, .none, .none, .none]
      sortStatusArray[sender.tag] = .descending
      buttunsArray[sender.tag].setImage(UIImage(systemName: "arrow.down"), for: .normal)
      delegate?.sortData(by: parameter, isAscending: false)
    case .descending:
      sortStatusArray = [.none, .none, .none, .none, .none]
      sortStatusArray[sender.tag] = .ascending
      buttunsArray[sender.tag].setImage(UIImage(systemName: "arrow.up"), for: .normal)
      delegate?.sortData(by: parameter, isAscending: true)
    case .none:
      sortStatusArray = [.none, .none, .none, .none, .none]
      sortStatusArray[sender.tag] = .ascending
      buttunsArray[sender.tag].setImage(UIImage(systemName: "arrow.up"), for: .normal)
      delegate?.sortData(by: parameter, isAscending: true)
    }
  }
  
}
