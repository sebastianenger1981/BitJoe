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

package com.asoft.midp.zip;

import java.io.*;
import com.asoft.midp.jzlib.*;


/**
 * This class provides support for general purpose compression using the
 * popular JZLIB compression library. JZLIB is a port of popular ZLIB library.
 *(see http://www.jcraft.com/jzlib/ for further JZLIB information)
 *The ZLIB compression library was
 * initially developed as part of the PNG graphics standard and is not
 * protected by patents.
 * 
 * @see		Inflater
 */
//!!!  TODO exclude casting of "long" to  "int" in case if "long" is excluded from JZLIB
public class Deflater {
    private int level, strategy;
    private boolean setParams;
    private boolean finish, finished;
    private ZStream c_stream;
    private boolean nowrap;//GZIP compatability (not supported)

    /**
     * Compression method for the deflate algorithm (the only one currently
     * supported).
     */
    public static final int DEFLATED = 8;

    /**
     * Compression level for no compression.
     */
    public static final int NO_COMPRESSION = JZlib.Z_NO_COMPRESSION;

    /**
     * Compression level for fastest compression.
     */
    public static final int BEST_SPEED = JZlib.Z_BEST_SPEED;

    /**
     * Compression level for best compression.
     */
    public static final int BEST_COMPRESSION = JZlib.Z_BEST_COMPRESSION;

    /**
     * Default compression level.
     */
    public static final int DEFAULT_COMPRESSION = JZlib.Z_DEFAULT_COMPRESSION;

    /**
     * Compression strategy best used for data consisting mostly of small
     * values with a somewhat random distribution. Forces more Huffman coding
     * and less string matching.
     */
    public static final int FILTERED = JZlib.Z_FILTERED;

    /**
     * Compression strategy for Huffman coding only.
     */
    public static final int HUFFMAN_ONLY = JZlib.Z_HUFFMAN_ONLY;

    /**
     * Default compression strategy.
     */
    public static final int DEFAULT_STRATEGY = JZlib.Z_DEFAULT_STRATEGY;
    
    /**
      * Creates a new compressor using the specified compression level.
      * If 'nowrap' is true then the ZLIB header and checksum fields will
      * not be used in order to support the compression format used in
      * both GZIP and PKZIP.
      * @param level the compression level (0-9)
      * @param nowrap if true then use GZIP compatible compression NOT TESTED
      */
    private Deflater(int level, boolean nowrap)  throws IOException{
     this.level = level;
     this.strategy = DEFAULT_STRATEGY;
     this.nowrap=nowrap;
     init(level, DEFAULT_STRATEGY, nowrap);
    }

    /** 
     * Creates a new compressor using the specified compression level.
     * Compressed data will be generated in ZLIB format.
     * @param level the compression level (0-9)
     */
    public Deflater(int level)  throws IOException{
	this(level, false);
    }

    
    /**
     * Creates a new compressor with the default compression level.
     * Compressed data will be generated in ZLIB format.
     */
    public Deflater()  throws IOException{
	this(DEFAULT_COMPRESSION, false);
    }

    /**
     * Sets input data for compression. This should be called whenever
     * needsInput() returns true indicating that more input data is required.
     * @param b the input data bytes
     * @param off the start offset of the data
     * @param len the length of the data
     * @see Deflater#needsInput
     */
    public synchronized void setInput(byte[] b, int off, int len) {
	if (b== null) {
	    throw new NullPointerException();
	}
	if (off < 0 || len < 0 || off + len > b.length) {
	    throw new ArrayIndexOutOfBoundsException();
	}
	//this.buf = b;
	//this.off = off;
	//this.len = len;
	c_stream.next_in=b;
	c_stream.next_in_index=off;
	c_stream.avail_in=len;
    }

    /**
     * Sets input data for compression. This should be called whenever
     * needsInput() returns true indicating that more input data is required.
     * @param b the input data bytes
     * @see Deflater#needsInput
     */
    public void setInput(byte[] b) {
	setInput(b, 0, b.length);
    }

    /**
     * Sets preset dictionary for compression. A preset dictionary is used
     * when the history buffer can be predetermined. When the data is later
     * uncompressed with Inflater.inflate(), Inflater.getAdler() can be called
     * in order to get the Adler-32 value of the dictionary required for
     * decompression.
     * @param b the dictionary data bytes
     * @param off the start offset of the data
     * @param len the length of the data
     * @see Inflater#inflate
     * @see Inflater#getAdler
     */
    public synchronized void setDictionary(byte[] b, int off, int len) throws IOException{
     if (c_stream==null || b == null) {
      throw new NullPointerException();
     }
     if (off < 0 || len < 0 || off + len > b.length) {
      throw new ArrayIndexOutOfBoundsException();
     }
     byte[] dictionary = new byte[len];
     System.arraycopy(b,off,dictionary,0,len);
     int err=c_stream.deflateSetDictionary(dictionary, dictionary.length);
     if(err!=JZlib.Z_OK){	 
       System.out.println(ErrorMsg(c_stream,err));
       throw new IOException(ErrorMsg(c_stream,err));
     }//if
    }

    /**
     * Sets preset dictionary for compression. A preset dictionary is used
     * when the history buffer can be predetermined. When the data is later
     * uncompressed with Inflater.inflate(), Inflater.getAdler() can be called
     * in order to get the Adler-32 value of the dictionary required for
     * decompression.
     * @param b the dictionary data bytes
     * @see Inflater#inflate
     * @see Inflater#getAdler
     */
    public void setDictionary(byte[] b)  throws IOException{
	setDictionary(b, 0, b.length);
    }

    /**
     * Sets the compression strategy to the specified value.
     * @param strategy the new compression strategy
     * @exception IllegalArgumentException if the compression strategy is
     *				           invalid
     */
    public synchronized void setStrategy(int strategy) {
	switch (strategy) {
	  case DEFAULT_STRATEGY:
	  case FILTERED:
	  case HUFFMAN_ONLY:
	    break;
	  default:
	    throw new IllegalArgumentException();
	}
	if (this.strategy != strategy) {
	    this.strategy = strategy;
	    setParams = true;
	}
    }

    /**
     * Sets the current compression level to the specified value.
     * @param level the new compression level (0-9)
     * @exception IllegalArgumentException if the compression level is invalid
     *<p>NOT PROPERLY IMPLEMENTED
     *<p>TODO: make it change compression level on fly (not only on reset)
     */
    public synchronized void setLevel(int level) {
	if ((level < 0 || level > 9) && level != DEFAULT_COMPRESSION) {
	    throw new IllegalArgumentException("invalid compression level");
	}
	if (this.level != level) {
	    this.level = level;
	    setParams = true;
	}
    }

    /**
     * Returns true if the input data buffer is empty and setInput()
     * should be called in order to provide more input.
     * @return true if the input data buffer is empty and setInput()
     * should be called in order to provide more input
     */
    public boolean needsInput() {
	return c_stream.avail_in <= 0;
    }

    /**
     * When called, indicates that compression should end with the current
     * contents of the input buffer.
     */
    public synchronized void finish() throws IOException{
     finish = true;
     int err=c_stream.deflate(JZlib.Z_FINISH);
     if(err==JZlib.Z_STREAM_END) finished=true;
     //if(err!=JZlib.Z_OK)System.out.println(ErrorMsg(c_stream,err));
     //err=c_stream.deflateEnd();
     if(err!=JZlib.Z_OK && err!=JZlib.Z_STREAM_END){
      System.out.println(ErrorMsg(c_stream,err));
      throw new IOException(ErrorMsg(c_stream,err));
     }//if      
    }

    /**
     * Returns true if the end of the compressed data output stream has
     * been reached.
     * @return true if the end of the compressed data output stream has
     * been reached
     */
    public synchronized boolean finished() {
	return finished;
    }

    /**
     * Fills specified buffer with compressed data. Returns actual number
     * of bytes of compressed data. A return value of 0 indicates that
     * needsInput() should be called in order to determine if more input
     * data is required.
     * @param b the buffer for the compressed data
     * @param off the start offset of the data
     * @param len the maximum number of bytes of compressed data
     * @return the actual number of bytes of compressed data
     */
    public synchronized int deflate(byte[] b, int off, int len) throws IOException{
	if (b == null) {
	    throw new NullPointerException();
	}
	if (off < 0 || len < 0 || off + len > b.length) {
	    throw new ArrayIndexOutOfBoundsException();
	}
	return deflateBytes(b, off, len);
    }

    /**
     * Fills specified buffer with compressed data. Returns actual number
     * of bytes of compressed data. A return value of 0 indicates that
     * needsInput() should be called in order to determine if more input
     * data is required.
     * @param b the buffer for the compressed data
     * @return the actual number of bytes of compressed data
     */
    public int deflate(byte[] b)  throws IOException{
	return deflate(b, 0, b.length);
    }

    /**
     * Returns the ADLER-32 value of the uncompressed data.
     * @return the ADLER-32 value of the uncompressed data
     */
    public synchronized int getAdler() {
     if (c_stream==null) {
      throw new NullPointerException();
     }
     return (int)c_stream.adler;
    }

    /**
     * Returns the total number of bytes input so far.
     * @return the total number of bytes input so far
     */
    public synchronized int getTotalIn() {
     if (c_stream==null) {
      throw new NullPointerException();
     }
     return (int)c_stream.total_in;
    }

    /**
     * Returns the total number of bytes output so far.
     * @return the total number of bytes output so far
     */
    public synchronized int getTotalOut() {
     if (c_stream==null) {
      throw new NullPointerException();
     }
     return (int)c_stream.total_out;
    }

    /**
     * Resets deflater so that a new set of input data can be processed.
     * Keeps current compression level and strategy settings.
     */
    public synchronized void reset()  throws IOException{
     if (c_stream==null) {
      throw new NullPointerException();
     }//if
     c_stream=null;
     init(level, DEFAULT_STRATEGY, nowrap);
     finish = false;
     finished = false;
     //off = len = 0;     
     c_stream.next_in_index=c_stream.avail_in=0;
    }

    
    /**
     * Closes the compressor and discards any unprocessed input.
     * This method should be called when the compressor is no longer
     * being used, but will also be called automatically by the
     * finalize() method. Once this method is called, the behavior
     * of the Deflater object is undefined.
     */
    public synchronized void end() {
     if (c_stream!=null) {
      c_stream.free();
      c_stream=null;
     }
    }

    //    /**
    //     * Closes the compressor when garbage is collected.
    //     */
    //    protected void finalize() {
    //     end();
    //    }
    
    private void init(int level, int strategy, boolean nowrap) throws IOException{
     this.level=level;
     this.strategy=strategy;
     c_stream = new ZStream();
     
     //??? may be correct ZIP data is needed here
     int err;
     if(nowrap){
      //err=c_stream.deflateInit(JZlib.Z_DEFAULT_COMPRESSION,-1);
      err=c_stream.deflateInit(level,-1);      
     }else{
      //err=c_stream.deflateInit(JZlib.Z_DEFAULT_COMPRESSION);
      err=c_stream.deflateInit(level);
     }//if
     if(err==JZlib.Z_STREAM_END) finished=true;
     if(err!=JZlib.Z_OK){
      System.out.println(ErrorMsg(c_stream,err));
       throw new IOException(ErrorMsg(c_stream,err));
     }//if      
    }
    
    private  int deflateBytes(byte[] b, int off, int len) throws IOException{
     //System.out.println("b.length="+b.length+" off="+off+" len="+len);
     final long last_total_out=c_stream.total_out;	
     c_stream.next_out=b;
     c_stream.next_out_index=off;
     c_stream.avail_out = len;

     final int err;
     if(finish==true){
      err=c_stream.deflate(JZlib.Z_FINISH);
     }else{
      err=c_stream.deflate(JZlib.Z_NO_FLUSH);//TODO adjust FLUSH method
     }//if 
     if(err==JZlib.Z_STREAM_END) finished=true;
     if(err!=JZlib.Z_OK&&err!=JZlib.Z_STREAM_END){
      System.out.println(ErrorMsg(c_stream,err));
      throw new IOException(ErrorMsg(c_stream,err));
     }//if      
     if(c_stream.total_out>Integer.MAX_VALUE){
      throw new IOException("Internal error: JZlib deflated data is too long");
     }//if
     return (int)(c_stream.total_out-last_total_out);
    }


 private static final void CheckError(ZStream z, int err) throws IOException{
  if(err!=JZlib.Z_OK){
   String err_s="zip error: "+err;	
   if(z.msg!=null) err_s=err_s+" ("+z.msg+")"; 
    throw new IOException(err_s);
   }//if
  }

 private static final String ErrorMsg(ZStream z, int err) throws IOException{
  String ret=null;
  if(err!=JZlib.Z_OK){
   String err_s="zip error: "+err;	
   if(z.msg!=null) err_s=err_s+" ("+z.msg+")";
   ret=err_s;
  }//if
  return ret;
 }

//==================================================================
/*
 public static void main(String[] args)throws Exception{
  final int hlen=0;   
  final byte[] buff="qwertyuiopasdfghjklzxcvbnm".getBytes();
  int l_in=buff.length;
  final byte[] out_buf = new byte[buff.length+30];
  Deflater	compressor = new Deflater(9);
System.out.println("#1");  
  compressor.reset();
System.out.println("#2");     
  compressor.setInput(buff,0,l_in);
System.out.println("#3");     
  while (!compressor.needsInput()){
System.out.println("#7");      
   compressor.deflate(out_buf,hlen+compressor.getTotalOut(),
	                 out_buf.length - (hlen+compressor.getTotalOut()) );
System.out.println("#7.2");    
  }//while
System.out.println("#8");   
  compressor.finish();
System.out.println("#9");   
  compressor.deflate(out_buf,hlen+compressor.getTotalOut(),
		       out_buf.length - (hlen+compressor.getTotalOut())  );
System.out.println("#10");   
   int l_out = compressor.getTotalOut();

 }
*/
    
}

