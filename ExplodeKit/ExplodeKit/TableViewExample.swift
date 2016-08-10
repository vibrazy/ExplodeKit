//
//  TableViewExample.swift
//  ExplodeKit
//
//  Created by Daniel Tavares on 10/08/2016.
//  Copyright © 2016 Daniel Tavares. All rights reserved.
//

import UIKit

class TableViewExample: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var explodeKit: ExplodeKit!
	var data = Array(repeating: 1, count: 50)

	override func viewDidLoad() {
		super.viewDidLoad()
		explodeKit = ExplodeKit(hostingView: self.view)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: "cell")!
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		defer {
			// remove data
			data.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}

		// explode
		if let cell = tableView.cellForRow(at: indexPath) {
			explodeKit.explode(cell.contentView)
		}
	}
}
