//
//  DrawingAnnotation.swift
//  PDF
//
//  Created by Kajal on 06/02/2019.
//  Copyright © 2019 Kajal. All rights reserved.
//

import Foundation
import PDFKit

class DrawingAnnotation: PDFAnnotation {
    public var path = UIBezierPath()
    
    func completed() {
        add(path)
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        let pathCopy = path.copy() as! UIBezierPath
        UIGraphicsPushContext(context)
        context.saveGState()
        
        context.setShouldAntialias(true)
        
        color.set()
        pathCopy.lineJoinStyle = .round
        pathCopy.lineCapStyle = .round
        pathCopy.lineWidth = border?.lineWidth ?? 1.0
        pathCopy.stroke()
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}
