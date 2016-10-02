import UIKit

class InnerTableView: UITableView {
    weak var itvDelegate: InnerTableViewDelegate!
    weak var outerCell: TableViewCellWithTableView!
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.insertRows(at: indexPaths, with: animation)
        outerCell.didInsertRows(at: indexPaths)
    }
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        super.deleteRows(at: indexPaths, with: animation)
        outerCell.didDeleteRows(at: indexPaths)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        isScrollEnabled = false
    }
    
    override func reloadData() {
        super.reloadData()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var tableHeaderView: UIView? {
        didSet {
            itvDelegate.heightWasChanged()
        }
    }
    override var tableFooterView: UIView? {
        didSet {
            itvDelegate.heightWasChanged()
        }
    }
}

protocol InnerTableViewDelegate: class {
    func heightWasChanged()
}
