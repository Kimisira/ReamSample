//
//  SecondViewController.swift
//  RealmSample2
//
//  Created by Kimisira on 2016/05/22.
//  Copyright © 2016年 Kimisira. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Social

class SecondViewController:UIViewController,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    @IBOutlet var testConstraint: NSLayoutConstraint!

    //値渡される値
    var naiyouId:Int = 0
    var naiyouKategori = ""
    var naiyouData = ""
    
    //NavigationItem
    var DataBarButtonArray:NSMutableArray = []
    var DataBarButtonArray1:NSMutableArray = []
    
    //PickerViewの項目
    //UserDefaultsの読み込み
    var segmentedArray = NSUserDefaults.standardUserDefaults().objectForKey("Kategori") as! [String]
    var preSelectedLb:UILabel!
    let NavigationTitleLabel:TagLabel = TagLabel(frame: CGRectMake(0,0,100,20))
    let tagTitleLabel = 1
    
    let realm = try! Realm()
    let memodb = MemoDB()
    
    @IBOutlet weak var naiyouTextView: UITextView!
    var myPicker:UIPickerView! = UIPickerView()

    //MARK: - UIViewController
    override func  viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.toolbarHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: true) //ナビゲーションバーの表示・非表示
        self.navigationItem.title = naiyouKategori
        self.navigationItem.leftItemsSupplementBackButton = true  //NavigatioBarItemの戻るボタンが消えてししまうので表示する
        
        
        //TextViewの設定
        naiyouTextView.text = naiyouData
        naiyouTextView.allowsEditingTextAttributes = true
        naiyouTextView.delegate = self
        
        let DataBarButton1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action,target: self,action: #selector(SecondViewController.AutoPutto))
        DataBarButtonArray.addObject(DataBarButton1)
    
        self.navigationItem.titleView = titlelabel()
       
        self.navigationItem.setRightBarButtonItems((DataBarButtonArray as NSArray) as? [UIBarButtonItem], animated: true)
        segmentedArray.removeLast()
        
        myPicker = UIPickerView(frame: CGRectMake(0.2,self.view.frame.maxY,self.view.frame.width,200))
        myPicker.backgroundColor = UIColor.whiteColor()
        myPicker.delegate = self
        myPicker.dataSource = self
        myPicker.showsSelectionIndicator = true
        
        let buttonBorder = CALayer()
        buttonBorder.frame = CGRectMake(0, 0, self.view.frame.width, 2)
        buttonBorder.backgroundColor = UIColor.grayColor().CGColor
        self.myPicker.layer.addSublayer(buttonBorder)
        
        //内容が有る場合PickerViewのindextを渡された値にする
        if naiyouKategori != "" {
            let koumoku =  segmentedArray.indexOf(naiyouKategori)!
            print("K:\(koumoku)")
            myPicker.selectRow(koumoku, inComponent: 0, animated: false)
        }
        
        self.view.addSubview(myPicker)
    }  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let notification = NSNotificationCenter.defaultCenter()
        notification.addObserver(self, selector: #selector(SecondViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil) //表示
        notification.addObserver(self, selector: #selector(SecondViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil) //非表示
        if naiyouTextView.text != nil {
            if DataBarButtonArray.count == 1 {
            let DataBarButton2 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SecondViewController.AddData))
            DataBarButtonArray.addObject(DataBarButton2)
            self.navigationItem.setRightBarButtonItems((DataBarButtonArray as NSArray) as? [UIBarButtonItem], animated: true)
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
      
            let notification = NSNotificationCenter.defaultCenter()
            notification.removeObserver(self)
            notification.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            notification.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("メモリ使いすぎ")
    }
    
    //MARK: - KeyBoard
    // キーボード表示時の動作をここに記述する
    func keyboardWillShow(notification: NSNotification?) {
        //キーボードの高さを取得
        let userInfo:NSDictionary = notification!.userInfo!
        let keyboardBoundsValue = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight = keyboardBoundsValue.height
        let textViewMoto = naiyouTextView.frame.height
        let zureY = textViewMoto - keyboardHeight
        
        print("KeyboardHeight:\(keyboardHeight)")
        print("textViewMoto:\(textViewMoto)")
        print("Zure:\(zureY)")
        
        var contentInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0.0)
        contentInsets = naiyouTextView.contentInset
        contentInsets.bottom = keyboardHeight
        
        naiyouTextView.contentInset = contentInsets
        naiyouTextView.scrollIndicatorInsets = contentInsets
        
    }
    // キーボード消滅時の動作をここに記述する
    func keyboardWillHide(notification: NSNotification?) {
        var contentInsets = naiyouTextView.contentInset
        contentInsets.bottom = 0
        naiyouTextView.contentInset = contentInsets
        naiyouTextView.scrollIndicatorInsets = contentInsets
        
    }
    
    
    //MARK: - パーツ設定
    func titlelabel()->UILabel{
        NavigationTitleLabel.text = naiyouKategori
        if NavigationTitleLabel.text == "" {
            print("新規")
            NavigationTitleLabel.text = "カテゴリ"
        }
        return LabelConfig()
    }
    func LabelConfig()->UILabel{
        let tagFont = UIFont.systemFontOfSize(16)
        let tagHeight = tagFont.lineHeight + TagLabel().tagPadding * 2
        let tagText =  NavigationTitleLabel.text
        let tagWidth = tagLabelTextWidth(text: tagText!, font: tagFont, height: tagHeight)
        let tag = TagLabel(frame: CGRectMake(100, 100, tagWidth, tagHeight))
        tag.text = tagText
        tag.font = tagFont
        
        tag.userInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecondViewController.Kategori))
        tag.addGestureRecognizer(gestureRecognizer)
        
        return tag
    }
    func tagLabelTextWidth(text text: String, font: UIFont, height: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRectMake(0, 0, CGFloat.max, height))
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size.width + TagLabel().tagPadding * 2
    }
    func AddData(){
        //完了ボタンが表示してあるのでそれを消す
        if DataBarButtonArray.count == 2{
            DataBarButtonArray.removeObjectAtIndex(1)
            self.navigationItem.setRightBarButtonItems((DataBarButtonArray as NSArray) as? [UIBarButtonItem], animated: true)
        }
        if naiyouId == 0{
            memodb.id = MemoDB.lastId()
            memodb.naiyou = naiyouTextView.text
            memodb.nauTime = jastTime()
            memodb.kategori = naiyouKategori
            memodb.add()
        }else{
            memodb.naiyou = naiyouTextView.text
            memodb.id = naiyouId
            memodb.kategori = naiyouKategori
            memodb.nauTime = jastTime()
            try! realm.write(){
                realm.create(MemoDB.self,value: ["id": naiyouId,"naiyou":naiyouTextView.text,"kategori":naiyouKategori,"nauTime":jastTime()],update:true)
            }
        }
        print("追加:\(memodb)")
         self.naiyouTextView.resignFirstResponder()
        
        }
    func jastTime() -> String{
        let nawutime = NSDate()     //現在時間
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let data = dateFormatter.stringFromDate(nawutime)
        return data
    }
    func AutoPutto(){
        //Twitterの最後にタグを付ける設定
        let activityViewController = UIActivityViewController(activityItems: [CutomClass.init(NaiyouString: self.naiyouTextView.text)], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    func Kategori(){
        if self.naiyouTextView.resignFirstResponder() { //キーボード消し
            self.naiyouTextView.resignFirstResponder()
        }
        UIView.animateWithDuration(0,delay: 0.0,options: .CurveLinear ,animations:{() -> Void in
            self.myPicker.frame = CGRectMake(0 ,self.view.bounds.maxY - 200, self.view.bounds.size.width,200)
            self.view.addSubview(self.myPicker)
            self.view.bringSubviewToFront(self.myPicker)
            },completion: nil)

    }
    
    //MARK: - TextViewDelegate
    //テキストビューにフォーカスが移った
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if DataBarButtonArray.count == 1 {
            let DataBarButton2 = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SecondViewController.AddData))
            DataBarButtonArray.addObject(DataBarButton2)
            self.navigationItem.setRightBarButtonItems((DataBarButtonArray as NSArray) as? [UIBarButtonItem], animated: true)
        }
        return true
    }
    
    //MARK:- UIPicKerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return segmentedArray.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return segmentedArray[row] as String
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(segmentedArray[row])")
        
        naiyouKategori = segmentedArray[row]
        self.navigationItem.titleView = titlelabel()
        
    
        
        // 選択状態のラベルを代入
        self.preSelectedLb = pickerView.viewForRow(row, forComponent: component) as! UILabel
        // ピッカーのリロードでviewForRowが呼ばれる
        pickerView.reloadComponent(component)
        
        //pickerView.removeFromSuperview()
        
        UIView.animateWithDuration(0.2,delay: 0.0,options: .CurveLinear ,animations:{() -> Void in
            self.myPicker.frame = CGRectMake(0,self.view.frame.maxY,self.view.frame.width,200)
            self.view.addSubview(self.myPicker)
            self.view.bringSubviewToFront(self.myPicker)
            },completion: nil)
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        
        let tagFont = UIFont.systemFontOfSize(12.5)
        let tagHeight = tagFont.lineHeight + TagLabel().tagPadding * 2
        let tagText =  segmentedArray[row] as String
        let tagWidth = tagLabelTextWidth(text: tagText, font: tagFont, height: tagHeight)
        let tag = TagLabel(frame: CGRectMake(100, 100, tagWidth, tagHeight))
        tag.text = tagText
        tag.font = tagFont

         //既存ラベル、選択状態のラベルが存在している
        if let lb = pickerView.viewForRow(row, forComponent: component) as? UILabel,
            let _ = self.preSelectedLb {
            // 設定
            self.preSelectedLb = lb
            self.preSelectedLb.backgroundColor = UIColor(red: 0, green: 0.549, blue: 0.788, alpha: 0.3)
            self.preSelectedLb.textColor = UIColor.orangeColor()
        }
        
        return tag
    }
}
//MARK: - タグラベル
class TagLabel: UILabel {
    let tagPadding: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 2
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1
        textColor = UIColor.blackColor()
        clipsToBounds = true
        numberOfLines = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let insets = UIEdgeInsets(top: tagPadding, left: tagPadding, bottom: tagPadding, right: tagPadding)
        return super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }

}



