//
//  ResultVC.swift
//  FiveSlowFingers
//
//  Created by fsociety.1 on 5/30/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit

class ResultVC: UIViewController {
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    var getCorrect = Int()
    var getIncorrect = Int()
    var getLanguage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctLabel.text = "\(getCorrect)"
        incorrectLabel.text = "\(getIncorrect)"
        saveRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func back(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        self.present(vc, animated: false, completion: nil)
    }
    
    func saveRecord() {
        let score = UserDefaults.standard.integer(forKey: "score" + getLanguage)
        if getCorrect > score {
            UserDefaults.standard.set(getCorrect, forKey: "score" + getLanguage)
        }
    }
    
    
    @IBAction func share(_ sender: Any) {
        shareButton.isHidden = true
        backButton.isHidden = true
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        var imagesToShare = [AnyObject]()
        imagesToShare.append(image!)
        
        shareButton.isHidden = false
        backButton.isHidden = false
        let activityViewController = UIActivityViewController(activityItems: imagesToShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
}
