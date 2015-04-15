//
//  ScheduleViewController.swift
//  MPCRevisited
//
//  Created by Luan Barbalho Kalume on 16/03/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

var reusableIdentifier = "cell"
var grade = [Int]()
let scheduleService = ScheduleService()


class ScheduleViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private let freeTimeIndex = ConfigValues.sharedInstance.freeTimeIndex
    private let busyTimeIndex = ConfigValues.sharedInstance.busyTimeIndex
    private let optionalTimeIndex = ConfigValues.sharedInstance.optionalTimeIndex
    private let daysOfWeek = ConfigValues.sharedInstance.daysOfWeek
    private let firstHour = ConfigValues.sharedInstance.firstHour
    private let lastHour = ConfigValues.sharedInstance.lastHour
    
    /* Salva qual collection view está sendo arrastada */
    var scrollingView: UIScrollView!
    
    /* Referência ao botão de editar */
    @IBOutlet weak var editButton: UIButton!
    
    /* Referência às collection views da tela */
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var daysCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.allowsMultipleSelection = true
        mainCollectionView.allowsSelection = false
        
        timeCollectionView.delegate = self
        timeCollectionView.dataSource = self
        timeCollectionView.showsVerticalScrollIndicator = false
        
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        daysCollectionView.scrollEnabled = false
        
        /* Define o tamanho da janela com as horas, usando como base o tamanho da tela do device */
        timeCollectionView.bounds = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width*0.1875, timeCollectionView.bounds.height)
        mainCollectionView.bounds = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width*1.8125, timeCollectionView.bounds.height)
        
        var mySchedules = scheduleService.getMySchedule()
        var timeList = getMyScheduleIndex(mySchedules)
        for time in timeList
        {
            grade.append(time)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editTouched(sender: UIButton)
    {
        /* Apenas alterna entre editar ou não, trocando o texto do botão no processo */
        if (!mainCollectionView.allowsSelection)
        {
            editButton.setTitle("OK", forState: nil)
            mainCollectionView.allowsSelection = true
        }
        else
        {
            editButton.setTitle("Edit", forState: nil)
            mainCollectionView.allowsSelection = false
            let timeList = prepareScheduleToSave(grade)
            scheduleService.saveMySchedule(timeList)
        }
        
    }
    
    
// MARK: Funções obrigatórias do protocolo datasource
    
    /* Retorna o número de células exibidas nas collections views */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        switch collectionView
        {
        case mainCollectionView:
            return (daysOfWeek * ( lastHour - firstHour ) )
        case timeCollectionView:
            return ( lastHour - firstHour )
        case daysCollectionView:
            return daysOfWeek
        default:
            return 0
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    /* Função que cria as células nas collection views */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if( collectionView == mainCollectionView)
        {
            var mainCell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
            
            switch grade[indexPath.item]
            {
            case 0:
                mainCell.backgroundColor = UIColor(red: 0.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            case 1:
                mainCell.backgroundColor = UIColor.redColor()
            case 2:
                mainCell.backgroundColor = UIColor.orangeColor()
            default:
                mainCell.backgroundColor = UIColor.blackColor()
            }
            
            return mainCell
        }
        else if( collectionView == timeCollectionView )
        {
            var leftCell: TimeViewCell
            
            leftCell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifier, forIndexPath: indexPath) as! TimeViewCell
            leftCell.textLabel.text = String(indexPath.item + firstHour) + ":00"
           
            return leftCell
    
        }
        else
        {
            var dayCell: TimeViewCell
            
            dayCell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifier, forIndexPath: indexPath) as! TimeViewCell
           
            switch indexPath.item
            {
            case 0:
                dayCell.textLabel.text = "M"
            case 1,3:
                dayCell.textLabel.text = "T"
            case 2:
                dayCell.textLabel.text = "W"
            case 4:
                dayCell.textLabel.text = "F"
            default:
                dayCell.textLabel.text = "Error"
            }
            
            return dayCell
        }
    }
    
    
// MARK: Funções opcionais do protocolo collection view delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if( collectionView == mainCollectionView)
        {
            var cell = collectionView.cellForItemAtIndexPath(indexPath)
            
            grade[indexPath.item]++
            if( grade[indexPath.item] > 2 )
            {
                grade[indexPath.item] = 0
            }
            
            switch grade[indexPath.item]
            {
            case 0:
                cell?.backgroundColor = UIColor(red: 0.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            case 1:
                cell?.backgroundColor = UIColor.redColor()
            case 2:
                cell?.backgroundColor = UIColor.orangeColor()
            default:
                cell?.backgroundColor = UIColor.blackColor()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
    {
        if( collectionView == mainCollectionView)
        {
            var cell = collectionView.cellForItemAtIndexPath(indexPath)
            
            grade[indexPath.item]++
            if( grade[indexPath.item] > 2 )
            {
                grade[indexPath.item] = 0
            }
            
            switch grade[indexPath.item]
            {
            case 0:
                cell?.backgroundColor = UIColor(red: 0.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            case 1:
                cell?.backgroundColor = UIColor.redColor()
            case 2:
                cell?.backgroundColor = UIColor.orangeColor()
            default:
                cell?.backgroundColor = UIColor.blackColor()
            }
        }
    }
    
// MARK: Funções do delegate de scroll das duas collection views
    /* Faz as duas collections moverem em conjunto */
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if( scrollView == mainCollectionView && scrollingView == mainCollectionView )
        {
            var offset = timeCollectionView.contentOffset
            offset.y = mainCollectionView.contentOffset.y
            timeCollectionView.setContentOffset(offset, animated: false)
        }
        else if( scrollView == timeCollectionView && scrollingView == timeCollectionView  )
        {
            var offset = mainCollectionView.contentOffset
            offset.y = timeCollectionView.contentOffset.y
            mainCollectionView.setContentOffset(offset, animated: false)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        scrollingView = scrollView
    }

// MARK: Funões do collection view delegate flow layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        switch collectionView
        {
        case mainCollectionView:
            return UIEdgeInsetsMake(0, 5, 10, 10)
        case timeCollectionView:
            return UIEdgeInsetsMake(0, 5, 0, 0)
        case daysCollectionView:
            return UIEdgeInsetsMake(0, 5, 0, 10)
        default:
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        var lado:CGFloat = (mainCollectionView.bounds.width - 60)/5
        
        switch collectionView
        {
        case daysCollectionView:
            var size:CGSize = CGSizeMake(lado, daysCollectionView.bounds.height)
            return size
        case timeCollectionView:
            var size:CGSize = CGSizeMake(lado + 4, lado)
            return size
        default:
            var size:CGSize = CGSizeMake(lado, lado)
            return size
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 10.0
    }
    
    private func prepareScheduleToSave(grid:[Int]) -> [Time]{
        var timeList = scheduleService.createDefaultSchedule()
        
        for var i = 0; i < timeList.count; i++ {
            if grid[i] == freeTimeIndex {
                timeList[i].setBusy(false)
                timeList[i].setOptional(false)
            } else if grid[i] == busyTimeIndex {
                timeList[i].setBusy(true)
                timeList[i].setOptional(false)
            } else if grid[i] == optionalTimeIndex{
                timeList[i].setBusy(false)
                timeList[i].setOptional(true)
            }
        }
        return timeList
    }
    
    private func getMyScheduleIndex(timeList:[Time]) ->[Int]{
        var arrayIndex = [Int]()
        
        for time in timeList{
            if time.isBusy() {
                arrayIndex.append(busyTimeIndex)
            } else if time.isOptional() {
                arrayIndex.append(optionalTimeIndex)
            } else {
                arrayIndex.append(freeTimeIndex)
            }
        }
        return arrayIndex
    }
}
