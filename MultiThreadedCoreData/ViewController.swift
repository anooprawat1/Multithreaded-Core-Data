//
//  ViewController.swift
//  MultiThreadedCoreData
//
//  Created by Anoop Rawat on 13/03/17.
//  Copyright © 2017 Anoop Rawat. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    @IBOutlet var quakeTableView:UITableView!
    var datasource = QuakeManager.sharedInstance.earthQuake
    @IBOutlet var activityIndicator:UIActivityIndicatorView!
    @IBOutlet var loadingView:UIView!
    @IBOutlet var loadingLabel:UILabel!
    @IBOutlet var headerViewHeightConstraint:NSLayoutConstraint!
    @IBOutlet var headerView:UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerViewHeightConstraint.constant = 0
        activityIndicator.startAnimating()
        QuakeManager.sharedInstance.addObserver(self, forKeyPath: "earthQuake", options: .new, context: nil)
        QuakeManager.sharedInstance.addObserver(self, forKeyPath: "isSavingFinish", options: .new, context: nil)
        
        // Reading Data From File
        DispatchQueue.global(qos: .background).async {
            () -> Void in
            QuakeManager.sharedInstance.readDataFromFile()
        }
    }
   
    // MARK: - Observation Method
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "isSavingFinish" {
            DispatchQueue.main.async() {
                self.loadingView.removeFromSuperview()
                self.headerViewHeightConstraint.constant = 0
            }
        }
        else {
            if !self.animatingActivity() {
                loadingData()
            }
        }
    }
    
    func animatingActivity() -> Bool  {
        var returnValue = false
        if loadingView.center.y == self.view.center.y {
            returnValue = true
            self.loadingLabel.text = "Sync progress in background:)"
            headerViewHeightConstraint.constant = 50
            
            UIView.animate(withDuration: 2.0, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                self?.loadingView.center = CGPoint(x:(self?.headerView.frame.width)!/2, y: (self?.headerView.frame.height)! + 10)
                
                }, completion: { [weak self] (isCompleted)  in
                    self?.loadingData()
                    self?.headerViewAnimation()
                })
        }
        return returnValue
    }
    
    func loadingData() {
        datasource = QuakeManager.sharedInstance.earthQuake
        quakeTableView.reloadData()
    }
    
    
    func headerViewAnimation()  {
        loadingLabel.textColor = UIColor.white
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        self.loadingView.layer.add(animation, forKey: nil)
        
    }
    
    deinit {
        removeObserver(self, forKeyPath: "isSavingFinish")
        removeObserver(self, forKeyPath: "earthQuake")
    }
}


extension ViewController:UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Tableview Datasource Method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell  = tableView.dequeueReusableCell(withIdentifier: String(describing:QuakeTableViewCell.self), for: indexPath) as! QuakeTableViewCell
        let quakeObject = datasource[indexPath.row]
        tableViewCell.timeLabel.text = "\(quakeObject.time!)"
        tableViewCell.magnitudeLabel.text = "\(quakeObject.magnitude!)"
        tableViewCell.locationLabel.text = quakeObject.placeName!
        return tableViewCell
    }
    
    // MARK: - Managing Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset
        let  bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y: Float = Float(offset.y) + Float(bounds.size.height) + Float(inset.bottom)
        let height: Float = Float(size.height)
        let distance: Float = 10
        
        if y > height + distance {
            QuakeManager.sharedInstance.executedFetchRequest()
        }
    }
    
}

class QuakeTableViewCell: UITableViewCell {
    @IBOutlet var timeLabel:UILabel!
    @IBOutlet var magnitudeLabel:UILabel!
    @IBOutlet var locationLabel:UILabel!
}
