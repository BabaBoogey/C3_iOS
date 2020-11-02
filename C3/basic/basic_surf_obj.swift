//
//  basic_surf_obj.swift
//  C3
//
//  Created by 黄磊 on 2020/10/26.
//

import Foundation

class BasicSurfObj{
    var n:Int=0;
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
    var pn:Int=0
    var level:Int = -1
    var fea_val:[Float]=[Float]()
    var seg_id:Int=0
    var nodeinseg_id:Int=0
    var createmode:Int=0
    var timestamp:Int=0
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
    
    func write_SWC(swcfile:String) -> Bool {
        print("point num = \(self.listNeuron.count) ,save swc file to \(swcfile)")
        
        do{
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = URL(fileURLWithPath: swcfile,relativeTo: directoryURL)
            if FileManager.default.fileExists(atPath: fileURL.absoluteString)
            {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            let name=String("#name \(self.name)\n")
            let comment=String("#comment \(self.comment)\n")
            let title=String("##n,type,x,y,z,radius,parent\n")
            
            let fileHandle=try FileHandle(forWritingTo: fileURL)
            fileHandle.write(name.data(using: .utf8)!)
            fileHandle.write(comment.data(using: .utf8)!)
            fileHandle.write(title.data(using: .utf8)!)
            
            for (index,node) in self.listNeuron.enumerated(){
                var data=String("\(node.n) \(node.type) \(node.x) \(node.y) \(node.z) \(node.radius) \(node.pn)")
                if(index != self.listNeuron.count-1){
                    data += "\n"
                    fileHandle.write(data.data(using: .utf8)!)
                }
            }
            return true
        }catch
        {
            return false
        }
    }
    
    static func readSWC(swcfile:String)->NeuronTree{
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: swcfile,relativeTo: directoryURL)
//            let fileHandle=FileHandle(forReadingFrom: fileURL)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let filePointer=fopen(fileURL.path, "r")
        else {
            return NeuronTree()
        }
        
        var lineByteArrayPointer:UnsafeMutablePointer<CChar>? = nil
        var lineCap:Int=0//指针所指内存的大小，0:系统自动
        var bytesRead=getline(&lineByteArrayPointer, &lineCap, filePointer)
        defer {
            fclose(filePointer)
        }
        let nt=NeuronTree()
        while bytesRead>0 {
            let line=String.init(cString: lineByteArrayPointer!)
            if !(line.starts(with: "#")) || (!line.isEmpty){
                let list=line.trimmingCharacters(in: ["\n"]).split(separator: " ")
                if list.count < 7{
                    return NeuronTree()
                }
                let node:NeuronSWC=NeuronSWC()
                for (i,ss) in list.enumerated(){
                    
                    let s=String(ss)
                    switch i {
                    case 0:
                        guard let value=Int(s) else {
                            return NeuronTree()
                        }
                        node.n=value
                    case 1:
                        guard let value=Int(s) else {
                            return NeuronTree()
                        }
                        node.type=value
                    case 2:
                        guard let value=Float(s) else {
                            return NeuronTree()
                        }
                        node.x=value
                    case 3:
                        guard let value=Float(s) else {
                            return NeuronTree()
                        }
                        node.y=value
                    case 4:
                        guard let value=Float(s) else {
                            return NeuronTree()
                        }
                        node.z=value
                    case 5:
                        guard let value=Float(s) else {
                            return NeuronTree()
                        }
                        node.radius=value
                    case 6:
                        guard let value=Int(s) else {
                            return NeuronTree()
                        }
                        node.pn=value
                    default:
                        return NeuronTree()
                    }
                }
                nt.listNeuron.append(node)
                nt.hashNeuron[node.n]=nt.listNeuron.count-1
                
            }
            bytesRead=getline(&lineByteArrayPointer, &lineCap, filePointer)
        }
        nt.n=1
        nt.color=RGBA8(r: 0, g: 0, b: 0, a: 0)
        nt.on=true
        nt.name=swcfile
        
        
        return nt
    }
    
    func to_V_NeuronSWC_List()->V_NeuronSWC_list{
        let seg=V_NeuronSWC()
        for node in self.listNeuron{
            let unit:V_Neuron_unit=V_Neuron_unit()
            unit.n=node.n
            unit.type=node.type
            unit.x=Double(node.x)
            unit.y=Double(node.y)
            unit.z=Double(node.z)
            unit.r=Double(node.radius)
            unit.pn=node.pn
            unit.level=Double(node.level)
            unit.createmode=Double(node.createmode)
            unit.timestamp=Double(node.timestamp)
            unit.tfresindex=node.tfresindex
            seg.row.append(unit)
        }
        let segs=seg.decompose()
        segs.name=name
        segs.file=file
        segs.b_traced=false
        segs.color_uc=[color.r,color.g,color.b,color.a]
        return segs
    }
    
    
}
