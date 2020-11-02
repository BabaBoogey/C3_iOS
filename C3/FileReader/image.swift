//
//  Imagimage.swift
//  C3
//
//  Created by 黄磊 on 2020/10/28.
//

import Foundation
class Image4DSimple{
    enum ImagePixel:Int {
        case V3D_UNKNOWN=0
        case V3D_UINT8=1
        case V3D_UINT16=2
        case V3D_THREEBYTE=3
        case V3D_FLOAT32=4
    }
    enum TimePackType {
        case TIME_PACK_NONE,TIME_PACK_Z,TIME_PACK_C
    }
    
    var sz0,sz1,sz2,sz3,sz_time:Int  //channel,z,x,y
    var datatype:ImagePixel
    var timepacktype:TimePackType
    var isBig:Bool
    var imgSrcFile:String
    var b_error:Int
    var res_x,res_y,res_z:Int
    var origin_x,origin_y,origin_z:Int
    var valid_zslcenum:Int
    var prevaild_zslice_num:Int
    
    var data:[UInt8]?
    
    init() {
        sz0=0;sz1=0;sz2=0;sz3=0;
        sz_time=0
        datatype = .V3D_UNKNOWN;timepacktype = .TIME_PACK_NONE
        isBig=false
        imgSrcFile=""
        b_error=0
        res_x=0;res_y=0;res_z=0
        origin_x=0;origin_y=0;origin_z=0
        valid_zslcenum=0
        prevaild_zslice_num=0
        data=nil
    }
    
    func finalize(){
        sz0=0;sz1=0;sz2=0;sz3=0;
        sz_time=0
        datatype = .V3D_UNKNOWN;timepacktype = .TIME_PACK_NONE
        isBig=false
        imgSrcFile=""
        b_error=0
        res_x=0;res_y=0;res_z=0
        origin_x=0;origin_y=0;origin_z=0
        valid_zslcenum=0
        prevaild_zslice_num=0
        data=nil
    }
    
    func getdata()->[UInt8]?{
        return data
    }
    
    func getTotalUnitNumber()->Int{
        return sz0*sz1*sz2*sz3
    }
    
    func getTotalUnitNumberPerPlane()->Int{
        return sz0*sz1
    }
    
    func getTotalUnitNumberPerChannel()->Int{
        return sz0*sz1*sz2
    }
    
    func getUnitType()->Int{
        switch datatype {
        case .V3D_UINT16: return 2
        case .V3D_FLOAT32:return 4
        default:
            return 1
        }
    }
    
    func getTotalbytes()->Int{
        return getTotalUnitNumber()*getUnitType()
    }
    
    func valid()->Bool{
        return data != nil
            && !data!.isEmpty
            && sz0>0 && sz1>0 && sz2>0 && sz3>0
            && b_error == 0
            && (datatype == .V3D_UINT8 && datatype == .V3D_UINT16 && datatype == .V3D_FLOAT32)
    }
    func setVaild_zslcenum(value:Int)->Bool{
        if value==0 && sz2==0 {
            self.valid_zslcenum=0;return true
        }
        if value>=0 && value<sz2{
            valid_zslcenum=value
            return true
        }else{
            return false
        }
    }
    
    func setPreVaild_zslcenum(value:Int)->Bool{
        if value==0 && sz2==0 {
            self.prevaild_zslice_num=0;return true
        }
        if value>=0 && value<sz2{
            prevaild_zslice_num=value
            return true
        }else{
            return false
        }
    }
    
    func setDataFromImage(data:[UInt8],sz0:Int,sz1:Int,sz2:Int,sz3:Int,dt:ImagePixel,isBig:Bool)->Bool{
        if !data.isEmpty && sz0>0 && sz1>0 && sz2>0 && sz3>0 &&
            (dt==ImagePixel.V3D_UINT8)||(dt==ImagePixel.V3D_UINT16)||(dt==ImagePixel.V3D_FLOAT32){
            if self.data != nil {
                finalize()
            }
            self.data=data
            self.sz0=sz0
            self.sz1=sz1
            self.sz2=sz2
            self.sz3=sz3
            self.datatype=dt
            self.isBig=isBig
            return true
        }else
        {
            return false
        }
    }
    
    func setDataFromImage(image:Image4DSimple){
        self.data=image.data
        self.sz0=image.sz0
        self.sz1=image.sz1
        self.sz2=image.sz2
        self.sz3=image.sz3
        self.datatype=image.datatype
        self.isBig=image.isBig
    }
    
    func getDataCXYZ()->[[[[UInt32]]]]{
        var cxyzData=[[[[UInt32]]]]()
        if data != nil
        {
                for c in 0..<sz3{
                    for k in 0..<sz2 {
                        for j in 0..<sz1 {
                            for i in 0..<sz0 {
                                if datatype == .V3D_UINT8{
                                    cxyzData[c][i][j][k]=UInt32(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i])
                                }else if(datatype == .V3D_UINT16){
                                    let b1=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i])
                                    let b2=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+1])
                                    cxyzData[c][i][j][k]=byte2ToUInt32(b: [b1,b2], isBig: isBig)
                                }else if(datatype == .V3D_FLOAT32){
                                    let b1=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i])
                                    let b2=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+1])
                                    let b3=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+2])
                                    let b4=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+3])
                                    cxyzData[c][i][j][k]=byte2ToUInt32(b: [b1,b2,b3,b4], isBig: isBig)
                                }
                            }
                        }
                    }
            }
        }
        return cxyzData
    }
    
    func getDataCZYX()->[[[[UInt32]]]]{
        var czyxData=[[[[UInt32]]]]()
        
        for c in 0..<sz3{
            for k in 0..<sz2 {
                for j in 0..<sz1 {
                    for i in 0..<sz0 {
                        if datatype == .V3D_UINT8{
                            czyxData[c][k][i][j]=UInt32(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i])
                        }else if(datatype == .V3D_UINT16){
                            let b1=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i])
                            let b2=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+1])
                            czyxData[c][k][j][i]=byte2ToUInt32(b: [b1,b2], isBig: isBig)
                        }else if(datatype == .V3D_FLOAT32){
                            let b1=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i])
                            let b2=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+1])
                            let b3=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+2])
                            let b4=(data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i+3])
                            czyxData[c][k][j][i]=byte2ToUInt32(b: [b1,b2,b3,b4], isBig: isBig)
                        }
                    }
                }
            }
        }
        return czyxData
    }
    
    func setDataFromCZYX(cxyzdata:[[[[UInt32]]]],sz0:Int,sz1:Int,sz2:Int,sz3:Int,dt:ImagePixel,isBig:Bool)->Bool{
        if !cxyzdata.isEmpty && sz0>0 && sz1>0 && sz2>0 && sz3>0 &&
            (dt == .V3D_UINT8 || dt == .V3D_UINT16 || dt == .V3D_FLOAT32){
            if data != nil{
                finalize()
            }
            data=[UInt8]()
//            var datatype = 0
//            if (dt == .V3D_UINT8)
//            {
//                datatype = 1
//            }else if(dt == .V3D_UINT16){
//                datatype = 2
//            }else if(dt == .V3D_FLOAT32){
//                datatype = 4
//            }
                
            for c in 0..<sz3{
                for k in 0..<sz2 {
                    for j in 0..<sz1 {
                        for i in 0..<sz0 {
                            let b=uint32ToBytes(b: cxyzdata[c][k][j][i])
                            if dt == .V3D_UINT8{
                                data![c*sz0*sz1*sz2+k*sz0*sz1+j*sz0+i]=b[3]
                            }else if dt == .V3D_UINT16{
                                if isBig{
                                    data![c*sz0*sz1*sz2*2+k*sz0*sz1*2+j*sz0*2+i*2+0]=b[2]
                                    data![c*sz0*sz1*sz2*2+k*sz0*sz1*2+j*sz0*2+i*2+1]=b[3]
                                }else{
                                    data![c*sz0*sz1*sz2*2+k*sz0*sz1*2+j*sz0*2+i*2+0]=b[3]
                                    data![c*sz0*sz1*sz2*2+k*sz0*sz1*2+j*sz0*2+i*2+1]=b[2]
                                }
                            }else if dt == .V3D_FLOAT32{
                                if isBig{
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+0]=b[0]
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+1]=b[1]
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+2]=b[2]
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+3]=b[3]
                                }else{
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+0]=b[3]
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+1]=b[2]
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+2]=b[1]
                                    data![c*sz0*sz1*sz2*4+k*sz0*sz1*4+j*sz0*4+i*4+3]=b[0]
                                }
                            }
                        }
                    }
                }
            }
            self.sz0=sz0;self.sz1=sz1;self.sz2=sz2;self.sz3=sz3;self.datatype=dt;self.isBig=isBig
            return true
        }else{
            return false
            
        }
    }
    
    func setDataToNil(){
        data=nil
    }
    
    func setDataUINT8(x:Int,y:Int,z:Int,c:Int,val:UInt32)->Bool{
        if datatype != .V3D_UINT8{
            return false
        }else{
            if x>=0 && x<sz0
            && y>=0 && y<sz1
            && z>=0 && z<sz2
            && c>=0 && c<sz3
            {
                data![c*sz0*sz1*sz2+z*sz0*sz1+y*sz0+x]=uint32ToBytes(b: val)[3]
                return true
            }
            return false
        }
    }
    
    func getDataUINT8(x:Int,y:Int,z:Int,c:Int)->UInt32?{
        if datatype != .V3D_UINT8{
            return nil
        }else{
            if x>=0 && x<sz0
            && y>=0 && y<sz1
            && z>=0 && z<sz2
            && c>=0 && c<sz3
            {
//                return byte1ToUInt32(b:data![c*sz0*sz1*sz2+z*sz0*sz1+y*sz0+x])
                return byte1ToUInt32(b: data![c*sz0*sz1*sz2+z*sz0*sz1+y*sz0+x])
            }
            return nil
        }
    }
    
    func setValue(x:Int,y:Int,z:Int,c:Int,val:UInt32)->Bool{
        if x>=0 && x<sz0
            && y>=0 && y<sz1
                && z>=0 && z<sz2
                    && c>=0 && c<sz3
        {
            let b=uint32ToBytes(b: val)
            var byteCnt=0
            if datatype == .V3D_UINT8{
                byteCnt=1
                data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0]=b[3]
            }else if datatype == .V3D_UINT16{
                byteCnt=2
                if isBig{
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0]=b[2]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+1]=b[3]
                }else{
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0]=b[3]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+1]=b[2]
                }
            }else if datatype == .V3D_FLOAT32{
                byteCnt=4
                if isBig{
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0]=b[0]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+1]=b[1]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+2]=b[2]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+3]=b[3]
                }else{
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0]=b[3]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+1]=b[2]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+2]=b[1]
                    data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+3]=b[0]
                }
            }else{
                return false
            }
            return true
        }
        return false
    }
    
    func getValue(x:Int,y:Int,z:Int,c:Int)->UInt32?{
        if x>=0 && x<sz0
            && y>=0 && y<sz1
                && z>=0 && z<sz2
                    && c>=0 && c<sz3
        {
            var byteCnt=0
            if datatype == .V3D_UINT8{
                byteCnt=1
                return byte1ToUInt32(b: data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0])
            }else if datatype == .V3D_UINT16{
                    
                return byte2ToUInt32(b: [data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0],
                     data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+1]],isBig: isBig)
            }else if datatype == .V3D_FLOAT32{
                byteCnt=4
                return byte2ToUInt32(b: [data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+0],
                     data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+1],
                     data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+2],
                     data![c*sz0*sz1*sz2*byteCnt+z*sz0*sz1*byteCnt+y*sz0*byteCnt+x*byteCnt+3]
                ],isBig: isBig)
            }else{
                return nil
            }
        }
        return nil
    }

    func setRes_x(x:Int)->Bool{
        if x<0{
            return false
        }else{
            self.res_x=x
            return true
        }
    }
    
    func setRes_y(y:Int)->Bool{
        if y<0{
            return false
        }else{
            self.res_y=y
            return true
        }
    }
    
    func setRes_z(z:Int)->Bool{
        if z<0{
            return false
        }else{
            self.res_z=z
            return true
        }
    }
    
    func setOrigin_x(x:Int)->Bool{
        if x<0{
            return false
        }else{
            self.origin_x=x
            return true
        }
    }
    
    func setOrigin_y(y:Int)->Bool{
        if y<0{
            return false
        }else{
            self.origin_y=y
            return true
        }
    }
    func setOrigin_y(z:Int)->Bool{
        if z<0{
            return false
        }else{
            self.origin_z=z
            return true
        }
    }
    
    static func loadImage(filename:String,filetype:String)->Image4DSimple{
        var image=Image4DSimple()
        
        if filetype == ".V3DRAW"{
            //read raw
        }else if filetype == "TIF"{
            //read tif
        }else if filetype == "V3dPBD"{
            
        }
        if image.data != nil{
            image.imgSrcFile=filename
        }
        return image
    }
    
    static func loadBigImage(filename:String,p:[Int])->Image4DSimple{
        // 等待实现
        return Image4DSimple()
    }
    
    func createImage(sz0:Int,sz1:Int,sz2:Int,sz3:Int,dt:ImagePixel)->Bool{
        if sz0<0 || sz1<0 || sz2<0 || sz3<0{
            return false
        }
        if data != nil {
            data = nil
        }
        

        data=[UInt8](repeating: 0, count: sz0*sz1*sz2*sz3*dt.rawValue)
        print("failed to allocate memory")
        
        return true
    }
    
    

}
