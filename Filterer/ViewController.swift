//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var filteredImage: UIImage?
    var oldImage: UIImage?
    
    let imageProcessor = ImageProcessor.init(filters: [Filter]())
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    
    @IBOutlet var monochromeButton: UIButton!
    @IBOutlet var brightnessButton: UIButton!
    @IBOutlet var contrastButton: UIButton!
    
    @IBOutlet var compareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var originalLabel: UILabel!
    
    @IBOutlet var sliderContainer: UIView!
    @IBOutlet weak var slider: UISlider!
    
    let monochromeFilter = MonochromeFilter.init()
    let brightnessFilter = BrightnessFilter.init(factor: 1.5)
    let contrastFilter = ContrastFilter.init(factor: 2.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        sliderContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let smileImage = UIImage.init(named: "smile.png")
        
        monochromeButton.setBackgroundImage(imageByApplyingFilter(smileImage!, filter: monochromeFilter),
            forState: UIControlState.Normal)
        brightnessButton.setBackgroundImage(imageByApplyingFilter(smileImage!, filter: brightnessFilter!),
            forState: UIControlState.Normal)
        contrastButton.setBackgroundImage(imageByApplyingFilter(smileImage!, filter: contrastFilter!),
            forState: UIControlState.Normal)
        
        monochromeButton.titleLabel!.text = nil
        brightnessButton.titleLabel!.text = nil
        contrastButton.titleLabel!.text = nil
    }

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            undoFilter()
            
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            if (sliderContainer.isDescendantOfView(view)) {
                hideSlider()
                editButton.selected = false
            }
            
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func imageByApplyingFilter(fromImage: UIImage, filter: Filter) -> UIImage {
        imageProcessor!.imageFilters = Array.init(arrayLiteral: filter)
        let rgbaImage = RGBAImage.init(image: fromImage)
        
        return imageProcessor!.processImage(rgbaImage!).toUIImage()!
    }
    
    func applyFilter(filter: Filter)
    {
        resetImageViewToOldImage()
        
        oldImage = imageView.image
        
        filteredImage = imageByApplyingFilter(oldImage!, filter: filter)
        
        crossfadeToFilteredImage()
        
        compareButton.enabled = true
    }
    
    func animateTransitionToImage(image: UIImage!) {
        UIView.transitionWithView(self.imageView,
            duration: 1.0,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: { self.imageView.image = image },
            completion: nil)
    }
    
    func crossfadeToFilteredImage() {
        animateTransitionToImage(filteredImage)
    }
    
    func resetImageViewToOldImage() {
        if (oldImage != nil) {
            animateTransitionToImage(oldImage)
            oldImage = nil
            filteredImage = nil
        }
    }
    
    func undoFilter() {
        resetImageViewToOldImage()
        
        imageProcessor?.imageFilters = [Filter]()
        
        monochromeButton.selected = false
        brightnessButton.selected = false
        contrastButton.selected = false
        
        compareButton.enabled = false
        editButton.enabled = false
    }
    
    @IBAction func onMonochrome(sender: UIButton) {
        if (sender.selected == true) {
            undoFilter()
        }
        else {
            undoFilter()
            
            sender.selected = true
            
            applyFilter(MonochromeFilter.init())
        }
    }
    
    @IBAction func onBrightness(sender: UIButton) {
        if (sender.selected == true) {
            undoFilter()
        }
        else {
            undoFilter()
            
            sender.selected = true
            
            applyFilter(brightnessFilter!)
            
            slider.minimumValue = 0.0
            slider.maximumValue = 2.0
            slider.value = brightnessFilter!.brightnessChangeFactor
            
            editButton.enabled = true
        }
    }
    
    @IBAction func onContrast(sender: UIButton) {
        if (sender.selected == true) {
            undoFilter()
        }
        else {
            undoFilter()
            
            sender.selected = true
            
            applyFilter(contrastFilter!)
            
            slider.minimumValue = 0.0
            slider.maximumValue = 3.0
            slider.value = contrastFilter!.contrastChangeFactor
            
            editButton.enabled = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onCompare(sender: UIButton) {
        if (filteredImage != nil && oldImage != nil) {
            if (imageView.image == filteredImage) {
                animateTransitionToImage(oldImage)
                
                originalLabel.hidden = false
            } else {
                animateTransitionToImage(filteredImage)
                
                originalLabel.hidden = true
            }
        }
    }
    
    func showSlider() {
        view.addSubview(sliderContainer)
        
        let bottomConstraint = sliderContainer.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = sliderContainer.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = sliderContainer.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = sliderContainer.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.sliderContainer.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.sliderContainer.alpha = 1.0
        }
    }
    
    func hideSlider() {
        UIView.animateWithDuration(0.4, animations: {
            self.sliderContainer.alpha = 0
            }) { completed in
                if completed == true {
                    self.sliderContainer.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onEdit(sender: UIButton) {
        if (sender.selected == false) {
            sender.selected = true
            
            if (secondaryMenu.isDescendantOfView(view)) {
                hideSecondaryMenu()
                filterButton.selected = false
            }
            
            showSlider()
        } else {
            sender.selected = false
            hideSlider()
        }
    }
    
    @IBAction func onSliderEditingDidEnd(sender: UISlider) {
        let currentFilter = imageProcessor!.imageFilters.last!
        
        if (currentFilter === contrastFilter) {
            contrastFilter!.contrastChangeFactor = sender.value
            
            applyFilter(contrastFilter!)
        } else if (currentFilter === brightnessFilter) {
            brightnessFilter!.brightnessChangeFactor = sender.value
            
            applyFilter(brightnessFilter!)
        }
        
    }
}

