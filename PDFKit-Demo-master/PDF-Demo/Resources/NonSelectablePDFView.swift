//
//  NonSelectable.swift
//  PDF
//
//  Created by Kajal on 06/02/2019.
//  Copyright © 2019 Kajal. All rights reserved.
//

import UIKit
import PDFKit

class NonSelectablePDFView: PDFView {
    
    // Disable selection
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
}
