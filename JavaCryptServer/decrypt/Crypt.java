import org.bouncycastle.util.encoders.Hex;
import org.bouncycastle.crypto.BufferedBlockCipher;
import org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.bouncycastle.crypto.modes.CBCBlockCipher;
import org.bouncycastle.crypto.engines.AESEngine;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.crypto.CryptoException;


public class Crypt{

 //private BufferedBlockCipher cipher      = null;
 private byte[]              cipherText  = null;
	
	public Crypt(String kryptKey, String s){
		//System.out.println(s);
		cipherText = performEncrypt(Hex.decode(kryptKey.getBytes()), s);
		//String st = new String(cipherText);
		String st = new String(Hex.encode(cipherText));
        //System.out.println(st);
		//System.out.println(new String(performEncrypt(Hex.decode(kryptKey.getBytes()), s)));
		
		// BASTI: 17-4-2007: System.out.println("Verschlüsselt: "+st);
		System.out.println( st );

		//String cs = performDecrypt(Hex.decode(kryptKey.getBytes()), cipherText);
		//String cs = performDecrypt(Hex.decode(kryptKey.getBytes()), st);
		//System.out.println("Entschlüsselt: "+ cs); 
	}
    
    private final byte[] performEncrypt(byte[] key, String plainText){

        byte[] ptBytes = plainText.getBytes();

   BufferedBlockCipher cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(new AESEngine()));
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new ISO7816d4Padding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new ISO10126d2Padding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new TBCPadding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new X923Padding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), new ZeroBytePadding());
        //cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(getEngineInstance()), null);
      
        

        String name = cipher.getUnderlyingCipher().getAlgorithmName();

        cipher.init(true, new KeyParameter(key));

        byte[] rv = new byte[cipher.getOutputSize(ptBytes.length)];

        int oLen = cipher.processBytes(ptBytes, 0, ptBytes.length, rv, 0);
        try
        {
            cipher.doFinal(rv, oLen);
        }
        catch (CryptoException ce)
        {
            System.out.println("Ooops, encrypt exception");
            System.out.println(ce.toString());
        }
        return rv;
    }
    //private final String performDecrypt(byte[] key, byte[] cipherText)
   /* private final String performDecrypt(byte[] key, String st)
    {
    	cipherText = Hex.decode(st);
    	BufferedBlockCipher cipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(new AESEngine()));
        cipher.init(false, new KeyParameter(key));

        byte[] rv = new byte[cipher.getOutputSize(cipherText.length)];

        int oLen = cipher.processBytes(cipherText, 0, cipherText.length, rv, 0);
        try
        {
            cipher.doFinal(rv, oLen);
        }
        catch (CryptoException ce)
        {
            System.out.println("Ooops, decrypt exception");
            System.out.println(ce.toString());
        }
        return new String(rv).trim();
    }*/
    public static void main(String args[]){
    	String s = "";
    	for(int i = 1; i < args.length; i++){
    		if(i == 1){
    		  s = s +args[i];	
    		}else{	
    		  s = s +" "+args[i];
    	    }
    	}	
    	 new Crypt(args[0], s);
    	 
    }			
}	