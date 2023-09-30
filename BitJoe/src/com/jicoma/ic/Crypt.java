package com.jicoma.ic;


import org.bouncycastle.util.encoders.Hex;
import org.bouncycastle.crypto.BufferedBlockCipher;
import org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.bouncycastle.crypto.modes.CBCBlockCipher;
import org.bouncycastle.crypto.engines.AESEngine;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.crypto.CryptoException;

import com.twmacinta.util.*;
import de.hgnut.Misc.Constant;


public class Crypt{

 //private BufferedBlockCipher cipher      = null;
 private byte[] cipherText  = null;
	
	public Crypt(String kryptKey){
		
		//System.out.println("cipherText: " +kryptKey);
		
	this.cipherText = Hex.decode(kryptKey.getBytes());
	
		//String st = new String(Hex.encode(cipherText));
        
	}
    
public final String performEncrypt(String plainText){

        byte[] ptBytes = plainText.getBytes();

   BufferedBlockCipher cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(new AESEngine()));
        
        String name = cipher.getUnderlyingCipher().getAlgorithmName();

        cipher.init(true, new KeyParameter(cipherText));

        byte[] rv = new byte[cipher.getOutputSize(ptBytes.length)];

        int oLen = cipher.processBytes(ptBytes, 0, ptBytes.length, rv, 0);
        try
        {
            cipher.doFinal(rv, oLen);
        }
        catch (CryptoException ce)
        {
            System.out.println("CryptoException: "+ce.toString());
        }
        
        String plain = new String(Hex.encode(rv));
        //System.out.println("plain: "+ plain);
        byte plainBytes[] = plain.getBytes();
        MD5 md5 = new MD5(plainBytes);
        byte[] result = md5.doFinal();
        String hashResult = md5.toHex(result);
        //return hashResult+Constant.CRLF+Constant.PUBLICKEY+Constant.CRLF+plain;
        return hashResult+"##"+Constant.PUBLICKEY+"##"+plain+Constant.CRLF;                  
    }
    
 			
}	