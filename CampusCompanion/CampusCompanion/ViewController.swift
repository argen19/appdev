//
//  ViewController.swift
//  CampusCompanion
//
//  Created by ARCE, EDZEL KIM on 9/12/26.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func getStartedButton(_ sender: UIButton) {
        subtitleLabel.text = "Let's get started!"
    }
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

