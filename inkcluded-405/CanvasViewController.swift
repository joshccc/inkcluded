//
//  CanvasViewController.swift
//  inkcluded-405
//
//  Created by Francis Yuen on 1/13/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import UIKit

class CanvasViewController: UIViewController {
    
    var drawView: DrawView?

    @IBOutlet weak var canvas: UIView!
    
    var menu: CanvasMenuView?
    var selectImageVC: SelectImageViewController?
    private var orderedSubViews: [UIView] = [] // 0: drawView 1:menu
    
    var model: CanvasModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialization
        drawView = getNewDrawView()
        model = CanvasModel()
        menu = CanvasMenuView(size: self.view.frame.size, delegate: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        selectImageVC = storyboard.instantiateViewController(withIdentifier: "selectImageVC") as? SelectImageViewController
        
        // Set up view
        self.view.backgroundColor = UIColor.white
        
        // Bindings
        selectImageVC?.selectImageDelegate = self
        
        // Add subviews
        self.orderedSubViews.append(drawView!)
        self.orderedSubViews.append(menu!)
        
        canvas.addSubview(drawView!)
        canvas.addSubview(menu!)
        
        bringSubViewToFrontInOrder()
    }
    
    /**
     * Saves the canvas tot he default canvas path. The default will doc path is:
     * /Users/<USER>/Library/Developer/CoreSimulator/Devices/<SIMULATOR-ID>/data/Containers/Data/Application/<APP-ID>/Documents/
     *
     **/
    @IBAction func sendButtonPressed(_ sender: Any) {
        // Set the document path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let willDocPath = documentsPath.appending("willFile")
        model!.saveCanvasElements(drawViewSize: (drawView?.bounds.size)!, toFile: willDocPath)
    }
    
    // Loads a completely new canvas and discards the old canvas. Placeholder button just for canvas bugtesting.
    func loadButtonPressed(_ sender: Any) {
        // Set the document path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let willDocPath = documentsPath.appending("willFile")
    
        // Clear and restore context
        model?.clearCanvasElements()
        let renderElements = model?.restoreStateFromWILLFile(textViewDelegate: self, fromFile: willDocPath)
        resetDrawView(withElements: renderElements!)
    }
    
    func resetDrawView(withElements elements: [AnyObject]) {
        drawView?.removeFromSuperview();
        
        drawView = getNewDrawView()
        
        drawView?.refreshViewWithElements(elements: elements)
        
        canvas.addSubview(drawView!)
        self.orderedSubViews[0] = drawView!
        
        self.bringSubViewToFrontInOrder()
    }
    
    /**
     * Helper Functions
     */
    func getNewDrawView() -> DrawView {
        let newDrawView = DrawView(frame: canvas.bounds)
        newDrawView.setNewDelegate(newDelegate: self)
        
        return newDrawView
    }
    
    func bringSubViewToFrontInOrder() {
        for view in self.orderedSubViews {
            canvas.bringSubview(toFront: view)
        }
    }
}

extension CanvasViewController: CanvasMenuDelegate {
    func didClickOnMenuItem(item: CanvasMenuItem) {
        switch item {
        case .INSERT_IMAGE:
            self.present(self.selectImageVC!, animated: true, completion: nil)
            break
        case .INSERT_TEXT:
            // TODO: replace these magic numbers
            let myField: DraggableTextView = DraggableTextView(frame: CGRect.init(x: 50, y: 50, width: 150, height: 50));
            myField.delegate = self
            self.drawView!.addSubview(myField)
            self.view.becomeFirstResponder()
            self.model?.appendElement(elem: myField)
            break
        case .UNDO:
            let _ = self.model?.popMostRecentElement()
            resetDrawView(withElements: (self.model?.getCanvasElements())!)
            break
        case .DELETE:
            print("it matched here")
            // change to delete mode
            // any clicks while in delete mode will delete
            break
        }
        
        // Refresh the menu
        self.menu?.refreshView()
    }
    
    func shouldEnableMenuItem(item: CanvasMenuItem) -> Bool {
        if (item == .UNDO && self.model?.getCanvasElements().count == 0) {
            return false;
        }
        
        return true;
    }
}

extension CanvasViewController: SelectImageDelegate {
    func didSelectImage(image: DraggableImageView) {
        image.frame.origin = CGPoint(x: (canvas.frame.width - image.frame.width) / 2, y: (canvas.frame.height - image.frame.height) / 2)
        self.drawView!.addSubview(image)
        self.model!.appendElement(elem: image)
        self.menu?.refreshView()
    }
}

extension CanvasViewController: DrawStrokesDelegate {
    func addStroke(stroke: Stroke) {
        model!.appendElement(elem: stroke)
        self.menu?.refreshView()
    }
    
    
    func clearStrokes() {
        model!.clearCanvasElements()
        self.menu?.refreshView()
    }
    
    func getAllStrokes() -> [Stroke] {
        return (model?.getCanvasElements().filter({ (element) -> Bool in
            return ((element as? Stroke) != nil)
        }))! as! [Stroke]
    }
}

extension CanvasViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        var textFrame = textView.frame
        textFrame.size.height = textView.contentSize.height
        textView.frame = textFrame
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let draggableTextView = textView as? DraggableTextView
        draggableTextView?.configureDraggableGestureRecognizers()
        self.drawView!.endEditing(true)
        textView.isSelectable = false
    }
}
