//
//  ViewController.swift
//  RealmSample2
//
//  Created by Kimisira on 2016/05/22.
//  Copyright © 2016年 Kimisira. All rights reserved.
//

import UIKit
import HMSegmentedControl
import RealmSwift

class MemoTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var dataTableView: UITableView! //TableViewインスタンス
    
    //RealmSwift関係
    var realm = try! Realm()
    var dataRistDo = try! Realm().objects(MemoDB).sorted("nauTime",ascending: false) //時間で降順(descending order)
    
    //SegmentedController関係
    var menuControl:HMSegmentedControl!
    var menuControlColor:NSArray = [UIColor.redColor(),UIColor.blueColor(),UIColor.brownColor()]
    var menuArray:[String] = ["メモ","アイデア","設定"]
    
    //件数関係
    var dataCount = 0
    var dataIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataTableView.delegate = self
        dataTableView.dataSource = self
        
        //UserDefaultsに追加
        if menuArray.count == 0 {
             let defaults = NSUserDefaults.standardUserDefaults()
             defaults.setObject(kategoriArray,forKey:"Kategori")
             defaults.synchronize()
        }
               
        //遷移後のBackButtonItem
        let DataBarButton2 = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = DataBarButton2
        
        dateTableView.editing = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //viewが表示される直前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Viewが表示された")
        // ナビゲーションを非表示
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //toolBarを表示する
        self.navigationController?.toolbarHidden = false
        
        //UserDefaults読み込み
        let defolt = NSUserDefaults.standardUserDefaults()
        if ((defolt.objectForKey("Kategori")) != nil) {
            kategoriArray = defolt.objectForKey("Kategori") as! [String]
        }
        print("I:\(dataIndex)")
        segmentedConfig()
        toolbar()
        self.dateTableView.reloadData()
    }
    
    //MARK:Segmented
    func segmentedConfig(){

        segmentedControl = HMSegmentedControl(frame: CGRectMake(0, 20, 320, 45))
        segmentedControl.sectionTitles = kategoriArray
        segmentedControl.selectedSegmentIndex = dataIndex
        segmentedControl.selectionIndicatorColor = UIColor(red: 0, green: 0.549, blue: 0.788, alpha: 0.5)
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName:UIColor.orangeColor()]
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        
        let blockVariable:IndexChangeBlock = {(index:Int) -> Void in
            
            self.dataIndex = index
        
            //Segmentが設定を選んだら設定画面を開く
            if self.kategoriArray[self.dataIndex] == "設定" {
                let addViewContoller = self.storyboard?.instantiateViewControllerWithIdentifier("ConfigVC") as! ConfigViewController
                addViewContoller.piyo = self.kategoriArray
                self.navigationController?.pushViewController(addViewContoller, animated: true)
                self.dataIndex = 0
            }
            print("POI:\(self.dataIndex)")
             self.toolbar()
             self.dateTableView.reloadData()
            
        }
        segmentedControl.indexChangeBlock = blockVariable
        
        //Segmentedの下に線を引く
        let buttonBorder = CALayer()
        let borderWidth = CGFloat(0.1)
        buttonBorder.frame = CGRectMake(0, 51, 320 - borderWidth, 1)
        buttonBorder.backgroundColor = UIColor.grayColor().CGColor
        self.view.layer.addSublayer(buttonBorder)
        self.view.addSubview(segmentedControl)
    }
    
    //MARK:UIToolBar
    func toolbar(){
        results = try! Realm().objects(MemoDB).filter("kategori BEGINSWITH[c] %@",self.kategoriArray[self.dataIndex]).sorted("nauTime",ascending: false)
        let dataCount = "\(results.count)件"
        let aaaa = UILabel(frame: CGRectMake(0,0,100,30) )
        aaaa.text = dataCount
        aaaa.sizeToFit()
        aaaa.textAlignment = NSTextAlignment.Center
        
        
        //ToolBarに配置する要件
        let toolbarlabel = UIBarButtonItem(customView: aaaa)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: self,action: nil)
        let button1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(MemoTableViewController.addButton))
        let button2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: #selector(MemoTableViewController.trashButton))
        self.toolbarItems = [button2,flexibleItem,toolbarlabel,flexibleItem, button1]
        
        
    }
    
    //MARK:AddButton
    func addButton(){
        let memodb = MemoDB()
        memodb.id = MemoDB.lastId()
        
        
        let addViewContoller = self.storyboard?.instantiateViewControllerWithIdentifier("SecondVC") as! SecondViewController
        addViewContoller.naiyouId = memodb.id
        
        self.navigationController?.pushViewController(addViewContoller, animated: true)
    }
    
    //MARK:DeleteButton
    func trashButton(){
        
        if dateTableView.editing {
            dateTableView.setEditing(false, animated: true)
        }else{
            dateTableView.setEditing(true, animated: true)
        }
        
    }
    
    //MARK:Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.dateTableView.indexPathForSelectedRow!
        
        if segue.identifier == "DataSegue" {
            let secondView = segue.destinationViewController as! SecondViewController
            results = try! Realm().objects(MemoDB).filter("kategori BEGINSWITH[c] %@",self.kategoriArray[self.dataIndex]).sorted("nauTime",ascending: false)
            
            secondView.naiyouData = results[indexPath.row].naiyou
            secondView.naiyouId = results[indexPath.row].id
            secondView.naiyouKategori = results[indexPath.row].kategori
        }
        
    }
    
    
    //MARK: - UITableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.results = try! Realm().objects(MemoDB).filter("kategori BEGINSWITH[c] %@",self.kategoriArray[self.dataIndex])
        return results.count
    
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath)
        
        results = try! Realm().objects(MemoDB).filter("kategori BEGINSWITH[c] %@",self.kategoriArray[self.dataIndex]).sorted("nauTime",ascending: false)
        let object = results[indexPath.row]
        cell.textLabel?.text = object.naiyou
        cell.detailTextLabel?.text = object.nauTime
        

        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
       results = try! Realm().objects(MemoDB).filter("kategori BEGINSWITH[c] %@",self.kategoriArray[self.dataIndex]).sorted("nauTime",ascending: false)
        let object = results[indexPath.row]
        
        try! realm.write(){
            realm.delete(object)
            dateTableView.deleteRowsAtIndexPaths([indexPath],withRowAnimation: UITableViewRowAnimation.Automatic)
            toolbar()
            self.dateTableView.setEditing(false, animated: true)
        }
        
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    

    
    
    
}



