import UIKit

//MARK: TableViewCelLWithTableView
open class TableViewCellWithTableView: UITableViewCell {
    public var delegate: TableViewCellWithTableViewDelegate? {
        didSet{
            subTableViewDelegateAndDataSource.delegate = delegate
        }
    }
    public var dataSource: TableViewCellWithTableViewDataSource! {
        didSet {
            subTableViewDelegateAndDataSource.dataSource = dataSource
            setViewsAndConstraints()
        }
    }
    
    public var topContentView = UIView() {
        didSet {
            topContentViewHeightConstraint.constant = topContentView.frame.height
        }
    }
    public var topContentViewHeight: CGFloat { return 0 }
    let innerTableView = UITableView()
    
    public var outerIndexPath: IndexPath!
    let subTableViewDelegateAndDataSource = SubTableViewDelegateAndDataSource()
    
    required public init(reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        subTableViewDelegateAndDataSource.outerCell = self
        innerTableView.delegate = subTableViewDelegateAndDataSource
        innerTableView.dataSource = subTableViewDelegateAndDataSource
    }
    
    var innerTableHeightConstraint: NSLayoutConstraint!
    public var topContentViewHeightConstraint: NSLayoutConstraint!
    
    func setViewsAndConstraints() {
        
        innerTableView.translatesAutoresizingMaskIntoConstraints = false
        topContentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(innerTableView)
        contentView.addSubview(topContentView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(topContentView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor))
        constraints.append(topContentView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor))
        constraints.append(topContentView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor))
        constraints.append(innerTableView.topAnchor.constraint(equalTo: topContentView.bottomAnchor))
        constraints.append(innerTableView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor))
        constraints.append(innerTableView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor))
        constraints.append(innerTableView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor))
        
        topContentViewHeightConstraint = topContentView.heightAnchor.constraint(equalToConstant: 1)
        innerTableHeightConstraint = innerTableView.heightAnchor.constraint(equalToConstant: 1)
        
        constraints.append(topContentViewHeightConstraint)
        constraints.append(innerTableHeightConstraint)
        constraints.forEach { constraint in
            constraint.priority = 999
        }
        setHeightConstraint(false)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setHeightConstraint(_ animated: Bool) {
        guard let dataSource = dataSource else { return }
        
        let headerHeight = innerTableView.tableHeaderView?.frame.height ?? 0
        let footerHeight = innerTableView.tableFooterView?.frame.height ?? 0
        let cellHeight = dataSource.heightForInnerCell(for: self)
        var cellCount = 0
        for i in 0..<(dataSource.numberOfSections?(in: self) ?? 1) {
            cellCount += dataSource.cell(self, numberOfRowsInSection: i)
        }
        let totalHeightForCells = CGFloat(cellCount) * cellHeight + headerHeight + footerHeight
        
        innerTableHeightConstraint.constant = totalHeightForCells
        
        let frameResizing: () -> () = {
            let frame = self.innerTableView.frame
            self.innerTableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: totalHeightForCells)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                frameResizing()
            }
        } else {
            frameResizing()
        }
        innerTableView.endUpdates()
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) { fatalError("Use init(outerIndexPath:)") }
    required public init?(coder aDecoder: NSCoder) { fatalError("Use init(outerIndexPath:)") }
}

//MARK: - InnerTableView interceptions
extension TableViewCellWithTableView {
    public func deleteRows(atInner innerIndexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        innerTableView.deleteRows(at: innerIndexPaths, with: animation)
        setHeightConstraint(true)
    }
    public func insertRows(atInner innerIndexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        innerTableView.insertRows(at: innerIndexPaths, with: animation)
        setHeightConstraint(true)
    }
    public var innerTableHeaderView: UIView? {
        get {
            return innerTableView.tableHeaderView
        }
        set {
            innerTableView.tableHeaderView = newValue
            setHeightConstraint(false)
        }
    }
    public var innerTableFooterView: UIView? {
        get {
            return innerTableView.tableFooterView
        }
        set {
            innerTableView.tableFooterView = newValue
            setHeightConstraint(false)
        }
    }
    public func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        innerTableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String, forInner innerIndexPath: IndexPath) -> UITableViewCell {
        return innerTableView.dequeueReusableCell(withIdentifier: identifier, for: innerIndexPath)
    }
    public func deselectRow(at innerIndexPath: IndexPath, animated: Bool) {
        innerTableView.deselectRow(at: innerIndexPath, animated: animated)
    }
    public func innerIndexPath(forInner innerCell: UITableViewCell) -> IndexPath? {
        return innerTableView.indexPath(for: innerCell)
    }
    public func innerCellForRow(atInner innerIndexPath: IndexPath) -> UITableViewCell? {
        return innerTableView.cellForRow(at: innerIndexPath)
    }
    
    var innerTableViewIsUserInteractionEnabled: Bool {
        get { return innerTableView.isUserInteractionEnabled }
        set { innerTableView.isUserInteractionEnabled = newValue }
    }
}


//MARK: TableViewCellWithTableView Delegate and DataSource
@objc public protocol TableViewCellWithTableViewDataSource: class {
    //Required
    func numberOfRows(in section: Int, for outerCell: TableViewCellWithTableView) -> Int
    func innerCellForRow(atInner innerIndexPath: IndexPath, forOuter outerCell: TableViewCellWithTableView) -> UITableViewCell
    
    func reuseIdentifiersForInnerTableView(forOuter outerCell: TableViewCellWithTableView) -> [String]
    func innerCellClassesForInnerTableView(forOuter outerCell: TableViewCellWithTableView) -> [AnyClass]
    func heightForInnerCell(forOuter outerCell: TableViewCellWithTableView) -> CGFloat
    
    //Optional Other
    @objc optional func cell(_ cell: TableViewCellWithTableView, commit editingSyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    @objc optional func cell(_ cell: TableViewCellWithTableView, canEditRowAt indexPath: IndexPath) -> Bool
    @objc optional func numberOfSections(in cell: TableViewCellWithTableView) -> Int
}

@objc public protocol TableViewCellWithTableViewDelegate {
    @objc optional func cell(_ cell: TableViewCellWithTableView, willSelectRowAtInner innerIndexPath: IndexPath) -> IndexPath?
    @objc optional func cell(_ cell: TableViewCellWithTableView, didSelectRowAtInner innerIndexPath: IndexPath)
}



//MARK: SubTableViewDelegateAndDataSource
class SubTableViewDelegateAndDataSource: NSObject {
    weak var outerCell: TableViewCellWithTableView!
    
    var delegate: TableViewCellWithTableViewDelegate?
    var dataSource: TableViewCellWithTableViewDataSource?
}
extension SubTableViewDelegateAndDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (dataSource?.numberOfSections?(in: outerCell) ?? 1)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { fatalError("Requires a data source.") }
        guard outerCell.outerIndexPath != nil else { return 0 }
        let cellClasses = dataSource.cellClassForInnerTableView(for: outerCell)
        let identifiers = dataSource.reuseIdentifierForInnerTableView(for: outerCell)
        for (cellClass,identifier) in zip(cellClasses, identifiers) {
            outerCell.register(cellClass, forCellReuseIdentifier: identifier)
        }
        return dataSource.cell(outerCell, numberOfRowsInSection: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource else { fatalError("Requires a data source.") }
        return dataSource.cell(outerCell, cellForRowAt: indexPath)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        dataSource?.cell?(outerCell, commit: editingStyle, forRowAt: indexPath)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (dataSource?.cell?(outerCell, canEditRowAt: indexPath) ?? false )
    }
}
extension SubTableViewDelegateAndDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return delegate?.cell?(outerCell, willSelectRowAtInner: indexPath)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.cell?(outerCell, didSelectRowAtInner: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource!.heightForInnerCell(for: outerCell)
    }
    
    //IMPLEMENT THIS
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
