//
//  Created by Faisal Bhombal on 9/25/20.
//

import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController {

    let processor = BarcodeProcessor()
    
    @IBOutlet weak var liveView: UIView!

    var trackingLevel = VNRequestTrackingLevel.accurate
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class BarcodeProcessor {
    let asset: AVAsset = AVAsset()
    
    
}
