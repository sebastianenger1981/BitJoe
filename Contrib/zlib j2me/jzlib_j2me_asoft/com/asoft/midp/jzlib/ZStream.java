/* -*-mode:java; c-basic-offset:2; -*- */
/*
Copyright (c) 2000,2001,2002,2003 ymnk, JCraft,Inc. All rights reserved.

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
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JCRAFT,
INC. OR ANY CONTRIBUTORS TO THIS SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * This program is based on zlib-1.1.3, so all credit should go authors
 * Jean-loup Gailly(jloup@gzip.org) and Mark Adler(madler@alumni.caltech.edu)
 * and contributors of zlib.
 */
/*                                                                              
 *Modified by Asoft ltd. at 2003 for running on J2ME platform                   
 *www.asoft.ru                                                                  
 *Alexandre Rusev rusev@asoft.ru                                                
 *Alexey Soloviev soloviev@asoft.ru                                             
 */
  /**
   *<pre>     
   *    deflate(...) compresses as much data as possible, and stops when the input
   *  buffer becomes empty or the output buffer becomes full. It may introduce some
   *    output latency (reading input without producing any output) except when
   *    forced to flush.
   *  
   *      The detailed semantics are as follows. deflate performs one or both of the
   *    following actions:
   *  
   *    - Compress more input starting at next_in and update next_in and avail_in
   *      accordingly. If not all input can be processed (because there is not
   *      enough room in the output buffer), next_in and avail_in are updated and
   *      processing will resume at this point for the next call of deflate().
   *  
   *    - Provide more output starting at next_out and update next_out and avail_out
   *      accordingly. This action is forced if the parameter flush is non zero.
   *      Forcing flush frequently degrades the compression ratio, so this parameter
   *      should be set only when necessary (in interactive applications).
   *      Some output may be provided even if flush is not set.
   *  
   *    Before the call of deflate(), the application should ensure that at least
   *    one of the actions is possible, by providing more input and/or consuming
   *    more output, and updating avail_in or avail_out accordingly; avail_out
   *    should never be zero before the call. The application can consume the
   *    compressed output when it wants, for example when the output buffer is full
   *    (avail_out == 0), or after each call of deflate(). If deflate returns Z_OK
   *    and with zero avail_out, it must be called again after making room in the
   *    output buffer because there might be more output pending.
   *  
   *      If the parameter flush is set to Z_SYNC_FLUSH, all pending output is
   *    flushed to the output buffer and the output is aligned on a byte boundary, so
   *    that the decompressor can get all input data available so far. (In particular
   *    avail_in is zero after the call if enough output space has been provided
   *    before the call.)  Flushing may degrade compression for some compression
   *    algorithms and so it should be used only when necessary.
   *  
   *      If flush is set to Z_FULL_FLUSH, all output is flushed as with
   *    Z_SYNC_FLUSH, and the compression state is reset so that decompression can
   *    restart from this point if previous compressed data has been damaged or if
   *    random access is desired. Using Z_FULL_FLUSH too often can seriously degrade
   *    the compression.
   *  
   *      If deflate returns with avail_out == 0, this function must be called again
   *    with the same value of the flush parameter and more output space (updated
   *    avail_out), until the flush is complete (deflate returns with non-zero
   *    avail_out).
   *  
   *      If the parameter flush is set to Z_FINISH, pending input is processed,
   *    pending output is flushed and deflate returns with Z_STREAM_END if there
   *    was enough output space; if deflate returns with Z_OK, this function must be
   *    called again with Z_FINISH and more output space (updated avail_out) but no
   *    more input data, until it returns with Z_STREAM_END or an error. After
   *    deflate has returned Z_STREAM_END, the only possible operations on the
   *    stream are deflateReset or deflateEnd.
   *    
   *      Z_FINISH can be used immediately after deflateInit if all the compression
   *    is to be done in a single step. In this case, avail_out must be at least
   *    0.1% larger than avail_in plus 12 bytes.  If deflate does not return
   *    Z_STREAM_END, then it must be called again as described above.
   *  
   *      deflate() sets strm->adler to the adler32 checksum of all input read
   *    so far (that is, total_in bytes).
   *  
   *      deflate() may update data_type if it can make a good guess about
   *    the input data type (Z_ASCII or Z_BINARY). In doubt, the data is considered
   *    binary. This field is only for information purposes and does not affect
   *    the compression algorithm in any manner.
   *   
   *      deflate() returns Z_OK if some progress has been made (more input
   *    processed or more output produced), Z_STREAM_END if all input has been
   *    consumed and all output has been produced (only when flush is set to
   *    Z_FINISH), Z_STREAM_ERROR if the stream state was inconsistent (for example
   *    if next_in or next_out was NULL), Z_BUF_ERROR if no progress is possible
   *    (for example avail_in or avail_out was zero).
   *    </pre>
   */


package com.asoft.midp.jzlib;

import com.asoft.midp.dynarray.*;


final public class ZStream{

  static final private int MAX_WBITS=15;        // 32K LZ77 window
  static final private int DEF_WBITS=MAX_WBITS;

  static final private int Z_NO_FLUSH=0;
  static final private int Z_PARTIAL_FLUSH=1;
  static final private int Z_SYNC_FLUSH=2;
  static final private int Z_FULL_FLUSH=3;
  static final private int Z_FINISH=4;

  static final private int MAX_MEM_LEVEL=9;

  static final private int Z_OK=0;
  static final private int Z_STREAM_END=1;
  static final private int Z_NEED_DICT=2;
  static final private int Z_ERRNO=-1;
  static final private int Z_STREAM_ERROR=-2;
  static final private int Z_DATA_ERROR=-3;
  static final private int Z_MEM_ERROR=-4;
  static final private int Z_BUF_ERROR=-5;
  static final private int Z_VERSION_ERROR=-6;

  public byte[] next_in;     // next input byte
  public int next_in_index;
  public int avail_in;       // number of bytes available at next_in
  public long total_in;      // total nb of input bytes read so far

  public byte[] next_out;    // next output byte should be put there
  public int next_out_index;
  public int avail_out;      // remaining free space at next_out
  public long total_out;     // total nb of bytes output so far

  public String msg;

  Deflate dstate; 
  Inflate istate; 

  int data_type; // best guess about the data type: ascii or binary

  public long adler;
  Adler32 _adler=new Adler32();

  public int inflateInit(){
    return inflateInit(DEF_WBITS);
  }
  public int inflateInit(int w){
    istate=null;
    istate=new Inflate();
    return istate.inflateInit(this, w);
  }

  public int inflate(int f){
    if(istate==null) return Z_STREAM_ERROR;
    return istate.inflate(this, f);
  }
  public int inflateEnd(){
    if(istate==null) return Z_STREAM_ERROR;
    int ret=istate.inflateEnd(this);
    istate = null;
    return ret;
  }
  public int inflateSync(){
    if(istate == null)
      return Z_STREAM_ERROR;
    return istate.inflateSync(this);
  }
  public int inflateSetDictionary(byte[] dictionary, int dictLength){
    if(istate == null)
      return Z_STREAM_ERROR;
    return istate.inflateSetDictionary(this, dictionary, dictLength);
  }

  public int deflateInit(int level){
    return deflateInit(level, MAX_WBITS);
  }
  public int deflateInit(int level, int bits){
    dstate=null;
    dstate=new Deflate();
    return dstate.deflateInit(this, level, bits);
  }
  public int deflate(int flush){
    if(dstate==null){
      return Z_STREAM_ERROR;
    }
    return dstate.deflate(this, flush);
  }
  public int deflateEnd(){
    if(dstate==null) return Z_STREAM_ERROR;
    int ret=dstate.deflateEnd();
    dstate=null;
    return ret;
  }
  public int deflateParams(int level, int strategy){
    if(dstate==null) return Z_STREAM_ERROR;
    return dstate.deflateParams(this, level, strategy);
  }
  public int deflateSetDictionary (byte[] dictionary, int dictLength){
    if(dstate == null)
      return Z_STREAM_ERROR;
    return dstate.deflateSetDictionary(this, dictionary, dictLength);
  }

  // Flush as much pending output as possible. All deflate() output goes
  // through this function so some applications may wish to modify it
  // to avoid allocating a large strm->next_out buffer and copying into it.
  // (See also read_buf()).
  void flush_pending(){
    int len=dstate.pending;

    if(len>avail_out) len=avail_out;
    if(len==0) return;

    if(dstate.pending_buf.length()<=dstate.pending_out ||
       next_out.length<=next_out_index ||
       dstate.pending_buf.length()<(dstate.pending_out+len) ||
       next_out.length<(next_out_index+len)){
      System.out.println(dstate.pending_buf.length()+", "+dstate.pending_out+
			 ", "+next_out.length+", "+next_out_index+", "+len);
      System.out.println("avail_out="+avail_out);
    }

    //System.arraycopy(dstate.pending_buf, dstate.pending_out,next_out, next_out_index, len);
    byte_array.Copy(dstate.pending_buf, dstate.pending_out,next_out, next_out_index, len);

    next_out_index+=len;
    dstate.pending_out+=len;
    total_out+=len;
    avail_out-=len;
    dstate.pending-=len;
    if(dstate.pending==0){
      dstate.pending_out=0;
    }
  }

  // Read a new buffer from the current input stream, update the adler32
  // and total number of bytes read.  All deflate() input goes through
  // this function so some applications may wish to modify it to avoid
  // allocating a large strm->next_in buffer and copying from it.
  // (See also flush_pending()).
  int read_buf(byte_array buf, int start, int size) {
    int len=avail_in;

    if(len>size) len=size;
    if(len==0) return 0;

    avail_in-=len;

    if(dstate.noheader==0) {
      adler=_adler.adler32(adler, next_in, next_in_index, len);
    }
    //System.arraycopy(next_in, next_in_index, buf, start, len);
    byte_array.Copy(next_in, next_in_index, buf, start, len);
    next_in_index  += len;
    total_in += len;
    return len;
  }

  public void free(){
    next_in=null;
    next_out=null;
    msg=null;
    _adler=null;
  }
}
