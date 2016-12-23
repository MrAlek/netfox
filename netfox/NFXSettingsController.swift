//
//  NFXSettingsController.swift
//  netfox
//
//  Copyright © 2015 kasketis. All rights reserved.
//

import Foundation
import UIKit

class NFXSettingsController: NFXGenericController, UITableViewDelegate, UITableViewDataSource
{
    // MARK: Properties

    var nfxURL = "https://github.com/kasketis/netfox"
    
    var tableView: UITableView = UITableView()
    
    var tableData = [HTTPModelShortType]()
    var filters = [Bool]()

    // MARK: View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Settings"
                
        self.tableData = HTTPModelShortType.allValues
        self.filters =  NFX.sharedInstance().getCachedFilters()
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage.NFXStatistics(), style: .plain, target: self, action: #selector(NFXSettingsController.statisticsButtonPressed)), UIBarButtonItem(image: UIImage.NFXInfo(), style: .plain, target: self, action: #selector(NFXSettingsController.infoButtonPressed))]

        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 60)
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
        self.view.addSubview(self.tableView)
        
        var nfxVersionLabel: UILabel
        nfxVersionLabel = UILabel(frame: CGRect(x: 10, y: self.view.frame.height - 60, width: self.view.frame.width - 2*10, height: 30))
        nfxVersionLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        nfxVersionLabel.font = UIFont.NFXFont(14)
        nfxVersionLabel.textColor = UIColor.NFXOrangeColor()
        nfxVersionLabel.textAlignment = .center
        nfxVersionLabel.text = "netfox - \(nfxVersion)"
        self.view.addSubview(nfxVersionLabel)
        
        var nfxURLButton: UIButton
        nfxURLButton = UIButton(frame: CGRect(x: 10, y: self.view.frame.height - 40, width: self.view.frame.width - 2*10, height: 30))
        nfxURLButton.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        nfxURLButton.titleLabel?.font = UIFont.NFXFont(12)
        nfxURLButton.setTitleColor(UIColor.NFXGray44Color(), for: UIControlState())
        nfxURLButton.titleLabel?.textAlignment = .center
        nfxURLButton.setTitle(nfxURL, for: UIControlState())
        nfxURLButton.addTarget(self, action: #selector(NFXSettingsController.nfxURLButtonPressed), for: .touchUpInside)
        self.view.addSubview(nfxURLButton)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        NFX.sharedInstance().cacheFilters(self.filters)
    }
    
    func nfxURLButtonPressed()
    {
        UIApplication.shared.openURL(URL(string: nfxURL)!)
    }
    
    func infoButtonPressed()
    {
        var infoController: NFXInfoController
        infoController = NFXInfoController()
        self.navigationController?.pushViewController(infoController, animated: true)
    }
    
    func statisticsButtonPressed()
    {
        var statisticsController: NFXStatisticsController
        statisticsController = NFXStatisticsController()
        self.navigationController?.pushViewController(statisticsController, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case 0: return 1
        case 1: return self.tableData.count
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        cell.textLabel?.font = UIFont.NFXFont(14)
        cell.tintColor = UIColor.NFXOrangeColor()

        switch indexPath.section
        {
        case 0:
            cell.textLabel?.text = "Logging"
            let nfxEnabledSwitch: UISwitch
            nfxEnabledSwitch = UISwitch()
            nfxEnabledSwitch.setOn(NFX.sharedInstance().isEnabled(), animated: false)
            nfxEnabledSwitch.addTarget(self, action: #selector(NFXSettingsController.nfxEnabledSwitchValueChanged(_:)), for: .valueChanged)
            cell.accessoryView = nfxEnabledSwitch
            return cell
            
        case 1:
            let shortType = tableData[indexPath.row]
            cell.textLabel?.text = shortType.rawValue
            configureCell(cell, indexPath: indexPath)
            return cell

        case 2:
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "Clear data"
            cell.textLabel?.textColor = UIColor.NFXRedColor()
            cell.textLabel?.font = UIFont.NFXFont(16)

            return cell

            
        default: return UITableViewCell()

        }
        
    }
    
    func reloadTableData()
    {
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.NFXGray95Color()
        
        switch section {
        case 1:
            
            var filtersInfoLabel: UILabel
            filtersInfoLabel = UILabel(frame: headerView.bounds)
            filtersInfoLabel.backgroundColor = UIColor.clear
            filtersInfoLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            filtersInfoLabel.font = UIFont.NFXFont(13)
            filtersInfoLabel.textColor = UIColor.NFXGray44Color()
            filtersInfoLabel.textAlignment = .center
            filtersInfoLabel.text = "\nSelect the types of responses that you want to see"
            filtersInfoLabel.numberOfLines = 2
            headerView.addSubview(filtersInfoLabel)
            
            
        default: break
        }
        
        return headerView

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section
        {
        case 1:
            let cell = tableView.cellForRow(at: indexPath)
            self.filters[indexPath.row] = !self.filters[indexPath.row]
            configureCell(cell, indexPath: indexPath)
            break
            
        case 2:
            clearDataButtonPressedOnTableIndex(indexPath)
            break
            
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)


    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.section {
        case 0: return 44
        case 1: return 33
        case 2: return 44
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {        
        let iPhone4s = (UIScreen.main.bounds.height == 480)
        switch section {
        case 0:
            if iPhone4s {
                return 20
            } else {
                return 40
            }
        case 1:
            if iPhone4s {
                return 50
            } else {
                return 60
            }
        case 2:
            if iPhone4s {
                return 25
            } else {
                return 50
            }
        default: return 0
        }
    }
    
    func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath)
    {
        if (cell != nil) {
            if self.filters[indexPath.row] {
                cell!.accessoryType = .checkmark
            } else {
                cell!.accessoryType = .none
            }
        }

    }
    
    func nfxEnabledSwitchValueChanged(_ sender: UISwitch)
    {
        if sender.isOn {
            NFX.sharedInstance().enable()
        } else {
            NFX.sharedInstance().disable()
        }
    }
    
    func clearDataButtonPressedOnTableIndex(_ index: IndexPath)
    {
        let actionSheetController: UIAlertController = UIAlertController(title: "Clear data?", message: "", preferredStyle: .actionSheet)
        actionSheetController.popoverPresentationController?.sourceView = tableView
        actionSheetController.popoverPresentationController?.sourceRect = tableView.rectForRow(at: index)

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)

        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            NFX.sharedInstance().clearOldData()
        }
        actionSheetController.addAction(yesAction)

        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .default) { action -> Void in
        }
        actionSheetController.addAction(noAction)

        self.present(actionSheetController, animated: true, completion: nil)
    }
    
}
