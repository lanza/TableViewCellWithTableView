import UIKit

//MARK: TableViewCelLWithTableView
public class TableViewCellWithTableView: UITableViewCell {
    public var delegate: TableViewCellWithTableViewDelegate? {
        didSet{ subTableViewDelegateAndDataSource.delegate = delegate }
    }
    public var dataSource: TableViewCellWithTableViewDataSource! {
        didSet {
            subTableViewDelegateAndDataSource.dataSource = dataSource
            setConstraints()
        }
    }

    let innerTableView = InnerTableView()

    public var outerIndexPath: IndexPath!
    let subTableViewDelegateAndDataSource = SubTableViewDelegateAndDataSource()
    
    required public init(reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        subTableViewDelegateAndDataSource.outerCell = self
        innerTableView.delegate = subTableViewDelegateAndDataSource
        innerTableView.dataSource = subTableViewDelegateAndDataSource
    }
    
    public override func prepareForReuse() {
        print("prepare for reuse")
    }
    
    var heightConstraint: NSLayoutConstraint!
    
    func setConstraints() {
        
        innerTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(innerTableView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(innerTableView.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(innerTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        constraints.append(innerTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor))
        constraints.append(innerTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor))
        
        heightConstraint = innerTableView.heightAnchor.constraint(equalToConstant: 1)
        constraints.append(heightConstraint)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setHeightConstraint() {
        innerTableView.beginUpdates()
        let headerHeight = innerTableView.tableHeaderView?.frame.height ?? 0
        let footerHeight = innerTableView.tableFooterView?.frame.height ?? 0
        let cellHeight = dataSource.heightForInnerCell(for: self)
        var cellCount = 0
        for i in 0..<(dataSource!.numberOfSections?(in: self) ?? 1) {
            cellCount += dataSource!.cell(self, numberOfRowsInSection: i)
        }
        let totalHeightForCells = CGFloat(cellCount) * cellHeight + headerHeight + footerHeight
        
        heightConstraint.constant = totalHeightForCells
        innerTableView.endUpdates()
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) { fatalError("Use init(outerIndexPath:)") }
    required public init?(coder aDecoder: NSCoder) { fatalError("Use init(outerIndexPath:)") }
}

//MARK: - InnerTableView interceptions
extension TableViewCellWithTableView {
    public func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        innerTableView.deleteRows(at: indexPaths, with: animation)
        setHeightConstraint()
    }
    public func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        innerTableView.insertRows(at: indexPaths, with: animation)
        setHeightConstraint()
    }
    public var innerTableHeaderView: UIView? {
        get {
            return innerTableView.tableHeaderView
        }
        set {
            innerTableView.tableHeaderView = newValue
            setHeightConstraint()
        }
    }
    public var innerTableFooterView: UIView? {
        get {
            return innerTableView.tableFooterView
        }
        set {
            innerTableView.tableFooterView = newValue
            setHeightConstraint()
        }
    }
    public func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        innerTableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        return innerTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}


//MARK: TableViewCellWithTableView Delegate and DataSource
@objc public protocol TableViewCellWithTableViewDataSource: class {
    //Required
    func cell(_ cell: TableViewCellWithTableView, numberOfRowsInSection section: Int) -> Int
    func cell(_ cell: TableViewCellWithTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func reuseIdentifierForInnerTableView(for cell: TableViewCellWithTableView) -> String
    func cellClassForInnerTableView(for cell: TableViewCellWithTableView) -> AnyClass
    
    func heightForInnerCell(for cell: TableViewCellWithTableView) -> CGFloat

    //Optional Other
    @objc optional func cell(_ cell: TableViewCellWithTableView, commit editingSyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    @objc optional func cell(_ cell: TableViewCellWithTableView, canEditRowAt indexPath: IndexPath) -> Bool
    @objc optional func numberOfSections(in cell: TableViewCellWithTableView) -> Int
}

@objc public protocol TableViewCellWithTableViewDelegate {
    @objc optional func cell(_ cell: TableViewCellWithTableView, willSelectRowAtInner innerIndexPath: IndexPath) -> IndexPath?
    @objc optional func cell(_ cell: TableViewCellWithTableView, didSelectRowAtInner innerIndexPath: IndexPath)
    @objc optional func cell(_ cell: TableViewCellWithTableView, didTap button: UIButton)
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
        let cellClass = dataSource.cellClassForInnerTableView(for: outerCell)
        let identifier = dataSource.reuseIdentifierForInnerTableView(for: outerCell)
        outerCell.register(cellClass, forCellReuseIdentifier: identifier)
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
        return (delegate?.cell?(outerCell, willSelectRowAtInner: indexPath) ?? indexPath)
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
