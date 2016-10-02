import UIKit


//MARK: TableViewCelLWithTableView
public class TableViewCellWithTableView: UITableViewCell {
    func didInsertRows(at indexPaths: [IndexPath]) {
        setHeightConstraint()
    }
    func didDeleteRows(at indexPaths: [IndexPath]) {
        setHeightConstraint()
    }
    
    public var delegate: TableViewCellWithTableViewDelegate? {
        didSet{ subTableViewDelegateAndDataSource.delegate = delegate }
    }
    public var dataSource: TableViewCellWithTableViewDataSource! {
        didSet {
            subTableViewDelegateAndDataSource.dataSource = dataSource
            setHeightConstraint()
        }
    }

    let _innerTableView = InnerTableView()
    public var innerTableView: UITableView {
        return _innerTableView
    }
    public var outerIndexPath: IndexPath
    let subTableViewDelegateAndDataSource = SubTableViewDelegateAndDataSource()
    
    required public init(outerIndexPath: IndexPath, reuseIdentifier: String) {
        self.outerIndexPath = outerIndexPath
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        subTableViewDelegateAndDataSource.outerCell = self
        _innerTableView.outerCell = self
        _innerTableView.delegate = subTableViewDelegateAndDataSource
        _innerTableView.dataSource = subTableViewDelegateAndDataSource
        _innerTableView.itvDelegate = self
        
        setupConstraints()
    }
    
    var heightConstraint: NSLayoutConstraint!
    
    func setupConstraints() {
        
        _innerTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(_innerTableView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(_innerTableView.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(_innerTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        constraints.append(_innerTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor))
        constraints.append(_innerTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor))
        
        heightConstraint = _innerTableView.heightAnchor.constraint(equalToConstant: 1)
        constraints.append(heightConstraint)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setHeightConstraint() {
        let headerHeight = _innerTableView.tableHeaderView?.frame.height ?? 0
        let footerHeight = _innerTableView.tableFooterView?.frame.height ?? 0
        let cellHeight = dataSource.heightForInnerCell(for: self)
        var cellCount = 0
        for i in 0..<(dataSource!.numberOfSections?(in: self) ?? 1) {
            cellCount += dataSource!.cell(self, numberOfRowsInSection: i)
        }
        let totalHeightForCells = CGFloat(cellCount) * cellHeight + headerHeight + footerHeight
        
        heightConstraint.constant = totalHeightForCells
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) { fatalError("Use init(outerIndexPath:)") }
    required public init?(coder aDecoder: NSCoder) { fatalError("Use init(outerIndexPath:)") }
}

extension TableViewCellWithTableView: InnerTableViewDelegate {
    func heightWasChanged() {
        setHeightConstraint()
    }
}


//MARK: TableViewCellWithTableView Delegate and DataSource
@objc public protocol TableViewCellWithTableViewDataSource: class {
    //Required
    func cell(_ cell: TableViewCellWithTableView, numberOfRowsInSection section: Int) -> Int
    func cell(_ cell: TableViewCellWithTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func cell(_ cell: TableViewCellWithTableView, registerInnerCellForSection section: Int)
    
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
        dataSource.cell(outerCell, registerInnerCellForSection: section)
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
