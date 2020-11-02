//
//  ViewController.swift
//  C3
//
//  Created by 黄磊 on 2020/10/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let btn=UIButton()
        btn.frame=CGRect(x: 80, y: 50, width: 140, height: 30)
        btn.setTitle("push", for: .normal)
//        btn.setBackgrou, for: <#T##UIControl.State#>)
        btn.backgroundColor=UIColor.black
        btn.addTarget(self, action: #selector(self.btntraped(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(btn)
        // Do any additional setup after loading the view.
    }

    @objc func btntraped(_ btn:UIButton)  {
        print("touched")
        let nt=NeuronTree()
        nt.write_SWC(swcfile: "test")
    }
}

