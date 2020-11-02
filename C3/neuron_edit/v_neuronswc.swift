//
//  v_neuronswc.swift
//  C3
//
//  Created by 黄磊 on 2020/10/28.
//

import Foundation

class V_NeuronSWC_coord {
    var x=0.0
    var y=0.0
    var z=0.0
    
    func equal(other:V_NeuronSWC_coord) -> Bool {
        return x==other.x && y==other.y && z==other.z
    }
    
    func equal(x:Double = 0.0,y:Double = 0.0,z:Double = 0.0)->Bool{
        return self.x==x && self.y==y && self.z==z
    }
    
    init(x:Double,y:Double,z:Double) {
        self.x=x
        self.y=y
        self.z=z
    }
}

class V_Neuron_unit:NSCopying  {
    func copy(with zone: NSZone? = nil) -> Any {
        let unit=V_Neuron_unit()
        unit.n=n
        unit.type=type
        unit.x=x
        unit.y=y
        unit.z=z
        unit.r=r;unit.pn=pn;unit.nchild=nchild;unit.seg_id=seg_id;unit.nodeinseg_id=nodeinseg_id;
        unit.level=level;unit.createmode=createmode;unit.timestamp=timestamp;unit.tfresindex=tfresindex
        return unit
    }
    
    var x,y,z,r,level,createmode,timestamp,tfresindex:Double
    var n,type,pn,nchild,seg_id,nodeinseg_id:Int
    init() {
        n=0;type=0;x=0;y=0;z=0;r=0.5;pn=0;nchild=0;seg_id=0;nodeinseg_id=0;level=0;createmode=0;timestamp=0;tfresindex=0
    }
    
    func getcoord()->V_NeuronSWC_coord{
        let c=V_NeuronSWC_coord(x: 0, y: 0, z: 0)
        c.x=x;
        c.y=y
        c.z=z
        return c
    }
    
    func set(x:Double,y:Double,z:Double,r:Double,p:Int,t:Int){
        self.x=x;self.y=y;self.z=z;self.r=r;self.pn=p;self.type=t
    }
    func seyType(type:Int){
        self.type=type
    }
    
    
}

class V_NeuronSWC {
    class Node_Link {
        var i:Int=0
        var inlink:[Int]=[Int]()
        var outlink:[Int]=[Int]()
        var nLink:Int=0
    }
    typealias Link_Map = [Int:Node_Link]
    var row=[V_Neuron_unit]()
    var b_linegraph=false
    var name:String="unset"
    var comment:String=""
    var file:String=""
    var color_uc=[UInt8]()
    var b_jointed=false
    var to_be_deleted=false
    var to_be_broken=false
    var on=false
    
    func getIndexofParent(j:Int)->Int{
        let pn=self.row[j].pn
        for (index,unit) in row.enumerated(){
            if unit.n == pn
            {
                return index
            }
        }
        return -1
    }
    func to_NeuronTree()->NeuronTree{
        let SS:NeuronTree=NeuronTree()
        for unit in row{
            let S:NeuronSWC=NeuronSWC()
            S.n=unit.n
            S.type=unit.type
            S.x=Float(unit.x)
            S.y=Float(unit.y)
            S.z=Float(unit.z)
            S.radius=Float(unit.r)
            S.pn=unit.pn
            
            S.seg_id=unit.seg_id
            S.nodeinseg_id=unit.nodeinseg_id
            S.level=Int(unit.level)
            S.createmode=Int(unit.createmode)
            S.timestamp=Int(unit.timestamp)
            S.tfresindex=unit.tfresindex
            SS.listNeuron.append(S)
            SS.hashNeuron[S.n]=SS.listNeuron.count-1
        }
        SS.n = -1
        SS.color.r=self.color_uc[0]
        SS.color.g=self.color_uc[1]
        SS.color.b=self.color_uc[2]
        SS.color.a=self.color_uc[3]
        SS.on=true
        SS.name=self.name
        SS.file=self.file
        
        return SS
    }
    
    func getLink_map()->Link_Map{
        var linkMap:Link_Map=Link_Map()
        for (index,_) in self.row.enumerated(){
            let nid=self.row[index].n
            let nl:Node_Link=Node_Link()
            nl.i=index;
            nl.nLink=0
            linkMap[nid]=nl
        }
        for (index,_) in self.row.enumerated(){
            let n=self.row[index].n
            let pn=self.row[index].pn
            
            if pn>=0{
                let nl=linkMap[n]
                nl?.outlink.append(pn)
                nl?.nLink+=1
                let pnl=linkMap[pn]
                pnl?.inlink.append(n)
                pnl?.nLink+=1
                
            }else{
                var singleNode=true
                for node in self.row{
                    if node.pn==n{
                        singleNode=false
                    }
                }
                if singleNode{
                    let nl=linkMap[n]
                    nl?.outlink.append(n)
                    nl?.nLink+=1
                }
            }
        }
        return linkMap
    }
    
    func decompose()->V_NeuronSWC_list{
//        let segs=V_NeuronSWC_list()
        let linkMap=getLink_map()
        var outSwcSegs=[V_NeuronSWC]()
        var indices:[Int]=[Int]()
        for (index,node) in self.row.enumerated(){
            let nodeLink=linkMap[node.n]
            node.nchild=nodeLink!.nLink
            indices.append(index)
        }
        
        var halted=false
        
        while true {
            if indices.isEmpty {break;}
            var istart = -1
            var n_left=0
            var i_left = -1
            
            for (index,_) in indices.enumerated(){
                if halted{
                    halted=false
                    continue
                }
                
                let cur_node=self.row[indices[index]]
                let nodeLink=linkMap[cur_node.n]!
                n_left+=1
                i_left=indices[index]
                
                if nodeLink.nLink==1 && nodeLink.inlink.count==0
                    || nodeLink.nLink>2 && nodeLink.outlink.count>0
                    || nodeLink.nLink==2 && nodeLink.inlink.count==0{
                    istart=indices[index]
                    break;
                }
            }
            
            if istart<0{
                if n_left != 0{
                    istart=i_left
                    continue
                }else{
                    break
                }
            }
            
            let new_seg=V_NeuronSWC()
            var inext=istart
            var n=1
            while inext>=0 {
                let cur_node=row[inext]
                let nodeLink=linkMap[cur_node.n]!
                let newNode:V_Neuron_unit=cur_node.copy() as! V_Neuron_unit
                newNode.n=n
                newNode.pn=n+1
                new_seg.row.append(newNode)
                
                if cur_node.pn<0{
                    cur_node.nchild-=1
                    if(cur_node.nchild == 0){
                        indices.removeAll(where: {$0==inext})
                        break;
                    }else if(cur_node.nchild < 0){
                        break;
                    }
                }else if( n>1&&nodeLink.nLink>2){
                    cur_node.nchild-=1
                    if cur_node.nchild==0{
                        indices.removeAll(where: {$0==inext})
                    }else if(cur_node.nchild<0){
                        break;
                    }else{
                        halted=true
                        break
                    }
                }else if(n>1&&inext==istart){
                    cur_node.nchild-=1
                    if(cur_node.nchild==0){
                        indices.removeAll(where: {$0==inext})
                        break;
                    }else if(cur_node.nchild<0){
                        break
                    }
                }else{
                    cur_node.nchild = -1
                    indices.removeAll(where: {$0==inext})
                    let pn=cur_node.pn
                    inext=linkMap[pn]!.i
                }
            }
            if new_seg.row.count > 0{
                new_seg.row[new_seg.row.count-1].pn = -1
                new_seg.name=String("\(outSwcSegs.count + 1)")
                new_seg.b_linegraph=true
                outSwcSegs.append(new_seg)
            }
            n+=1
        }
        let segs=V_NeuronSWC_list()
        segs.seg=outSwcSegs
        return segs
    }
    
}

class V_NeuronSWC_list{
    var seg=[V_NeuronSWC]()
    var name:String=""
    var comment:String=""
    var file:String=""
    var color_uc:[UInt8]=[UInt8]()
    var b_traced:Bool=false
    
    func nsegs() -> Int {
        return seg.count
    }
    
    func append(new_seg:V_NeuronSWC){
        seg.append(new_seg)
    }
    
    func append(new_segs:[V_NeuronSWC]){
        seg+=new_segs
    }
    
    func clear(){
        seg=[V_NeuronSWC]()
    }
    
    func merge()->V_NeuronSWC{
        let out_swc:V_NeuronSWC=V_NeuronSWC()
        var n=0
        
        for (i,segment) in seg.enumerated(){
            if segment.to_be_deleted{
                continue
            }
            
            if !(segment.on){
                continue
            }
            
            if(segment.row.count<=0){
                continue
            }
            
            var min_ind=segment.row[0].n
            for unit in segment.row{
                if unit.n < min_ind{
                    min_ind=unit.n
                }
            }
            if min_ind<=0{
                print("error:illegal neuron node index in V_neuronSWC_list merge ")
                return V_NeuronSWC()
            }
            
            let seg_id=i;
            let n0=n
            for j in 0..<segment.row.count{
                let v=V_Neuron_unit()
                v.seg_id=seg_id
                v.nodeinseg_id=j
                v.level=segment.row[j].level
                v.createmode=segment.row[j].createmode
                v.timestamp=segment.row[j].timestamp
                v.tfresindex=segment.row[j].tfresindex
                v.n=(n0+1)+segment.row[j].n-min_ind
                v.type=segment.row[j].type
                v.x=segment.row[j].x
                v.y=segment.row[j].y
                v.z=segment.row[j].z
                v.pn = (segment.row[j].pn<0) ? -1:(n0+1)+segment.row[j].pn-min_ind
                out_swc.row.append(v)
                n += 1
            }
        }
        out_swc.color_uc=self.color_uc
        return out_swc
    }
    
    func delete_segment(seg_id:Int){
        if seg_id>=0 && seg_id < self.seg.count{
            self.seg.remove(at: seg_id)
        }
    }
    
    func to_NeuronTree()->NeuronTree{
        let segment=merge()
        segment.name=name
        segment.file=file
        return segment.to_NeuronTree()
    }
}

