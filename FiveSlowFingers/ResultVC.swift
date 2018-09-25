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

    override var prefersStatusBarHidden: Bool {
        return true
    }

    var getCorrect = Int()
    var getIncorrect = Int()

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
        let score = UserDefaults.standard.integer(forKey: "score")
        if getCorrect > score {
            UserDefaults.standard.set(getCorrect, forKey: "score")
        }
    }

}
