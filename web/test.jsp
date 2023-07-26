<%@ page import="java.security.MessageDigest" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto" %>
<%@ include file="/common/aes.jsp" %>
<%@ include file="/common/common.jsp" %>

<%
	byte[] _IV = null;
	byte[] _Key = null;
	_Key = new byte[16];
	_IV = new byte[16];

	MessageDigest hash = null;
	hash = MessageDigest.getInstance("SHA-256");
	Base64.encodeBase64String(hash.digest(CommonUtil.getEncKey().getBytes("UTF-8")));
	byte[] key = hash.digest(CommonUtil.getEncKey().getBytes("UTF-8"));

	int i;
	for(i = 0; i < 16; ++i) {
		_Key[i] = key[i];
	}

	for(i = 16; i < 32; ++i) {
		_IV[i - 16] = key[i];
	}

    logger.info("key : " + Base64.encodeBase64String(_Key));
	logger.info("Iv : " + Base64.encodeBase64String(_IV));
	String temp = encryptMsg("01098580428");
	logger.info(Base64.encodeBase64String(hash.digest(CommonUtil.getEncKey().getBytes("UTF-8"))));
	CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
    temp = aes.Encrypt("test");
	logger.info(temp);
//    String temp2 = decryptMsg(temp);
//	logger.info(temp2);
%>

<!DOCTYPE html>
<html>
<head>

	<script type="text/javascript" src="./js/aes.js"></script>
	<script type="text/javascript" src="./js/aescommon.js"></script>
	<!--// rsa -->
</head>

<body>
<script type="text/javascript">
    <%--var rkEncryptionKey = CryptoJS.enc.Base64.parse('<%=EncKey()%>');--%>
    <%--var rkEncryptionIv = CryptoJS.enc.Base64.parse('<%=EncIv()%>');--%>
	// console.log(rkEncryptionKey.toString());
    // console.log(rkEncryptionIv.toString());
    var decrypt = CryptoJS.AES.decrypt("<%=temp%>", rkEncryptionKey, {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: rkEncryptionIv});
    <%--var decrypt = CryptoJS.AES.decrypt("<%=temp%>", CryptoJS.enc.Utf8.parse("!@CNET#$"), {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: CryptoJS.enc.Utf8.parse("!@CNET#$")});--%>
    console.log(decrypt.toString(CryptoJS.enc.Utf8));
</script>

</body>
</html>
