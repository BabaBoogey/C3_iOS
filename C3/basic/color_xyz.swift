//
//  basic_surf_obj.swift
//  C3
//
//  Created by 黄磊 on 2020/10/26.
//

import Foundation


class RGB8
{
    var r,g,b:UInt8;
    init(px:UInt8=0,py:UInt8=0,pz:UInt8=0) {
        r=px
        g=py
        b=pz
    }
    
}

class RGBA8 {
    var r,g,b,a:UInt8;
    init(r:UInt8=0,g:UInt8=0,b:UInt8=0,a:UInt8=0) {
        self.r=r;self.g=g;self.b=b;self.a=a;
    }
    
}

class RGB16i {
    var r,g,b,a:UInt16;
    init(r:UInt16=0,g:UInt16=0,b:UInt16=0,a:UInt16=0) {
        self.r=r;self.g=g;self.b=b;self.a=a;
    }
    
}

class RGB32i {
    var r,g,b,a:UInt32;
    init(r:UInt32=0,g:UInt32=0,b:UInt32=0,a:UInt32=0) {
        self.r=r;self.g=g;self.b=b;self.a=a;
    }
    
}
class RGB32f {
    var r,g,b,a:Float32;
    init(r:Float32=0,g:Float32=0,b:Float32=0,a:Float32=0) {
        self.r=r;self.g=g;self.b=b;self.a=a;
    }
    
}

class XYZ {
    var x,y,z:Float32
    init(px:Float32=0,py:Float32=0,pz:Float32=0) {
        x=px;y=py;z=pz;
    }
    init(a:Float32) {
        x=a;y=a;z=a;
    }
    init(c:RGB8) {
        x=Float32(c.r);y=Float32(c.g);z=Float32(c.b);
    }
    init(c:RGB16i) {
        x=Float32(c.r);y=Float32(c.g);z=Float32(c.b);
    }
    init(c:RGB32i) {
        x=Float32(c.r);y=Float32(c.g);z=Float32(c.b);
    }
    init(c:RGB32f) {
        x=Float32(c.r);y=Float32(c.g);z=Float32(c.b);
    }
    
    static func norm(a:XYZ)->Float32{
        return Float32(sqrt(a.x*a.x+a.y*a.y+a.z*a.z))
        
    }
    
    static func normalize(a:XYZ)->XYZ{
        let d=norm(a: a)
        return XYZ(px:a.x/d,py:a.y/d,pz:a.z/d)
    }
}

extension RGB8{
    convenience init(a:XYZ){
        self.init(px:UInt8(a.x),py:UInt8(a.y),pz:UInt8(a.z))
    }
}

extension RGB8{
    static func random_rgb8()->RGB8{
        var d=XYZ()
        d.x=Float32(arc4random_uniform(256))
        d.y=Float32(arc4random_uniform(256))
        d.z=Float32(arc4random_uniform(256))
        d=XYZ.normalize(a: d)
        let c=RGB8()
        c.r=UInt8(d.x*255)
        c.g=UInt8(d.y*255)
        c.b=UInt8(d.z*255)
        return c
    }
}
extension RGBA8{
    static func random_rgba8()->RGBA8{
        let c=RGB8.random_rgb8()
        let cc:RGBA8=RGBA8(r:UInt8(c.r),g:UInt8(c.g),b:UInt8(c.b),a:UInt8(arc4random_uniform(256)))
        return cc
    }
}
extension RGB16i{
    convenience init(a:XYZ){
        self.init(r:UInt16(a.x),g:UInt16(a.y),b:UInt16(a.z))
    }
}

extension RGB32i{
    convenience init(a:XYZ){
        self.init(r:UInt32(a.x),g:UInt32(a.y),b:UInt32(a.z))
    }
}

extension RGB32f{
    convenience init(a:XYZ){
        self.init(r:Float32(a.x),g:Float32(a.y),b:Float32(a.z))
    }
}
