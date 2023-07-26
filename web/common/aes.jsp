<%@ page import="javax.crypto.SecretKey" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>
<%@ page import="java.security.spec.AlgorithmParameterSpec" %>
<%@ page import="javax.crypto.spec.IvParameterSpec" %>
<%@ page import="javax.crypto.Cipher" %>
<%!
  public static String decryptMsg(final String encrypted) {
    try {
      SecretKey key = new SecretKeySpec(Base64.decodeBase64("u/Gu5posvwDsXUnV5Zaq4g=="), "AES");
      AlgorithmParameterSpec iv = new IvParameterSpec(Base64.decodeBase64("5D9r9ZVzEYYgha93/aUK2w=="));
      byte[] decodeBase64 = Base64.decodeBase64(encrypted);

      Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
      cipher.init(Cipher.DECRYPT_MODE, key, iv);

      return new String(cipher.doFinal(decodeBase64), "UTF-8");
    } catch (Exception e) {
      throw new RuntimeException("This should not happen in production.", e);
    }
  }

  public String encryptMsg(final String message) {
    try {
      SecretKey key = new SecretKeySpec(Base64.decodeBase64("u/Gu5posvwDsXUnV5Zaq4g=="), "AES");
      AlgorithmParameterSpec iv = new IvParameterSpec(Base64.decodeBase64("5D9r9ZVzEYYgha93/aUK2w=="));
      Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
      cipher.init(Cipher.ENCRYPT_MODE, key, iv);
      byte[] encryptedBytes = cipher.doFinal(message.getBytes());
      String base64 = Base64.encodeBase64String(encryptedBytes) ;
      return base64;
    } catch (Exception e) {
      throw new RuntimeException("This should not happen in production.", e);
    }
  }

  public String EncKey() {
    try {
      byte[] _IV = null;
      byte[] _Key = null;
      _Key = new byte[16];
      _IV = new byte[16];
      MessageDigest hash = null;
      hash = MessageDigest.getInstance("SHA-256");
      Base64.encodeBase64String(hash.digest(CommonUtil.getEncKey().getBytes("UTF-8")));
      byte[] key = hash.digest(CommonUtil.getEncKey().getBytes("UTF-8"));

      int i;
      for (i = 0; i < 16; ++i) {
        _Key[i] = key[i];
      }

      return Base64.encodeBase64String(_Key);
    } catch (Exception e) {
      throw new RuntimeException("This should not happen in production.", e);
    }
  }

    public String EncIv() {
      try {
        byte[] _IV = null;
        byte[] _Key = null;
        _Key = new byte[16];
        _IV = new byte[16];
        MessageDigest hash = null;
        hash = MessageDigest.getInstance("SHA-256");
        Base64.encodeBase64String(hash.digest(CommonUtil.getEncKey().getBytes("UTF-8")));
        byte[] key = hash.digest(CommonUtil.getEncKey().getBytes("UTF-8"));

        int i;

        for(i = 16; i < 32; ++i) {
          _IV[i - 16] = key[i];
        }
        return Base64.encodeBase64String(_IV);
      } catch (Exception e) {
        throw new RuntimeException("This should not happen in production.", e);
      }

  }

%>