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
package  com.asoft.midp.zip;

import java.io.*;
import com.asoft.midp.jzlib.*;
//import java.util.zip.DataFormatException;

/**
 * This class provides support for general purpose decompression using
 * popular JZLIB compression library based on ZLIB. The ZLIB compression library was
 * initially developed as part of the PNG graphics standard and is not
 * protected by patents. It is fully described in the specifications at 
 * the <a href="package-summary.html#package_description">java.util.zip
 * package description</a>.
 *
 * @see		Deflater
 *
 */
public class Inflater {
    private ZStream d_stream;
    private boolean nowrap;
    //private byte[] buf = new byte[0];
    //private int off, len;
    private boolean finished;
    private boolean needDict;

  // compression levels
    public static final int NO_COMPRESSION=JZlib.Z_NO_COMPRESSION;
    public static final int BEST_SPEED=JZlib.Z_BEST_SPEED;
    public static final  int BEST_COMPRESSION=JZlib.Z_BEST_COMPRESSION;
    public static final int DEFAULT_COMPRESSION=JZlib.Z_DEFAULT_COMPRESSION;

  // compression strategy
    public static final int FILTERED=JZlib.Z_FILTERED;
    public static final int HUFFMAN_ONLY=JZlib.Z_HUFFMAN_ONLY;
    public static final int DEFAULT_STRATEGY=JZlib.Z_DEFAULT_STRATEGY;


    
    /**
     * Creates a new decompressor. If the parameter 'nowrap' is true then
     * the ZLIB header and checksum fields will not be used. This provides
     * compatibility with the compression format used by both GZIP and PKZIP.
     * <p>
     * Note: When using the 'nowrap' option it is also necessary to provide
     * an extra "dummy" byte as input. This is required by the ZLIB native
     * library in order to support certain optimizations.
     *
     * @param nowrap if true then support GZIP compatible compression NOT TESTED
     */
    public Inflater(boolean nowrap) throws IOException{
	init(nowrap);
    }

    /**
     * Creates a new decompressor.
     */
    public Inflater()  throws IOException{
	this(false);
    }
    
    

    /**
     * Sets input data for decompression. Should be called whenever
     * needsInput() returns true indicating that more input data is
     * required.
     * @param b the input data bytes
     * @param off the start offset of the input data
     * @param len the length of the input data
     * @see Inflater#needsInput
     */
    public synchronized void setInput(byte[] b, int off, int len) {
	if (b == null) {
	    throw new NullPointerException();
	}
	if (off < 0 || len < 0 || off + len > b.length) {
	    throw new ArrayIndexOutOfBoundsException();
	}
	//this.buf = b;
	//this.off = off;
	//this.len = len;
	d_stream.next_in=b;
	d_stream.next_in_index=off;
	d_stream.avail_in=len;
    }

    /**
     * Sets input data for decompression. Should be called whenever
     * needsInput() returns true indicating that more input data is
     * required.
     * @param b the input data bytes
     * @see Inflater#needsInput
     */
    public void setInput(byte[] b) {
	setInput(b, 0, b.length);
    }

    /**
     * Sets the preset dictionary to the given array of bytes. Should be
     * called when inflate() returns 0 and needsDictionary() returns true
     * indicating that a preset dictionary is required. The method getAdler()
     * can be used to get the Adler-32 value of the dictionary needed.
     * @param b the dictionary data bytes
     * @param off the start offset of the data
     * @param len the length of the data
     * @see Inflater#needsDictionary
     * @see Inflater#getAdler
     */
    public synchronized void setDictionary(byte[] b, int off, int len)  throws IOException{
     if (d_stream==null || b == null) {
      throw new NullPointerException();
     }
     if (off < 0 || len < 0 || off + len > b.length) {
      throw new ArrayIndexOutOfBoundsException();
     }
     byte[] dictionary = new byte[len];
     System.arraycopy(b,off,dictionary,0,len);
     int err=d_stream.inflateSetDictionary(dictionary, dictionary.length);
     if(err!=JZlib.Z_OK){
       System.out.println(ErrorMsg(d_stream,err));
       throw new IOException(ErrorMsg(d_stream,err));
     }//if
     needDict = false;
    }

    /**
     * Sets the preset dictionary to the given array of bytes. Should be
     * called when inflate() returns 0 and needsDictionary() returns true
     * indicating that a preset dictionary is required. The method getAdler()
     * can be used to get the Adler-32 value of the dictionary needed.
     * @param b the dictionary data bytes
     * @see Inflater#needsDictionary
     * @see Inflater#getAdler
     */
    public void setDictionary(byte[] b)  throws IOException{
	setDictionary(b, 0, b.length);
    }

    /**
     * Returns the total number of bytes remaining in the input buffer.
     * This can be used to find out what bytes still remain in the input
     * buffer after decompression has finished.
     * @return the total number of bytes remaining in the input buffer
     */
    public synchronized int getRemaining() {
	return d_stream.avail_in;
    }

    /**
     * Returns true if no data remains in the input buffer. This can
     * be used to determine if #setInput should be called in order
     * to provide more input.
     * @return true if no data remains in the input buffer
     */
    public synchronized boolean needsInput() {
	return d_stream.avail_in <= 0;
    }

    /**
     * Returns true if a preset dictionary is needed for decompression.
     * @return true if a preset dictionary is needed for decompression
     * @see Inflater#setDictionary
     */
    public synchronized boolean needsDictionary() {
	return needDict;
    }

    /**
     * Return true if the end of the compressed data stream has been
     * reached.
     * @return true if the end of the compressed data stream has been
     * reached
     */
    public synchronized boolean finished() {
	return finished;
    }

    /**
     * Uncompresses bytes into specified buffer. Returns actual number
     * of bytes uncompressed. A return value of 0 indicates that
     * needsInput() or needsDictionary() should be called in order to
     * determine if more input data or a preset dictionary is required.
     * In the later case, getAdler() can be used to get the Adler-32
     * value of the dictionary required.
     * @param b the buffer for the uncompressed data
     * @param off the start offset of the data
     * @param len the maximum number of uncompressed bytes
     * @return the actual number of uncompressed bytes
     * @exception DataFormatException if the compressed data format is invalid
     * @see Inflater#needsInput
     * @see Inflater#needsDictionary
     */
    public synchronized int inflate(byte[] b, int off, int len)
	throws DataFormatException, IOException
    {
	if (b == null) {
	    throw new NullPointerException();
	}
	if (off < 0 || len < 0 || off + len > b.length) {
	    throw new ArrayIndexOutOfBoundsException();
	}
	return inflateBytes(b, off, len);
    }

    /**
     * Uncompresses bytes into specified buffer. Returns actual number
     * of bytes uncompressed. A return value of 0 indicates that
     * needsInput() or needsDictionary() should be called in order to
     * determine if more input data or a preset dictionary is required.
     * In the later case, getAdler() can be used to get the Adler-32
     * value of the dictionary required.
     * @param b the buffer for the uncompressed data
     * @return the actual number of uncompressed bytes
     * @exception DataFormatException if the compressed data format is invalid
     * @see Inflater#needsInput
     * @see Inflater#needsDictionary
     */
    public int inflate(byte[] b) throws DataFormatException, IOException {
	return inflate(b, 0, b.length);
    }

    /**
     * Returns the ADLER-32 value of the uncompressed data.
     * @return the ADLER-32 value of the uncompressed data
     */
    public synchronized int getAdler() {
     if (d_stream==null) {
      throw new NullPointerException();
     }
     return (int)d_stream.adler;
    }

    /**
     * Returns the total number of bytes input so far.
     * @return the total number of bytes input so far
     */
    public synchronized int getTotalIn() {
     if (d_stream==null) {
      throw new NullPointerException();
     }
     return (int)d_stream.total_in;
    }

    /**
     * Returns the total number of bytes output so far.
     * @return the total number of bytes output so far
     */
    public synchronized int getTotalOut() {
     if (d_stream==null) {
      throw new NullPointerException();
     }
     return (int)d_stream.total_out;
    }

    /**
     * Resets inflater so that a new set of input data can be processed.
     */
    public synchronized void reset()  throws IOException{
     if (d_stream==null) {
      throw new NullPointerException();
     }//if
     d_stream=null;
     init(nowrap);
     finished = false;
     needDict = false;
     //off = len = 0;
     d_stream.next_in_index=d_stream.avail_in=0;
    }

    /**
     * Closes the decompressor and discards any unprocessed input.
     * This method should be called when the decompressor is no longer
     * being used, but will also be called automatically by the finalize()
     * method. Once this method is called, the behavior of the Inflater
     * object is undefined.
     */
    public synchronized void end() {
     if (d_stream!=null) {
      d_stream.free();
      d_stream=null;
     }
    }

    //    /**
    //     * Closes the decompressor when garbage is collected.
    //     */
    //    protected void finalize() {
    //	end();
    //    }


    
    private final void init(boolean nowrap)throws IOException{
     this.nowrap=nowrap;
     d_stream=new ZStream();
     int err;
     if(nowrap){
      err=d_stream.inflateInit(-1);
     }else{
      err=d_stream.inflateInit();
     }//if
     if(err==JZlib.Z_STREAM_END) finished=true;
     if(err!=JZlib.Z_OK){
      System.out.println(ErrorMsg(d_stream,err));
       throw new IOException(ErrorMsg(d_stream,err));
     }//if           
     
    }
    
    private int inflateBytes(byte[] b, int off, int len)throws DataFormatException,IOException{
     final long last_total_out=d_stream.total_out;
     d_stream.next_out=b;
     d_stream.next_out_index=off;
     d_stream.avail_out = len;
     int err=d_stream.inflate(JZlib.Z_NO_FLUSH);
     if(err==JZlib.Z_STREAM_END) finished=true;
     if(err!=JZlib.Z_OK && err!=JZlib.Z_STREAM_END){
      System.out.println(ErrorMsg(d_stream,err));
      throw new IOException(ErrorMsg(d_stream,err));
     }//if
     return (int)(d_stream.total_out-last_total_out); 
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
 public static void main(String[] args)throws Exception{
     
  //compress data
  System.out.println("compress data");
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
   System.out.println("data compressed in="+compressor.getTotalIn()+" out="+compressor.getTotalOut());  


   //put output of compressor in to decompressor input
   final byte[] data=out_buf;
   l_in=l_out;
   final byte[] udata = new byte[buff.length+20];
   
   
   //decompress data
   System.out.println("decompress data");

System.out.println("#11");      
   Inflater decompressor = new Inflater();
System.out.println("#12");      
   decompressor.reset();
System.out.println("#13");      
   decompressor.setInput(data,hlen,l_in);
System.out.println("#14");      
   int offs=0;
   int n=0;

   while( !decompressor.needsInput()   &&!decompressor.finished()){
System.out.println("#15");          
     n=decompressor.inflate(udata,offs,udata.length-offs);
     offs=offs+n;
System.out.println("#16");
	 
   }//while

System.out.println("#33");

System.out.println(new String(udata));
System.out.println("data decompressed in="+decompressor.getTotalIn()+" out="+decompressor.getTotalOut());   





   


   

//---------------------------------- 
/*      
      try {
        decompressor.setInput(data,hlen,l_in);//начнем раззиповывать
	                   //со сдвигом на длину заголовка
        int offs=0;
        int n=0;
        while( offs<max_udatalen-1 && !decompressor.needsInput()   &&!decompressor.finished()){
   	 n=decompressor.inflate(udata,offs,udata.length-offs);
         offs=offs+n;
         if(udata.length<=offs){
          //увеличим размер массива
          int q=Math.max(udata.length*6/5,2*data.length);
          byte[] old_udataref=udata;
          udata = new byte[Math.min(q,max_udatalen)];
          System.arraycopy(old_udataref,0,udata,0,old_udataref.length);
          System.out.println("Increased buffer for uncompressed DataPacket to "+
                              udata.length+" bytes.");          
         }//if(udata.ref.length<offs+1)

        }//while
*/

 }     

    
}
