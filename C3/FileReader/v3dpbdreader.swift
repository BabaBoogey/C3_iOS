//
//  v3dpbdreader.swift
//  C3
//
//  Created by 黄磊 on 2020/10/29.
//

import Foundation
func loadPBD(filename:String,image:Image4DSimple){
    image.finalize()
    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = URL(fileURLWithPath: filename,relativeTo: directoryURL)
//            let fileHandle=FileHandle(forReadingFrom: fileURL)
    do
    {
        let fileHandle=try FileHandle(forReadingFrom: fileURL)
        let fileSize=try fileHandle.seekToEnd()
        try fileHandle.seek(toOffset: 0)
        
        let formatkey:String="v3d_volume_pktbitdf_encod"
        let lenkey=formatkey.count
        
        if fileSize < 2+4+4+1{
            print("file size is to small")
            return
        }
        var keydata=fileHandle.readData(ofLength: lenkey)
        if String(data: keydata, encoding: String.Encoding.utf8) != formatkey{
            return
        }
//        var result=Image4DSimple()
        
        keydata=fileHandle.readData(ofLength: 1)
        if String(data: keydata, encoding: String.Encoding.utf8) != "B"
            || String(data: keydata, encoding: String.Encoding.utf8) != "L"{
            return
        }
        
        func checkMachineEndian()->String{
            var e="N"
            
            let a:Int32=0x44332211
            if (a && 0xff) == 0x11 {
                e= 
            }
        }
            
            
        
    }catch
    {
        return
    }
    
////    guard FileManager.default.fileExists(atPath: fileURL.path),
////          let filePointer=fopen(fileURL.path, "r")
////    else {
////        print("not find \(filename)")
////        return
////    }
//
//    var lineByteArrayPointer:UnsafeMutablePointer<CChar>? = nil
//    var lineCap:Int=0//指针所指内存的大小，0:系统自动
//    var bytesRead=getline(&lineByteArrayPointer, &lineCap, filePointer)
//
//    //cac file size
//    fseek(filePointer, 0, SEEK_END)
//    let fileSize=ftell(filePointer)
//    print("filesize = \(fileSize)")
//    rewind(filePointer)
//
//
//    // read data
//    var decompressionPrior = 0
//    var berror = 0
//
//
    

    
    
}
