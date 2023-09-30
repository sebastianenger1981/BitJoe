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

public interface   char_AccessibleArray {

 public int length();
    
 public int totalAllocated();

 public int blockSize();
    
 public void set(int n, char val);

 public  char get(int n);

 /**Копирует из char[] src в данный char_array,
  *при помощи этой функции в любой реализации char_AccessibleArray
  *легко сделать функцию блочного копирования в другой char_AccessibleArray
  *независимо от внутреннего устройства последнего
  *<p>ATTENTION: поэтому реализация этой функции НЕ должна
  *полагаться на какие-либо методы из src, а должна сама,
  *зная свое внутреннее устройство данного char_AccessibleArray,
  *все делать.
  */
 public void copyFrom(char[] src,int srcoff, int dstoff, int len);

/**Копирует из данного char_array в char[] dst*/
 public void copyTo(int srcoff, char[] dst, int dstoff, int len);

 /**Копирует данный char_AccessibleArray в другой char_AccessibleArray dst. 
  *<p>ATTENTION: Реализация этой функции может полагаться на
  *dst.copyFrom(char[] src,int srcoff, int dstoff, int len), dst.set(int n, char val)
  */
 public void copyTo(int srcoff, char_AccessibleArray dst, int dstoff, int len);
 
 /**Приводит часть массива в неинициализированное состояние
  *(как обычно в Java в этой части массива будут нули),
  *при этом как это обрабатывается (например можно пытаться
  *просто освободить несколько выделеных ранее блоков памяти)
  *остается на совести конкретной реализации char_AccessibleArray
  */
 public void clear(int off, int len);
 
}

