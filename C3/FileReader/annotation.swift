//
//  annotation.swift
//  C3
//
//  Created by 黄磊 on 2020/10/28.
//

import Foundation

class AnoReader{

    
//    var currentNTs=[NeuronTree]()
    static func read(anofile:String)->([NeuronTree],[MarkerList])?{
        var apoList=[String]()
        var swcList=[String]()
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = URL(fileURLWithPath: anofile,relativeTo: directoryURL)
//            let fileHandle=FileHandle(forReadingFrom: fileURL)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let filePointer=fopen(fileURL.path, "r")
        else {
            return nil
        }
        
        var lineByteArrayPointer:UnsafeMutablePointer<CChar>? = nil
        var lineCap:Int=0//指针所指内存的大小，0:系统自动
        let bytesRead=getline(&lineByteArrayPointer, &lineCap, filePointer)
        defer {
            fclose(filePointer)
        }
        
        while bytesRead>0 {
            var line:String=String.init(cString: lineByteArrayPointer!)
            line=line.trimmingCharacters(in: ["\n"])
            if line.starts(with: "#"){
                continue
            }
            let list=line.split(separator: "=")
            if list.count != 2{
                return nil
            }
            switch String(list[0]) {
            case String("ANOFILE"):apoList.append(String(list[1]))
            case String("SWCFILE"):swcList.append(String(list[1]))
            default:
                continue
            }
        }
        var ntList=[NeuronTree]()
        var markers=[MarkerList]()
        for file in swcList{
            ntList.append(NeuronTree.readSWC(swcfile: file))
        }
        
        for file in apoList{
            markers.append(MarkerList.readApo(apoFile: file))
        }
        
        return (ntList,markers)
        
    }
}
