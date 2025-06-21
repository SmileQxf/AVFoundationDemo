//
//  HomeBaseViewController.swift
//  AVFoundationDemo
//
//  Created by Coding on 2025/6/21.
//  Copyright © 2025 smile. All rights reserved.
//

import UIKit

class HomeBaseViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource = [HomeListGroupModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBaseViewUI()
    }
    

    func setBaseViewUI() {
        
        self.view.backgroundColor = .white
        
        
        self.tableView.dataSource = self
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    

}


extension HomeBaseViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    
}
