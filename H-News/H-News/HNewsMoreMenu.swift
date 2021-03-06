struct HNewsMoreMenuItem {
    let title: String
    let image: UIImage
    let callback: () -> Void
}

class HNewsMoreMenuItemView: UIView {
    
    fileprivate let title: UILabel = UILabel()
    fileprivate let icon: UIImageView = UIImageView()
    
    var item: HNewsMoreMenuItem?  {
        didSet {
            guard let item = item else { return }
            backgroundColor = Colors.lightGray
            
            // Create title
            addSubview(title)
            title.text = item.title
            title.textAlignment = .center
            title.textColor = Colors.gray
            title.snp.makeConstraints { (make) -> Void in
                make.bottom.equalTo(-16)
                make.right.left.equalTo(0)
            }
            
            // Create image - with tintcolor shining through (.AlwaysTemplate)
            icon.image = item.image.withRenderingMode(.alwaysTemplate)
            addSubview(icon)
            icon.tintColor = Colors.gray
            icon.snp.makeConstraints { (make) -> Void in
                make.centerX.equalTo(0)
                make.bottom.equalTo(title.snp.top).offset(-6)
            }
            
            let tapGestureRecog = UITapGestureRecognizer(target: self, action: #selector(HNewsMoreMenuItemView.didTapOnItem(_:)))
            addGestureRecognizer(tapGestureRecog)
        }
    }
    
    /// Call the item's callback
    func didTapOnItem(_ sender: UITapGestureRecognizer) {
        guard let item = item else { return }
        // Animate highlight
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.icon.tintColor = Colors.white
            }) { (finished) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    self.icon.tintColor = Colors.gray
                    }, completion: { (finished) in
                        item.callback()
                })
        }
    }
}

/// MoreMenu main class.
class HNewsMoreMenuView: UIView {
    
    fileprivate let animationDuration: TimeInterval = 0.2
    
    fileprivate let itemviews: [HNewsMoreMenuItemView] = [
        HNewsMoreMenuItemView(), HNewsMoreMenuItemView(),
        HNewsMoreMenuItemView(), HNewsMoreMenuItemView()
    ]
    
    var items: [HNewsMoreMenuItem] = [] {
        didSet {
            // Setup subview - the items
            for i in 0 ..< items.count where items.count == itemviews.count {
                itemviews[i].item = items[i]
            }
        }
    }
    
    /// Indicates if view is shown
    var shown: Bool = false
    
    /// Dismisses the more menu, does not remove it from the superview
    func dismiss() {
        shown = !shown
        // tell constraints they need updating
        setNeedsUpdateConstraints()
        // update constraints now so we can animate the change
        updateConstraints()
        // do the initial layout
        layoutIfNeeded()
        UIView.animate(withDuration: animationDuration) {
            guard let superview = self.superview else { return }
            // make animatable changes
            self.snp.updateConstraints({ (make) in
                make.bottom.equalTo(superview.snp.bottom).offset(superview.frame.height / 3)
            })
            // do the animation
            self.layoutIfNeeded()
        }
    }
    
    /// Shows the more menu in the superview
    func show() {
        shown = !shown
        // tell constraints they need updating
        setNeedsUpdateConstraints()
        // update constraints now so we can animate the change
        updateConstraints()
        // do the initial layout
        layoutIfNeeded()
        UIView.animate(withDuration: animationDuration) {
            guard let superview = self.superview else { return }
            // make animatable changes
            self.snp.updateConstraints({ (make) in
                make.bottom.equalTo(superview.snp.bottom).offset(0)
            })
            // do the animation
            self.layoutIfNeeded()
        }
    }
    
    /// Called whenever the view was added in the view that it will present itself in
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        
        /// Setup the more menu view
        // Hide the view under the superview, animate up when shown
        self.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(superview.snp.height).dividedBy(3)
            make.bottom.equalTo(superview.snp.bottom).offset(superview.frame.height / 3)
        }

        // Setup menu item grid ...
        let lowerleftitem = itemviews[0]
        addSubview(lowerleftitem)
        lowerleftitem.snp.makeConstraints { (make) in
            make.width.equalTo(self.snp.width).dividedBy(2)
            make.height.equalTo(self.snp.height).dividedBy(2)
            make.bottom.left.equalTo(0)
        }
        
        let lowerrightitem = itemviews[1]
        addSubview(lowerrightitem)
        lowerrightitem.snp.makeConstraints { (make) in
            make.width.equalTo(self.snp.width).dividedBy(2)
            make.height.equalTo(self.snp.height).dividedBy(2)
            make.bottom.right.equalTo(0)
        }
        
        let upperleftitem = itemviews[2]
        addSubview(upperleftitem)
        upperleftitem.snp.makeConstraints { (make) in
            make.width.equalTo(self.snp.width).dividedBy(2)
            make.height.equalTo(self.snp.height).dividedBy(2)
            make.top.left.equalTo(0)
        }

        let upperrightitem = itemviews[3]
        addSubview(upperrightitem)
        upperrightitem.snp.makeConstraints { (make) in
            make.width.equalTo(self.snp.width).dividedBy(2)
            make.height.equalTo(self.snp.height).dividedBy(2)
            make.top.right.equalTo(0)
        }
    }
}
