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

    @IBAction func openLink(_ sender: UIButton) {
         performSegue(withIdentifier: "webkitSegue", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webkitSegue"
        {
            if let navController = segue.destination as? UINavigationController {
                let webview = navController.topViewController as! AssetViewController
                webview.link = self.link
            }
        }
    }
    
    // MARK: - Variables
    var itemIndex: Int = 0
    
    var link:String = ""
    
    var image: UIImage = UIImage() {
        didSet {
            if let imageView = contentImageView {
                imageView.image = image
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
    
    var linkString: String = "" {
        didSet {
            link = linkString
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        contentImageView!.image = image
        pageTitleView!.text = titleString
        subtitleView!.text = subTitleString
        subtextView!.text = subtextString
        statement?.text = statementString
        link = linkString
    }
}
