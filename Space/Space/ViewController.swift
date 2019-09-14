//
//  ViewController.swift
//  Space
//
//  Created by Cong Viet Ho on 9/14/19.
//  Copyright © 2019 Viety Software. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var pickPhoto: UIButton!
    @IBOutlet weak var savePhoto: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Private properties
    
    private var partedImages = Array<UIImage>()
    private let gridContainerLayer = CALayer()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureScrollView()
        configureImageView()
        addGridOnImage()
    }
    
    // MARK: - IBAction
    
    @IBAction func pickAction(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        partedImages = getPartsFromImage(image: imageView.image!, rows: 3, columns: 3)
        
        partedImages.forEach { image in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    // MARK: - Private functions
    
    private func configureScrollView() {
        backgroundView.layer.addSublayer(gridContainerLayer)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2
    }
    
    private func configureImageView() {
        imageView.image = #imageLiteral(resourceName: "square")
        imageView.contentMode = .scaleAspectFill
    }
    
    private func addGridOnImage() {
        gridContainerLayer.frame = imageView.layer.frame
        
        var gridLayers = Array<CALayer>()
        gridLayers.forEach { $0.removeFromSuperlayer() }
        gridLayers = []
        
        let numberOfGrid = 3
        
        let width = gridContainerLayer.bounds.width / CGFloat(numberOfGrid)
        for i in 1..<numberOfGrid {
            let x = floor(CGFloat(i) * width)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: gridContainerLayer.bounds.height))
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor(white: 1, alpha: 0.6).cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            gridContainerLayer.addSublayer(lineLayer)
            gridLayers.append(lineLayer)
        }
        
        let height = gridContainerLayer.bounds.height / CGFloat(numberOfGrid)
        for i in 1..<numberOfGrid {
            let y = floor(CGFloat(i) * height)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: gridContainerLayer.bounds.width, y: y))
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor(white: 1, alpha: 0.6).cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            gridContainerLayer.addSublayer(lineLayer)
            gridLayers.append(lineLayer)
        }
    }
    
    private func getPartsFromImage(image: UIImage, rows: Int, columns: Int) -> [UIImage] {
        var images: [UIImage] = []
        let imageSize = image.size
        var xPos = 0.0
        var yPos = 0.0
        let width = imageSize.width / CGFloat(rows)
        let height = imageSize.height / CGFloat(columns)
        for y in 0..<columns {
            xPos = 0.0
            for x in 0..<rows {
                let rect = CGRect(x: xPos, y: yPos, width: Double(width), height: Double(height))
                let cImage = image.cgImage?.cropping(to: rect)
                let dImage = UIImage(cgImage: cImage!)
                let imageView = UIImageView(frame: CGRect(x: Double(x) * Double(width),
                                                          y: Double(y) * Double(height),
                                                          width: Double(width),
                                                          height: Double(height)))
                imageView.image = dImage
                images.append(dImage)
                xPos += Double(width)
                
            }
            yPos += Double(height)
        }
        return images
        
    }
    
    // MARK: - Saving alert selector
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your cropped image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

// MARK: - Scroll View delegate

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - Image Picker Controller delegate

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
}
