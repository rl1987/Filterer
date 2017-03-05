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
        secondaryMenu.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        sliderContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let smileImage = UIImage.init(named: "smile.png")
        
        monochromeButton.setBackgroundImage(imageByApplyingFilter(smileImage!, filter: monochromeFilter),
            for: UIControlState())
        brightnessButton.setBackgroundImage(imageByApplyingFilter(smileImage!, filter: brightnessFilter!),
            for: UIControlState())
        contrastButton.setBackgroundImage(imageByApplyingFilter(smileImage!, filter: contrastFilter!),
            for: UIControlState())
        
        monochromeButton.titleLabel!.text = nil
        brightnessButton.titleLabel!.text = nil
        contrastButton.titleLabel!.text = nil
    }

    // MARK: Share
    @IBAction func onShare(_ sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .photoLibrary
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            undoFilter()
            
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(_ sender: UIButton) {
        if (sender.isSelected) {
            hideSecondaryMenu()
            sender.isSelected = false
        } else {
            if (sliderContainer.isDescendant(of: view)) {
                hideSlider()
                editButton.isSelected = false
            }
            
            showSecondaryMenu()
            sender.isSelected = true
        }
    }
    
    func imageByApplyingFilter(_ fromImage: UIImage, filter: Filter) -> UIImage {
        imageProcessor!.imageFilters = Array.init(arrayLiteral: filter)
        let rgbaImage = RGBAImage.init(image: fromImage)
        
        return imageProcessor!.processImage(rgbaImage!).toUIImage()!
    }
    
    func applyFilter(_ filter: Filter)
    {
        resetImageViewToOldImage()
        
        oldImage = imageView.image
        
        filteredImage = imageByApplyingFilter(oldImage!, filter: filter)
        
        crossfadeToFilteredImage()
        
        compareButton.isEnabled = true
    }
    
    func animateTransitionToImage(_ image: UIImage!) {
        UIView.transition(with: self.imageView,
            duration: 1.0,
            options: UIViewAnimationOptions.transitionCrossDissolve,
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
        
        monochromeButton.isSelected = false
        brightnessButton.isSelected = false
        contrastButton.isSelected = false
        
        compareButton.isEnabled = false
        editButton.isEnabled = false
    }
    
    @IBAction func onMonochrome(_ sender: UIButton) {
        if (sender.isSelected == true) {
            undoFilter()
        }
        else {
            undoFilter()
            
            sender.isSelected = true
            
            applyFilter(MonochromeFilter.init())
        }
    }
    
    @IBAction func onBrightness(_ sender: UIButton) {
        if (sender.isSelected == true) {
            undoFilter()
        }
        else {
            undoFilter()
            
            sender.isSelected = true
            
            applyFilter(brightnessFilter!)
            
            slider.minimumValue = 0.0
            slider.maximumValue = 2.0
            slider.value = brightnessFilter!.brightnessChangeFactor
            
            editButton.isEnabled = true
        }
    }
    
    @IBAction func onContrast(_ sender: UIButton) {
        if (sender.isSelected == true) {
            undoFilter()
        }
        else {
            undoFilter()
            
            sender.isSelected = true
            
            applyFilter(contrastFilter!)
            
            slider.minimumValue = 0.0
            slider.maximumValue = 3.0
            slider.value = contrastFilter!.contrastChangeFactor
            
            editButton.isEnabled = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryMenu.alpha = 1.0
        }) 
    }

    func hideSecondaryMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryMenu.alpha = 0
            }, completion: { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }) 
    }
    
    @IBAction func onCompare(_ sender: UIButton) {
        if (filteredImage != nil && oldImage != nil) {
            if (imageView.image == filteredImage) {
                animateTransitionToImage(oldImage)
                
                originalLabel.isHidden = false
            } else {
                animateTransitionToImage(filteredImage)
                
                originalLabel.isHidden = true
            }
        }
    }
    
    func showSlider() {
        view.addSubview(sliderContainer)
        
        let bottomConstraint = sliderContainer.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = sliderContainer.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = sliderContainer.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = sliderContainer.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.sliderContainer.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.sliderContainer.alpha = 1.0
        }) 
    }
    
    func hideSlider() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sliderContainer.alpha = 0
            }, completion: { completed in
                if completed == true {
                    self.sliderContainer.removeFromSuperview()
                }
        }) 
    }
    
    @IBAction func onEdit(_ sender: UIButton) {
        if (sender.isSelected == false) {
            sender.isSelected = true
            
            if (secondaryMenu.isDescendant(of: view)) {
                hideSecondaryMenu()
                filterButton.isSelected = false
            }
            
            showSlider()
        } else {
            sender.isSelected = false
            hideSlider()
        }
    }
    
    @IBAction func onSliderEditingDidEnd(_ sender: UISlider) {
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

