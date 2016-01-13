//
//  HNewsCommentTableViewCell.swift
//  H-News
//
//  Created by Alexander Lingtorp on 04/01/16.
//  Copyright © 2016 Lingtorp. All rights reserved.
//

// TODO: When clicked the cell shall expand and reveal a textfield in which you can reply to the comment and 
// TODO: Add a shortcut to scroll back to top.

import MCSwipeTableViewCell

class HNewsCommentTableViewCell: UITableViewCell {
    
    private static let defaultCellColor = UIColor(red: 214, green: 214, blue: 214, alpha: 0.8)

    private static let dateCompsFormatter = NSDateComponentsFormatter()
    static let cellID = "HNewsCommentTableViewCell"
    
    @IBOutlet var indentationConstraint: NSLayoutConstraint!
    @IBOutlet var cellHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var author: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    private let gradient = CAGradientLayer()
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            author.text = comment.author
            
            // Setup NSDateFormatter
            HNewsCommentTableViewCell.dateCompsFormatter.unitsStyle = .Short
            HNewsCommentTableViewCell.dateCompsFormatter.zeroFormattingBehavior = .DropAll
            HNewsCommentTableViewCell.dateCompsFormatter.maximumUnitCount = 1
            dateLabel.text = HNewsCommentTableViewCell.dateCompsFormatter.stringFromTimeInterval(-comment.date.timeIntervalSinceNow)
            dateLabel.text? += " ago"
            
            commentLabel.text = comment.text
            
            let doubletapGestureRecog = UITapGestureRecognizer(target: self, action: "didDoubleTapOnComment")
            doubletapGestureRecog.numberOfTapsRequired = 2
            addGestureRecognizer(doubletapGestureRecog)
            
            gradient.frame = CGRectMake(0, 0, CGFloat(comment.offset  * 15), contentView.bounds.height)
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint   = CGPoint(x: 1, y: 0.5)
            gradient.colors = [UIColor.lightGrayColor().CGColor, contentView.backgroundColor?.CGColor ?? UIColor.redColor().CGColor]
            contentView.layer.addSublayer(gradient)
            
            setNeedsDisplay() // Renders the cell before it comes into sight
        }
    }
    
    private var expanded = false
    
    func didDoubleTapOnComment() {
        let v = expanded ? 3 : 0
        UIView.animateWithDuration(0.75) { () -> Void in
            self.commentLabel.numberOfLines = v
            self.contentView.layoutIfNeeded()
        }
        expanded = !expanded
        // This will recompute the cell's height
        guard let tableView = superview?.superview as? UITableView else { return }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    /// Handle indentation: Sets the indentation depending on the offset property of the comment
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let comment = comment else { return }
        indentationConstraint.constant = CGFloat(comment.offset) * 15
    }
}