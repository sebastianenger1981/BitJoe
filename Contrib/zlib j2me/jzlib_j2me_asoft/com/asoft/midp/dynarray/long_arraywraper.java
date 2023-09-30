//-*-java-*-
/*
Copyright (c) 2003 Asoft ltd. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in
     the documentation and/or other materials provided with the distribution.

  3. The names of the authors may not be used to endorse or promote products
     derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ASOFT
LTD. OR ANY CONTRIBUTORS TO THIS SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/*                                                                             
*Copyright (c) 2003 Asoft ltd. All rights reserved.                            
*www.asoft.ru                                                                  
*Authors: Alexandre Rusev, Alexey Soloviev                                     
*/
package com.asoft.midp.dynarray;

import java.util.Vector;

/**Этот класс предназначен для того, чтобы предоставить доступ к обычному массиву
 * через интерфейс long_AccessibleArray.
 *<p>Это иногда может быть нужно, если есть статически инициализированый
 *фактически не изменяемый массив, который всеже не слишком велик
 *чтобы реализация J2ME не могла выделить за раз такой размер.
 */

public final class   long_arraywraper extends long_Array implements long_AccessibleArray{
 private static final boolean FAST=true;     
 private final long[] array;
 private final int offs;
 private final int length;

 public long_arraywraper(long[] array){
  this(array,0,array.length);   
 }

 public long_arraywraper(long[] array, int offs, int length){
  this.array=array;
  this.offs=offs;
  this.length=length;
 }
 
 public int length(){
  return length;
 }
    
 public final int totalAllocated(){
  return array.length;
 }

 public int blockSize(){
  return array.length;
 }
    
 public final void set(int n, long val){
  array[offs+n]=val;
 }

 public final long get(int n){
  return array[offs+n];
 }

 public final void copyFrom(long[] src,int srcoff, int dstoff, int len){
  System.arraycopy(src,srcoff,array,offs+dstoff,len);   
 }
 
 public void copyTo(int srcoff, long[] dst, int dstoff, int len){
  System.arraycopy(array,offs+srcoff,dst,dstoff,len);
 }

  public final void copyTo(int srcoff, long_AccessibleArray dst, int dstoff, int len){
   dst.copyFrom(array,offs+srcoff,dstoff,len);   
  }

 public final void copyFrom(long_AccessibleArray src,int srcoff, int dstoff, int len){
  src.copyTo(srcoff,this,dstoff,len);
 }
  
 
  public final void clear(int off, int len){
   if(FAST) {
   //FAST==true
    long[] bb = new long[Math.min(50,length())];
    final int c=length()/bb.length;
    for(int i=0;i<=c;++i){
     final int off1=off+c*bb.length;
     if(off1<length())System.arraycopy(bb,0,array,offs+off1,Math.min(bb.length,length()-off1));   
    }//for
   }else{
   //FAST==false
    for(int i=off;i<off+len;++i) {
     array[offs+i]=(long)0;
    }//for
   }//if(FAST)
  }

 
}

