//
//  OnboardingViewController.swift
//  OtoSehatFixed
//
//  Created by Jevier Izza Maulana on 12/04/22.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var slides: [OnboardingSlide] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentPage = 0 {
        didSet {
            if currentPage == slides.count - 1 {
                nextButton.setTitle("Get Started", for: .normal)
            } else {
                nextButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slides = [
                    OnboardingSlide(title: "Any Vehicle", description: "You don't have to worry about our vehicle", image: #imageLiteral(resourceName: "vehicle 1")),
                    OnboardingSlide(title: "We'll Remind You", description: "Busy all day? Don't worry, we will keep in touch with you", image: #imageLiteral(resourceName: "ingat")),
                    OnboardingSlide(title: "It's On Your Hand", description: "Don't worry, We are here to help you from your hand", image: #imageLiteral(resourceName: "tangan"))
                ]
    }
    @IBAction func nextButtonClick(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            let controller = storyboard?.instantiateViewController(withIdentifier: "homeNC") as! UINavigationController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            present(controller, animated: true, completion: nil)
        } else {
            
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = currentPage
        }
    }

}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
    }
}
