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

/**От этого класса хорошо бы (но не обязательно) наследовать
 *реализации интерфейса short_AccessibleArray,
 *чтобы унаследовались некоторые (в частности статические) функции,
 *а можно этого и не делать, а вызывать их явно указывая этот класс.
 */

public class short_Array{

public static void Copy(short_AccessibleArray src,int srcoff, short_AccessibleArray dst, int dstoff, int len){
  if(len==0)return;     
  src.copyTo(srcoff,dst,dstoff,len);
 }
  public static void Copy(short[] src,int srcoff, short_AccessibleArray dst, int dstoff, int len){
   dst.copyFrom(src,srcoff,dstoff,len);
  }
 public static final void Copy(short_AccessibleArray src,int srcoff, short[] dst, int dstoff, int len){
  src.copyTo(srcoff,dst,dstoff,len);   
 }

 

}
