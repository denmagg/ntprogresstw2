import UIKit

final class DealCell: UITableViewCell {
  static let reuseIidentifier = "DealCell"
  
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var instrumentNameLabel: UILabel!
  @IBOutlet private weak var priceLabel: UILabel!
  @IBOutlet private weak var amountLabel: UILabel!
  @IBOutlet private weak var sideLabel: UILabel!
  
  func configure(with model: Deal) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss' 'dd.MM.yyyy"
    
    dateLabel.text = formatter.string(from: model.dateModifier)
    instrumentNameLabel.text = model.instrumentName
    priceLabel.text = String(round(model.price * 100) / 100)
    amountLabel.text = String(Int(round(model.amount)))
    switch model.side {
    case .buy:
      sideLabel.text = "Buy"
      sideLabel.textColor = .red
    case .sell:
      sideLabel.text = "Sell"
      sideLabel.textColor = .green
    }
  }
  
}
