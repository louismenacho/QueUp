//
//  FairQueueSwitchTableViewCell.swift
//  QueUp
//
//  Created by Louis Menacho on 6/1/22.
//

import UIKit

protocol FairQueueSwitchTableViewCellDelegate: AnyObject {
    func fairQueueSwitchTableViewCell(switchStateDidChange isOn: Bool)
}

class FairQueueSwitchTableViewCell: UITableViewCell {
    
    weak var delegate: FairQueueSwitchTableViewCellDelegate?

    @IBOutlet weak var fairQueueSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction func fairQueueSwitchDidChange(_ sender: UISwitch) {
        delegate?.fairQueueSwitchTableViewCell(switchStateDidChange: sender.isOn)
    }
}
