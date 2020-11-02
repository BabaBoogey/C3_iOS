//
//  ImageMarker.swift
//  C3
//
//  Created by 黄磊 on 2020/10/28.
//

import Foundation
class ImageMarker: BasicSurfObj ,Equatable,NSCopying{
    func copy(with zone: NSZone? = nil) -> Any {
        var res:ImageMarker=ImageMarker(x:x,y:y,z:z,t:type,s:shape,r: r)
        return res
    }
    
    static func == (lhs: ImageMarker, rhs: ImageMarker) -> Bool {
        return lhs.x==rhs.x && lhs.y==rhs.y && lhs.z==rhs.z
    }
    
    var type:Int=0
    var shape:Int=0
    var x:Double=0
    var y:Double=0
    var z:Double=0
    var r:Double=0
    
    init(x:Double,y:Double,z:Double,t:Int,s:Int,r:Double) {
        type=t
        shape=s
        self.x=x
        self.y=y
        self.z=z
        self.r=r
    }
    
    func getXYZ()->XYZ
    {
        return XYZ(px: Float32(x), py: Float32(y), pz: Float32(z))
    }

}


class MarkerList {
    var markers=[ImageMarker]()
    var count:Int
    {
        get{
            return markers.count
            }
    }
    
    init(markers:[ImageMarker]=[ImageMarker]()) {
        self.markers=markers
    }
    
    func add(marker:ImageMarker) {
         markers.append(marker)
    }
    
    func remove(marker:ImageMarker) {
        markers.removeAll(where: {$0 == marker})
    }
    
    func remove(i:Int)->ImageMarker{
        return markers.remove(at: i)
    }
    
    func get(i:Int) -> ImageMarker {
        return (markers[i].copy() as! ImageMarker)
    }
 
    func saveAsApo(apoFile:String)->Bool{
            
        do{
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = URL(fileURLWithPath: apoFile,relativeTo: directoryURL)
            if FileManager.default.fileExists(atPath: fileURL.absoluteString)
            {
                try FileManager.default.removeItem(at: fileURL)
            }

            let title=String("##n,orderInfo,name,comment,z,x,y,pixmass,intensity,sdev,volsize,mass,,,,color_r,color_g,color_b\n")
            
            let fileHandle=try FileHandle(forWritingTo: fileURL)
//            fileHandle.write(name.data(using: .utf8)!)
//            fileHandle.write(comment.data(using: .utf8)!)
            fileHandle.write(title.data(using: .utf8)!)
            
            for (index,node) in self.markers.enumerated(){
                var data=String("\(index),,,,\(node.z),\(node.x),\(node.y),,,,,,,,,\(node.color.r),\(node.color.g),\(node.color.b)")
                if(index != self.markers.count-1){
                    data += "\n"
                    fileHandle.write(data.data(using: .utf8)!)
                }
            }
            return true
            
        }catch{
            return false
        }
    }
    
    static func readApo(apoFile:String)->MarkerList{
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: apoFile,relativeTo: directoryURL)
//            let fileHandle=FileHandle(forReadingFrom: fileURL)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let filePointer=fopen(fileURL.path, "r")
        else {
            return MarkerList()
        }
        
        var lineByteArrayPointer:UnsafeMutablePointer<CChar>? = nil
        var lineCap:Int=0//指针所指内存的大小，0:系统自动
        let bytesRead=getline(&lineByteArrayPointer, &lineCap, filePointer)
        defer {
            fclose(filePointer)
        }
        
        let markers=MarkerList()
        while bytesRead>0 {
            let line=String.init(cString: lineByteArrayPointer!)
            if !(line.starts(with: "#")) || (!line.isEmpty){
                let list=line.trimmingCharacters(in: ["\n"]).split(separator: ",")
                if list.count < 3{
                    continue
                }
                let node:ImageMarker=ImageMarker(x: 0, y: 0, z: 0, t: 0, s: 0, r: 0)
                for (index,s) in list.enumerated(){
                    switch index {
                    case 0:
                        node.n=Int(s)!
                    case 4:
                        node.z=Double(s)!
                    case 5:
                        node.x=Double(s)!
                    case 6:
                        node.y=Double(s)!
                    case 15:
                        node.color.r=UInt8(s)!
                    case 16:
                        node.color.g=UInt8(s)!
                    case 17:
                        node.color.b=UInt8(s)!
                    default:
                        continue
                    }
                }
                markers.markers.append(node)
            }
        }
        return markers
    }
}
