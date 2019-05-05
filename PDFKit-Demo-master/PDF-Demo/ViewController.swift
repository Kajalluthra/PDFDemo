//
//  ViewController.swift
//
//  Created by Max on 10/31/17.
//  Copyright (c) 2017 Max. All rights reserved.
//

import UIKit
import PDFKit
import MessageUI

class ViewController: UIViewController {
    
    private var pdfdocument: PDFDocument?

    private var shouldUpdatePDFScrollPosition = true
    private let pdfDrawer = PDFDrawer()
    private var pageNumber: Int = 0
    private var pageCount: Int = 0
    
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPDFView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBtnClick))

        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
        
        
        guard let bundle = Bundle.main.url(forResource: "test", withExtension: "pdf") else {
            return
        }
        let fileURL = bundle
        pdfdocument = PDFDocument(url: fileURL)
        pdfView.document = pdfdocument
        
        if let count = pdfView.document {
            pageCount = count.pageCount
        }
    }
    
    private func setupPDFView() {
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)
        pdfView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        pdfView.autoScales = true
        pdfView.backgroundColor = UIColor.white
    }
    
    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }
    }
    
    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    private func fixPDFViewScrollPosition() {
        if let page = pdfView.document?.page(at: pageNumber) {
            pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).size.height)))
        }
    }
    
    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true // This call is required to fix PDF document scale, seems to be bug inside PDFKit
    }
    
    @IBAction func nxtButton(_ sender: Any) {
        
        if pageNumber == pageCount - 1 {
            return
        }
        
        pageNumber += 1
        if let page = pdfView.document?.page(at: pageNumber) {
            pdfView.goToNextPage(page)
        }
    }
    
    @IBAction func previousPage(_ sender: Any) {
        if pageNumber == 0 {
            return
        }
        
        pageNumber -= 1
        if let page = pdfView.document?.page(at:pageNumber) {
            pdfView.goToPreviousPage(page)
        }
    }
    
}

extension ViewController : MFMailComposeViewControllerDelegate {
    
    @objc func saveBtnClick(sender: UIButton) {
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent("pdf") else { return }
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        
        let filename = randomString(length: 6) + ".pdf"
        let file1 = writePath.appendingPathComponent(filename)
        
        pdfdocument?.write(to: file1)
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Have you heard a swift?")
            mailComposer.setMessageBody("This is what they sound like.", isHTML: false)
            
            
            if let fileData = NSData(contentsOfFile: file1.path) {
                
                mailComposer.addAttachmentData(fileData as Data, mimeType: "application/pdf", fileName: "annotation")
            }
            
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
