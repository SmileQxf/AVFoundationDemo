//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by Smile on 2017/11/26.
//  Copyright © 2017年 com.jimi.smile. All rights reserved.
//

import UIKit
import SnapKit

class HomeViewController: HomeBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.tableView.delegate = self
    }

}


extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellType = self.dataSource[indexPath.section].data[indexPath.row]
        guard let classType = cellType.classType else {
            return
        }
        
        let vc = classType.init()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
