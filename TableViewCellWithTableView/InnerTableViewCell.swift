import UIKit

class InnerTableViewCell: UITableViewCell {
    
    let label = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(label.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(label.leftAnchor.constraint(equalTo: contentView.leftAnchor))
        constraints.append(label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        constraints.append(label.rightAnchor.constraint(equalTo: contentView.rightAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
