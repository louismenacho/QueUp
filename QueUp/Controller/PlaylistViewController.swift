//
//  PlaylistViewController.swift
//  QueUp
//
//  Created by Louis Menacho on 4/27/22.
//

import UIKit

class PlaylistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSongButton: UIButton!
    
    var vm = PlaylistViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func addSongButtonPressed(_ sender: UIButton) {
        print("addSongButtonPressed")
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.playlist.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell", for: indexPath) as! PlaylistTableViewCell
        cell.update(with: vm.playlist.items[indexPath.row])
        return cell
    }
}

extension PlaylistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}
