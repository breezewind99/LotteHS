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

%>