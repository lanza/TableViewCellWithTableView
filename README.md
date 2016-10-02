A simple framework that embeds a UITableView within a UITableViewCell's contentView. In a pretty early development stage.

##Problems:
* Deleting an innerCell is not resizing outerCell
* Intercept dequeue proces so as not to have to set outerIndexPath on TVCWTV.
* Crashes sometimes when doing combinations of move/insert/deletes
    - likely caused by outerCell's outerIndexPath not being set properly after various moves

##Usage Guide
First, some terminology.
* The main tableView is referred to as outerTableView and it's cells as outerCell.
* Likewise, the outerCell's embedded tableView is reffered to as innerTableView and it's cells as innerCell.
* IndexPaths are similarly referred via innerIndexPath and outerIndexPath where possible.

##Requirements for usage:
In viewDidLoad, set:
* tableView.rowHeight = UITableViewAutomaticDimension
* tableView.estimatedRowHeight = 2 //or higher

In cellForRowAt indexPath, set:
* cell.outerIndexPath = indexPath
* cell.dataSource = self
* You can also set optionally set inner Table{Header,Footer}View. Presently, inner Section{Header,Footer}Views are not implemented.

The outerCell holds an innerTableView. The innerTableView's delegate and dataSource are the outerCell and those methods are forwarded to the outerCell.dataSource/delegate objects. You are required to implement:
* heightForInnerCell - This should return a height for the innerCells. This number is used to calculate the size of the outerCell.
* reuseIdentifierForInnerTableView and cellClassForInnerTableView - For resusage.
* numberOfRowsInSection and cellForRowAt - The same as used in standard UITableViews.

###For now, in order to insert/reorder/delete outerCells, you'll need some workarounds to deal with an implementation details:


The outer moveRowAt delegate method should look like:

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableView.beginUpdates()
        //alter your data structure
        tableView.reloadData() //IMPORTANT
        tableView.endUpdates()
    }

The commit editingStyle and insertion require a helper method:

    func setOuterIndexPaths() {
        for cell in tableView.visibleCells as! [TableViewCellWithTableView] {
            cell.outerIndexPath = tableView.indexPath(for: cell)
        }
    }

The outer commit editingStyle delegate method should look like:

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        //alter your data structure
        tableView.deleteRows(at: [indexPath], with: .automatic)
        setOuterIndexPaths()
        tableView.endUpdates()
    }

For insertion, if you have a UIBarButtonItem with an action bound to #selector(newItem):

    func newItem() {
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        //alter your data structure
        tableView.endUpdates()
        setOuterIndexPaths()
    }


##ToDo:
* Implement delegate method to get {Table,Section}{Header,Footer}View if not implemented in cellForRowAt indexPath and make them unsettable in (cellForRowAt indexPath) to be more consistent with implementation methods.


