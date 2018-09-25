//
//  MainVC.swift
//  FiveSlowFingers
//
//  Created by fsociety.1 on 6/2/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

class MainVC: UIViewController {
    @IBOutlet weak var recordLabel: UILabel!
    
    var rus = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let score = UserDefaults.standard.integer(forKey: "score")
        if score > 0 {
            recordLabel.text = "Your best score is: \(score)"
        }
        checkForUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func english(_ sender: Any) {
        rus = false
        performSegue(withIdentifier: "showGame", sender: self)
    }
    
    @IBAction func russian(_ sender: Any) {
        rus = true
        performSegue(withIdentifier: "showGame", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameVC {
            if rus {
                vc.chosenKeyb = "ru"
                vc.chosenFile = "rusWords"
                vc.chosenLang = "ru-RU"
            }
            else {
                vc.chosenKeyb = "en"
                vc.chosenFile = "enWords"
                vc.chosenLang = "en-US"
            }
        }
    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        print(currentVersion)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    func checkForUpdate() {
        _ = try? isUpdateAvailable { (update, error) in
            if let error = error {
                print(error)
            } else if let update = update {
                print(update)
                if update {
                    let alert = UIAlertController(title: "New Version Found", message: "A new version of this app is available. \nWant to download it now?", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1393657236"),
                            UIApplication.shared.canOpenURL(url){
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
