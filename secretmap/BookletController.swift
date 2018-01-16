//
//  BookletController.swift
//  secretmap
//
//  Created by Anton McConville on 2017-12-18.
//  Copyright © 2017 Anton McConville. All rights reserved.
//

import Foundation

import UIKit

struct Article: Codable {
    let page: Int
    let title: String
    let subtitle: String
    let imageEncoded:String
    let subtext:String
    let description: String
}

class BookletController: UIViewController, UIPageViewControllerDataSource {
    
    private var pageViewController: UIPageViewController?
    
    private var pages:[Article]?
    
    private var pageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "http://169.60.16.83:31874/pages"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let pages = try JSONDecoder().decode([Article].self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.pages = pages
                    self.pageCount = pages.count
                    self.createPageViewController()
                    self.setupPageControl()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
        
//        if let path = Bundle.main.url(forResource: "booklet", withExtension: "json") {
//            do {
//                _ = try Data(contentsOf: path, options: .mappedIfSafe)
//                let jsonData = try Data(contentsOf: path, options: .mappedIfSafe)
//                if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject] {
//
//                    if let pages = jsonDict["pages"] as? [[String: AnyObject]] {
//                        self.pages = pages
//                        self.pageCount = pages.count
//                        createPageViewController()
//                        setupPageControl()
//                    }
//                }
//            } catch {
//                print("couldn't parse JSON data")
//            }
//        }
    }
    
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewController(withIdentifier: "booklet") as! UIPageViewController
        pageController.dataSource = self
        
        if self.pageCount > 0 {
            let firstController = getItemController(itemIndex: 0)!
            let startingViewControllers = [firstController]
            pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParentViewController: self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor(red:0.92, green:0.59, blue:0.53, alpha:1.0)
        appearance.currentPageIndicatorTintColor = UIColor(red:0.47, green:0.22, blue:0.22, alpha:1.0)
        appearance.backgroundColor = UIColor.white
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! BookletItemController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemIndex: itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! BookletItemController
        
        if itemController.itemIndex+1 < self.pageCount {
            return getItemController(itemIndex: itemController.itemIndex+1)
        }
        
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> BookletItemController? {
        
        if itemIndex < self.pages!.count {
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "ItemController") as! BookletItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.titleString = self.pages![itemIndex].title
            pageItemController.subTitleString = self.pages![itemIndex].subtitle
            pageItemController.image = self.base64ToImage(base64: self.pages![itemIndex].imageEncoded)
            pageItemController.subtextString = self.pages![itemIndex].subtext
            pageItemController.statementString = self.pages![itemIndex].description
            
            return pageItemController
        }
        
        return nil
    }
    
    func base64ToImage(base64: String) -> UIImage {
        var img: UIImage = UIImage()
        if (!base64.isEmpty) {
            let decodedData = NSData(base64Encoded: base64 , options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedimage = UIImage(data: decodedData! as Data)
            img = (decodedimage as UIImage?)!
        }
        return img
    }
    
    // MARK: - Page Indicator
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pages!.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    // MARK: - Additions
    
    func currentControllerIndex() -> Int {
        
        let pageItemController = self.currentController()
        
        if let controller = pageItemController as? BookletItemController {
            return controller.itemIndex
        }
        
        return -1
    }
    
    func currentController() -> UIViewController? {
        
        let count:Int = (self.pageViewController?.viewControllers?.count)!;
        
        if count > 0 {
            return self.pageViewController?.viewControllers![0]
        }
        
        return nil
    }
}
