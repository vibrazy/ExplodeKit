//
//  ExplodeKit.swift
//  ExplodeKit
//
//  Created by Daniel Tavares on 02/08/2016.
//  Copyright © 2016 Daniel Tavares. All rights reserved.
//

import Foundation
import SpriteKit

final class ExplodeKit {
	// Default Options
	struct Options {
		let torque: CGFloat = 0.05
		let impulse: CGVector = CGVector(dx: 0.0, dy: 20.0)
		let angulerImpulse: CGFloat = 0.05
		let gravity: CGVector = CGVector(dx: 0, dy: -1.0)
		let sliceAmount: Int = 10
	}

	weak var hostingView: UIView?
	var explodeScene: ExplodeKitScene!

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
	final func explode(elements: [UIView], options: Options = Options()) {
		elements.forEach({explode($0, options: options)})
	}

	/**
	Hide element, slice and generate nodes and perform explosion

	- parameter element: UI Element to be exploded
	- parameter options: explosion options
	*/
	final func explode(element: UIView, removeElement: Bool = true, options: Options = Options()) {
		// setup view
		setupIfNeeded(options)

		// show element so we can take snapshot
		if !removeElement {
			element.hidden = false
		}

		// Slice elements
		guard let slicedNodes = slice(element, scene: explodeScene, sliceAmount: options.sliceAmount) else { return }

		// explode elements
		explode(slicedNodes, options: options)

		// remove from hierarchy
		if removeElement {
			element.removeFromSuperview()
		} else {
			element.hidden = true
		}
	}

	/**
	Perform explosion of nodes

	- parameter childen: sliced nodes
	- parameter options: explosion options
	*/
	final private func explode(childen: [SKSpriteNode], options: Options = Options()) {
		childen.forEach { node in
			let body = SKPhysicsBody(rectangleOfSize: node.size, center: CGPoint(x: node.size.width * 0.5, y: node.size.height * 0.5))
			node.physicsBody = body

			/// Impulses options
			let mass = body.mass
			let upImpulse = mass * options.impulse.dy
			let sideImpulse = mass * options.impulse.dx
			let angularImpulse = mass * options.angulerImpulse

			/// apply impulses
			node.physicsBody?.applyTorque(options.torque)
			node.physicsBody?.applyAngularImpulse(angularImpulse)
			node.physicsBody?.applyImpulse(CGVectorMake(sideImpulse, upImpulse))
		}
	}

	/**
	Setup SKView and SKScene

	- parameter options: Options for explosion animations
	*/
	final private func setupIfNeeded(options: Options = Options()) {
		guard let view = hostingView else { return }
		if view.subviews.filter({$0 is ExplodeKitHolderView}).first == nil {
			let holderView = ExplodeKitHolderView()
			holderView.userInteractionEnabled = false
			holderView.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(holderView)
			holderView.fillSuperView()
			explodeScene = ExplodeKitScene(size: view.frame.size)
			explodeScene.backgroundColor = UIColor.clearColor()
			explodeScene.physicsWorld.gravity = options.gravity
			holderView.backgroundColor = explodeScene.backgroundColor
			holderView.presentScene(explodeScene)
//			holderView.showsPhysics = true
//			holderView.showsNodeCount = true
		}
	}

	/**
	Slice view

	- parameter view:        UI element
	- parameter scene:       Hosting Scene
	- parameter sliceAmount: Horizontal amount of slices

	- returns: Array of SKSpriteNodes rendered from sliced textures
	*/
	final private func slice(view: UIView, scene: SKScene, sliceAmount: Int) -> [SKSpriteNode]? {
		guard let image = UIImage(view: view) else { return nil }

		let imageWidth = image.size.width
		let imageHeight = image.size.height

		let sliceSize = round(imageWidth / CGFloat(sliceAmount))
		let horizontalSlices = ceil(imageWidth / sliceSize)
		let verticalSlices = ceil(imageHeight / sliceSize)

		// figure out the size of our tiles
		let tileWidth = imageWidth / horizontalSlices
		let tileHeight = imageHeight / verticalSlices

		let cgImage = image.CGImage!
		let scale = UIScreen.mainScreen().scale

		for y in 0...Int(verticalSlices) {
			for x in 0...Int(horizontalSlices) {
				let rect = CGRectMake(CGFloat(x) * tileWidth,
				                      CGFloat(y) * tileHeight,
				                      tileWidth,
				                      tileHeight)

				guard let tempImage = CGImageCreateWithImageInRect(cgImage, rect) else { continue }

				let texture = SKTexture(CGImage: tempImage)
				let node = SKSpriteNode(texture: texture)
				node.anchorPoint = CGPoint.zero
				node.size = CGSizeMake(rect.size.width / scale , rect.size.height / scale)
				node.position = CGPoint(x: view.frame.origin.x + (node.size.width * CGFloat(x)), y: scene.size.height - view.frame.origin.y - node.size.height - (node.size.height * CGFloat(y)))
				explodeScene.addChild(node)
			}
		}

		return explodeScene.children.flatMap({$0 as? SKSpriteNode})
	}
}

final class ExplodeKitHolderView: SKView {}
final class ExplodeKitScene: SKScene {}

extension UIImage {
	convenience init?(view: UIView) {
		guard view.frame.size.width > 0 && view.frame.size.height > 0 else {
			return nil
		}
		UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.mainScreen().scale)
		view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.init(CGImage: image.CGImage!)
	}
}
