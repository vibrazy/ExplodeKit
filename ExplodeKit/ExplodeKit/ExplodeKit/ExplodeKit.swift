//
//  ExplodeKit.swift
//  ExplodeKit
//
//  Created by Daniel Tavares on 02/08/2016.
//  Copyright © 2016 Daniel Tavares. All rights reserved.
//

import SpriteKit

final class ExplodeKitHolderView: SKView {}
final class ExplodeKitScene: SKScene {}

final class ExplodeKit {
	// Default Options
	struct Options {
		let torque: CGFloat = 0.1
		let impulse: CGVector = CGVector(dx: 0.0, dy: 10.0)
		let angulerImpulse: CGFloat = 0.15
		let gravity: CGVector = CGVector(dx: 0, dy: -1.0)
		let sliceAmount: Int = 20
	}

	private weak var hostingView: UIView?
	private var explodeScene: ExplodeKitScene!

	/**
	Initializer

	- parameter hostingView: Parent view where uielements are held
	- parameter options:     explosion options

	- returns: ExplodeKit
	*/
	init(hostingView: UIView, options: Options = Options()) {
		self.hostingView = hostingView
	}

	/**
	Explode array of elements

	- parameter elements: UI Elements
	- parameter options:  explosion options
	*/
	final func explode(_ elements: [UIView], options: Options = Options()) {
		elements.forEach({explode($0, options: options)})
	}

	/**
	Hide element, slice and generate nodes and perform explosion

	- parameter element: UI Element to be exploded
	- parameter options: explosion options
	*/
	final func explode(_ element: UIView, options: Options = Options()) {
		// setup view
		setupIfNeeded(options)

		// show element so we can take snapshot
		element.alpha = 1.0

		// Slice elements
		guard let slicedNodes = slice(element, scene: explodeScene, sliceAmount: options.sliceAmount) else { return }

		// explode elements
		explode(slicedNodes, options: options)

		element.alpha = 0.0
	}

	/**
	Perform explosion of nodes

	- parameter childen: sliced nodes
	- parameter options: explosion options
	*/
	final private func explode(_ childen: [SKSpriteNode], options: Options = Options()) {
		childen.forEach { node in
			let body = SKPhysicsBody(rectangleOf: node.size, center: CGPoint(x: node.size.width * 0.5, y: node.size.height * 0.5))
			node.physicsBody = body

			/// Impulses options
			let mass = body.mass
			let upImpulse = mass * options.impulse.dy
			let sideImpulse = mass * options.impulse.dx
			let angularImpulse = mass * options.angulerImpulse

			/// apply impulses
			node.physicsBody?.applyTorque(options.torque)
			node.physicsBody?.applyAngularImpulse(angularImpulse)
			node.physicsBody?.applyImpulse(CGVector(dx: sideImpulse, dy: upImpulse))
		}
	}

	/**
	Setup SKView and SKScene

	- parameter options: Options for explosion animations
	*/
	final private func setupIfNeeded(_ options: Options = Options()) {
		guard let view = hostingView else { return }
		if view.subviews.filter({$0 is ExplodeKitHolderView}).first == nil {
			let holderView = ExplodeKitHolderView()
			holderView.isUserInteractionEnabled = false			
			view.addSubview(holderView)
			holderView.fillSuperView()
			explodeScene = ExplodeKitScene(size: view.frame.size)
			explodeScene.backgroundColor = UIColor.clear()
			explodeScene.physicsWorld.gravity = options.gravity
			holderView.backgroundColor = explodeScene.backgroundColor
			holderView.presentScene(explodeScene)
			holderView.showsPhysics = true
			holderView.showsNodeCount = true
		}
	}

	/**
	Slice view

	- parameter view:        UI element
	- parameter scene:       Hosting Scene
	- parameter sliceAmount: Horizontal amount of slices

	- returns: Array of SKSpriteNodes rendered from sliced textures
	*/
	final private func slice(_ view: UIView, scene: SKScene, sliceAmount: Int) -> [SKSpriteNode]? {
		guard let image = UIImage(view: view) else { return nil }

		let imageWidth = image.size.width
		let imageHeight = image.size.height

		let sliceSize = round(imageWidth / CGFloat(sliceAmount))
		let horizontalSlices = ceil(imageWidth / sliceSize)
		let verticalSlices = ceil(imageHeight / sliceSize)

		// figure out the size of our tiles
		let tileWidth = imageWidth / horizontalSlices
		let tileHeight = imageHeight / verticalSlices

		let cgImage = image.cgImage!
		let scale = UIScreen.main().scale

		for y in 0...Int(verticalSlices) {
			for x in 0...Int(horizontalSlices) {
				let rect = CGRect(x: CGFloat(x) * tileWidth,
				                      y: CGFloat(y) * tileHeight,
				                      width: tileWidth,
				                      height: tileHeight)

				guard let tempImage = cgImage.cropping(to: rect) else { continue }

				let texture = SKTexture(cgImage: tempImage)
				let node = SKSpriteNode(texture: texture)
				node.anchorPoint = CGPoint.zero
				node.size = CGSize(width: rect.size.width / scale , height: rect.size.height / scale)
				node.position = CGPoint(x: view.frame.origin.x + (node.size.width * CGFloat(x)), y: scene.size.height - view.frame.origin.y - node.size.height - (node.size.height * CGFloat(y)))
				explodeScene.addChild(node)
			}
		}

		return explodeScene.children.flatMap({$0 as? SKSpriteNode})
	}
}

// MARK: Extensions

extension UIImage {
	convenience init?(view: UIView) {
		guard !view.frame.isNull else {
			return nil
		}

		UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main().scale)

		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		view.layer.render(in: context)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.init(cgImage: (image?.cgImage!)!)
	}
}

extension UIView {
	func fillSuperView() {
		guard let superview = self.superview else { return }
		self.translatesAutoresizingMaskIntoConstraints = false
		let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
		let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: superview, attribute: .left, multiplier: 1, constant: 0)
		let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
		let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: superview, attribute: .right, multiplier: 1, constant: 0)
		superview.addConstraints([top, left, bottom, right])
	}
}
