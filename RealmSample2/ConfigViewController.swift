//
//  ConfigViewController.swift
//  RealmSample2
//
//  Created by Kimisira on 2016/05/27.
//  Copyright © 2016年 Kimisira. All rights reserved.
//

import Foundation
import UIKit
class ConfigViewController:UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    var piyo = [""]
    @IBOutlet weak var kategoriTableView: UITableView!
   
    //ViewControllerのViewがロードされた後に呼び出される
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.toolbarHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: true) //ナビゲーションバーの表示・非表示
        
        piyo.removeLast() //最後を削除
        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add,target:self,action:  #selector(ConfigViewController.addButton))
        
        self.navigationItem.rightBarButtonItems = [editButtonItem(),rightAddBarButtonItem,]

        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let viewControllers = self.navigationController?.viewControllers {
            var existsSelfInViewControllers = true
            for viewController in viewControllers {
                if viewController ==  self {
                    existsSelfInViewControllers = false
                    break
                }
            }
            if existsSelfInViewControllers {
                piyo.insert("設定", atIndex: piyo.count)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                               defaults.setObject(piyo,forKey:"Kategori")
                               defaults.synchronize()
                print("カテゴリ:\(piyo)")
            }
        }
            
    }
    
    //EditingButton
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        //kategoriTableView.editing = editing
        kategoriTableView.setEditing(editing, animated: true)
        print(kategoriTableView.editing)
        
    }
    
    func addButton() {
        print("ADDButton")
        alertConfig()
    }
    func alertConfig(){
        let alert:UIAlertController = UIAlertController(title: "カテゴリ", message: "新しいカテゴリを書いてください", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",style: UIAlertActionStyle.Cancel,handler:{(action:UIAlertAction!) -> Void in
            print("Cancel")
        })
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.Default,handler:{(action:UIAlertAction!) -> Void in
            print("OK")
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            if textFields != nil {
                for textField:UITextField in textFields! {
                    print(textField.text)
                    self.piyo.append(textField.text!)
                    print(self.piyo)
                    self.kategoriTableView.reloadData()
                }
            }

        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!)->Void in
            text.placeholder = "カテゴリを記入してくだい"
        })
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return piyo.count
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath)
        cell.textLabel?.text = piyo[indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        kategoriTableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(piyo[indexPath.row])
    }
    
    //MARK:UITableViewDataSource-Delete
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            print("削除")
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //削除
            piyo.removeAtIndex(indexPath.row)
            kategoriTableView.deleteRowsAtIndexPaths([indexPath],withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
    }
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let targetPiyo = piyo[sourceIndexPath.row]
        if let index = piyo.indexOf(targetPiyo){
            piyo.removeAtIndex(index)
            piyo.insert(targetPiyo, atIndex: destinationIndexPath.row)
        }
    }
    

}