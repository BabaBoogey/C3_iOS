//
//  ByteTranslate.swift
//  C3
//
//  Created by 黄磊 on 2020/10/28.
//

import Foundation

func byte1ToUInt32(b:UInt8) -> UInt32 {
    return UInt32(b&0xff)
}

func byte2ToUInt32(b:[UInt8],isBig:Bool)->UInt32{
    var ret:UInt32=0
    let mb:[UInt8]!
    if !isBig{
        mb=b.reversed()
    }else{
        mb=b
    }
    
    for v in mb{
        ret = ret*256+UInt32(v)
    }
    return ret
}

func byte2ToShort(b:[UInt8],isBig:Bool)->UInt16{
    var ret:UInt16=0
    let mb:[UInt8]!
    if !isBig{
        mb=b.reversed()
    }else{
        mb=b
    }
    
    for v in mb{
        ret = ret*256+UInt16(v)
    }
    return ret
}

func uint32ToBytes(b:UInt32)->[UInt8]{
    var result:[UInt8]=[UInt8]()
    result[0]=UInt8((b>>24)&0xFF)
    result[1]=UInt8((b>>16)&0xFF)
    result[2]=UInt8((b>>8)&0xFF)
    result[3]=UInt8((b>>0)&0xFF)
    return result
}
