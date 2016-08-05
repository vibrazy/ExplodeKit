//
//  ViewController.swift
//  ExplodeKit
//
//  Created by Daniel Tavares on 02/08/2016.
//  Copyright © 2016 Daniel Tavares. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	var explodeKit: ExplodeKit!
	@IBOutlet weak var elementsViews: UIView!

	@IBOutlet weak var topAlice: UIImageView!
	@IBOutlet weak var middleAlice: UIImageView?
	override func viewDidLoad() {
		super.viewDidLoad()
		explodeKit = ExplodeKit(hostingView: self.view)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let alice = middleAlice where alice.alpha == 1.0 else {
			explodeKit.explode(elementsViews.subviews)
			return
		}
		explodeKit.explode(alice, removeElement: false)
	}
}
