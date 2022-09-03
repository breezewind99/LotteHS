package com.cnet.crec.wfms;



import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.NoSuchAlgorithmException;
import org.apache.commons.codec.binary.Base64;

public class AES256Cipher
{
    private static volatile AES256Cipher INSTANCE;
    private static String IV = "";
    private static Key keySpec;

    public static AES256Cipher getInstance(String key) throws UnsupportedEncodingException
    {
        if (INSTANCE == null) {
            synchronized (AES256Cipher.class)
            {
                if (INSTANCE == null) {
                    INSTANCE = new AES256Cipher(key);
                }
            }
        }
        return INSTANCE;
    }

    private AES256Cipher(String key) throws UnsupportedEncodingException
    {
        IV = key.substring(0, 16);

        byte[] keyBytes = new byte[16];
        byte[] b = key.getBytes("UTF-8");
        int len = b.length;
        if (len > keyBytes.length) {
            len = keyBytes.length;
        }
        System.arraycopy(b, 0, keyBytes, 0, len);
        SecretKeySpec secKeySpec = new SecretKeySpec(keyBytes, "AES");

        keySpec = secKeySpec;
    }

    public String encrypt(String str)
            throws UnsupportedEncodingException, NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, IllegalBlockSizeException, BadPaddingException
    {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(1, keySpec, new IvParameterSpec(IV.getBytes()));

        byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
        String enStr = new String(Base64.encodeBase64(encrypted));

        return enStr;
    }

    public String decrypt(String str)
            throws UnsupportedEncodingException, NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, IllegalBlockSizeException, BadPaddingException
    {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(2, keySpec, new IvParameterSpec(IV.getBytes("UTF-8")));

        byte[] byteStr = Base64.decodeBase64(str.getBytes());

        return new String(c.doFinal(byteStr), "UTF-8");
    }
}