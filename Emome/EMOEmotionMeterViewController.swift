//
//  EMOEmotionMeterViewController.swift
//  Emome
//
//  Created by Huai-Che Lu on 10/26/15.
//  Copyright © 2015 Emome. All rights reserved.
//

import UIKit

class EMOEmotionMeterViewController: UIViewController {

    
    @IBOutlet weak var sadnessMeter: UISlider!
    @IBOutlet weak var frustrationMeter: UISlider!
    @IBOutlet weak var angerMeter: UISlider!
    @IBOutlet weak var fearMeter: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        EMODataManager.sharedInstance.sadnessValue     = sadnessMeter.value
        EMODataManager.sharedInstance.frustrationValue = frustrationMeter.value
        EMODataManager.sharedInstance.angerValue       = angerMeter.value
        EMODataManager.sharedInstance.fearValue        = fearMeter.value
    }


}
