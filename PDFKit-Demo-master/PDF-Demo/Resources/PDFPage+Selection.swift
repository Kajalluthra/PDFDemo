//
//  PDFPage+Selection.swift
//  PDF
//
//  Created by Kajal on 06/02/2019.
//  Copyright © 2019 Kajal. All rights reserved.
//

import UIKit
import PDFKit

extension PDFPage {
    func annotationWithHitTest(at: CGPoint) -> PDFAnnotation? {
        for annotation in annotations {
                if annotation.contains(point: at) {
                return annotation
            }
        }
        return nil
    }
}
