//
//  HelpViewController.swift
//  GroupMatch
//
//  Created by Victor Yves Crispim on 03/5/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UIPageViewControllerDataSource {


    private var pageViewController: UIPageViewController?
    
    private let contentImages = ["page1.png","page2.png","page3.png","page4.png","page5.png","page6.png"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Help"
        // Do any additional setup after loading the view.
        createPageViewController()
        //setUpPageControl()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createPageViewController()
    {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as UIPageViewController
        pageController.dataSource = self
        
        if contentImages.count > 0{
            let firstController = getItemController(0)!
            let startingViewControllers: NSArray = [firstController]
           pageController.setViewControllers(startingViewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            
        }
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
    }
    
    private func setUpPageControl()
    {
    
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
        appearance.bounds = CGRectMake(0, 0, 200, 200)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
     let itemController = viewController as PageItemController
        if itemController.itemIndex > 0
        {
            return getItemController(itemController.itemIndex-1)
        }
        return nil
    }
    
     func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
     {
      let itemController = viewController as PageItemController
        
        if itemController.itemIndex+1 < contentImages.count
        {
            return getItemController(itemController.itemIndex+1)
        }
        return nil
     }
    
    
    private func getItemController(itemIndex: Int) -> PageItemController?
    {
        if itemIndex < contentImages.count
        {
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("ItemController") as PageItemController
            pageItemController.itemIndex = itemIndex
            pageItemController.imageName = contentImages[itemIndex]
            return pageItemController
        }
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
       return contentImages.count
        
    }
  
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    
}












