//
//  basic_surf_obj.swift
//  C3
//
//  Created by 黄磊 on 2020/10/26.
//

import Foundation

class BasicSurfObj{
    var n:Int64=0;
    var color:RGBA8=RGBA8(r:255,g:255,b:255,a: 255)
    var on:Bool=true
    var selected:Bool=false
    var name:String=""
    var comment:String=""
}

class NeuronSWC: BasicSurfObj {
    var type:Int=0
    var x:Float=0
    var y:Float=0
    var z:Float=0
    var radius:Float=0
    var pn:Int64=0
    var level:Int64 = -1
    var fea_val:[Float]=[Float]()
    var seg_id:Int64=0
    var nodeinseg_id:Int64=0
    var createmode:Int64=0
    var timestamp:Int64=0
    var tfresindex:Double=0
    
    
}

class NeuronTree: BasicSurfObj {
    var listNeuron:[NeuronSWC] = [NeuronSWC]()
    var hashNeuron:[Int:Int] = [Int:Int]()
    var file:String = ""
    var editable:Bool=false
    var linemode:Int = -1
    
    func deepCopy(p:NeuronTree){
        n=p.n
        color.r=p.color.r
        color.g=p.color.g
        color.b=p.color.b
        on=p.on
        selected=p.selected
        name=p.name
        comment=p.comment
        
        listNeuron=[NeuronSWC]()
        hashNeuron=[Int:Int]()
        
        for node in p.listNeuron{
            let S=NeuronSWC()
            S.n=node.n
            S.type=node.type
            S.x=node.x
            S.y=node.y
            S.z=node.z
            S.radius=node.radius
            S.pn=node.pn
            S.level=node.level
            S.seg_id=node.seg_id
            S.createmode=node.createmode
            S.timestamp=node.timestamp
            S.tfresindex=node.tfresindex
            S.fea_val=node.fea_val
            listNeuron.append(S)
            hashNeuron.updateValue(Int(S.n), forKey: listNeuron.count-1)
        }
    }
    
    func copy(p:NeuronTree){
        n=p.n
        color.r=p.color.r
        color.g=p.color.g
        color.b=p.color.b
        on=p.on
        selected=p.selected
        name=p.name
        comment=p.comment
        
        listNeuron=p.listNeuron
        hashNeuron=p.hashNeuron
    }
    
    func copyGeometry(p:NeuronTree){
        if(listNeuron.count != p.listNeuron.count){
            return;
        }
        for i in 0..<listNeuron.count{
            let node=listNeuron[i]
            node.x=p.listNeuron[i].x
            node.y=p.listNeuron[i].y
            node.z=p.listNeuron[i].z
            node.radius=p.listNeuron[i].radius
            node.createmode=p.listNeuron[i].createmode
            node.timestamp=p.listNeuron[i].timestamp
            node.tfresindex=p.listNeuron[i].tfresindex
        }
    }
    
    func projection(axiscode:Int=3){
        for i in 0..<listNeuron.count{
            let node=listNeuron[i]
            switch axiscode {
            case 0:node.x=0
            case 1:node.y=0
            case 2:node.z=0
            case 3:node.radius=0.5
            default:
                return
            }
        }
    }
    
}
