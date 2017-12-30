//
//  BookletItemController.swift
//  secretmap
//
//  Created by Anton McConville on 2017-12-27.
//  Copyright © 2017 Anton McConville. All rights reserved.
//

import UIKit

class BookletItemController: UIViewController {
    
    @IBOutlet var contentImageView: UIImageView?
    @IBOutlet var pageTitleView: UILabel?
    @IBOutlet var subtitleView: UILabel?
    @IBOutlet var statement: UITextView?
    @IBOutlet var subtextView: UILabel?
    
    // MARK: - Variables
    var itemIndex: Int = 0
    
    var imageName: String = "" {
        didSet {
            if let imageView = contentImageView {
                imageView.image = UIImage(named: imageName)
            }
        }
    }
    
    var titleString: String = "" {
        didSet {
            if let titleView = pageTitleView {
                titleView.text = titleString
            }
        }
    }
    
    var subTitleString: String = "" {
        didSet {
            if let subtitleView = subtitleView {
                subtitleView.text = titleString
            }
        }
    }
    
    var subtextString: String = "" {
        didSet {
            if let subtextView = subtextView {
                subtextView.text = subtextString
            }
        }
    }
    
    var statementString: String = "" {
        didSet {
            if let statement = statement {
                statement.text = statementString
            }
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImageView!.image = UIImage(named: imageName)
        pageTitleView!.text = titleString
        subtitleView!.text = subTitleString
        subtextView!.text = subtextString
        statement?.text = statementString
    }
}
