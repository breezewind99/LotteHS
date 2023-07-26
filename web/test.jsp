<%@ include file="/common/aes.jsp" %>
<%@ include file="/common/common.jsp" %>
<%
	String temp = encryptMsg("01098580428");
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
    var decrypt = CryptoJS.AES.decrypt("<%=temp%>>", rkEncryptionKey, {mode: CryptoJS.mode.CBC, padding: CryptoJS.pad.Pkcs7, iv: rkEncryptionIv});
    console.log(decrypt.toString(CryptoJS.enc.Utf8));
</script>

</body>
</html>
