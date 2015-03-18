//
//  ScheduleViewController.swift
//  MPCRevisited
//
//  Created by Luan Barbalho Kalume on 16/03/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit

/* Identificador da célula protótipo */
var reusableIdentifier = "cell"

/* Array da agenda do usuário */
var grade = [Int]()

let scheduleService = ScheduleService()

/* Subclasse de uma célula que é usada na collection lateral
existe apenas para poder relacionar o seu label com o código
*/
class TimeViewCell: UICollectionViewCell
{
    /* Label da célula */
    @IBOutlet weak var textLabel: UILabel!
    
}

class ScheduleViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    /* Salva qual collection view está sendo arrastada */
    var scrollingView: UIScrollView!
    
    /* Referência ao botão de editar */
    @IBOutlet weak var editButton: UIButton!
    
    /* Referência às collection views da tela */
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var timeCollectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        var x = 0;
        
        /* Define essa view como o delegate das collection views */
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        timeCollectionView.delegate = self
        timeCollectionView.dataSource = self
        
        /* Permite multiplas seleções na collection view */
        mainCollectionView.allowsMultipleSelection = true
        /* Desliga a permição de seleção na collection view */
        mainCollectionView.allowsSelection = false
        
        /* Desliga a exibição da barra de rolagem lateral na collection de horas */
        timeCollectionView.showsVerticalScrollIndicator = false
        
        var mySchedules = scheduleService.getMySchedule()
        for schedule in mySchedules{
            grade.append(schedule)
        }
        
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Função de ação de toque no botão Editar */
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
            editButton.setTitle("Editar", forState: nil)
            mainCollectionView.allowsSelection = false
            scheduleService.saveMySchedule(grade)
        }
        
    }
    
    
// MARK: FUNÇÕES OBRIGATÓRIAS DO PROTOCOLO DATASOURCE
    
    /* Retorna o número de células exibidas nas collections views */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if( collectionView == mainCollectionView)
        {
            return 75
        }
        else
        {
            return 15
        }
    }

    /* Função que cria as células nas collection views */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        /* Pega uma célula reutiluzável */
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        /* Caso for uma célula da collection de seleção */
        if( collectionView == mainCollectionView)
        {
            /* Se o horário estiver livre */
            if( grade[indexPath.item] == 0 )
            {
                cell.backgroundColor = UIColor(red: 0.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            }
            else if( grade[indexPath.item] == 1 )
            {
                cell.backgroundColor = UIColor.redColor()
            }
            else
            {
                cell.backgroundColor = UIColor.orangeColor()
            }
        }
        else
        {
            /* Caso for uma célula da collection de horários */
            var leftCell: TimeViewCell
            
            leftCell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifier, forIndexPath: indexPath) as TimeViewCell
            
            leftCell.frame.size.width = 50
            leftCell.textLabel.text = String(indexPath.item + 7) + ":00"
            
            return leftCell
    
        }
        
        return cell
    }
    
    
// MARK: FUNÇÕES OPCIONAIS DO PROTOCOLO COLLECTION VIEW DELEGATE
    
    /* Muda a cor da célula selecionada para vermelho se for da main collection */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if( collectionView == mainCollectionView)
        {
            /* Célula selecionada */
            var cell = collectionView.cellForItemAtIndexPath(indexPath)
            grade[indexPath.item]++
            
            if( grade[indexPath.item] > 2 )
            {
                grade[indexPath.item] = 0
            }
            
            if( grade[indexPath.item] == 0 )
            {
                cell?.backgroundColor = UIColor(red: 0.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            }
            else if( grade[indexPath.item] == 1 )
            {
                cell?.backgroundColor = UIColor.redColor()
            }
            else
            {
                cell?.backgroundColor = UIColor.orangeColor()
            }
        }
        
    }
    
    /* Muda a cor da célula descelecionada para verde se for da main collection */
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
    {
        if( collectionView == mainCollectionView)
        {
            /* Célula selecionada */
            var cell = collectionView.cellForItemAtIndexPath(indexPath)
            grade[indexPath.item]++
            
            if( grade[indexPath.item] > 2 )
            {
                grade[indexPath.item] = 0
            }
            
            if( grade[indexPath.item] == 0 )
            {
                cell?.backgroundColor = UIColor(red: 0.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            }
            else if( grade[indexPath.item] == 1 )
            {
                cell?.backgroundColor = UIColor.redColor()
            }
            else
            {
                cell?.backgroundColor = UIColor.orangeColor()
            }
        }
    }
    
// MARK: FUNÇÕES DO DELEGATE DE SCROLL DAS DUAS COLLECTIONS
    
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


}
