/* ------------------------------------------------------ */
// �� ��  �� ü : Initech Co., Ltd.
// ��   ��   �� : Seon Jong, Kim.
// �����ۼ����� : 2006. 10. 04
// ������������ : 2007. 10. 04
// ������������ : 2009. 03. 16 - IE8�� ��� ���� ����
/* ------------------------------------------------------ */

//INISAFE Web 7.0 Client ��ġ ���� ȯ�� ����------------------------------------------------------------------
var InstallVersion = "7,0,0,32";		//INISAFE Web Client 7.0 Installer ����
var IE8InstallVersion = "7,0,0,35";		//INISAFE Web Client 7.0 Installer ����
var RebootURL = location.href;		//���� ��ġ�Ǵ� PC�� IE�� ����� ��, �̶� �̵��� ������
var RebootMode = 1;					//IE�� ����� �ɶ� ���� �������� â�� ���� ��� 0, �������� â�� ������ ���μ������� ��� ���� ��� 1
var NoReboot = 0;				// ��ġ�� ������ ����Ʈ ��� : 0, ����Ʈ ������ : 1

//��Ƽ �ڵ彦��ŷ�� ����� �̷������ �ִ��� ȣ��Ʈ ���� ����͸� ��
//��ġ ������ ���� ���¸� ����� ��ü�� �־�� �� �� : <div id="mshStatus"></div>
var shttpMultiServerStatusCheck = true;

//���ÿ� ��彦��ŷ(SSO)�� ������ ����Ʈ(���� ������ ������ �ȳ־ ��)
var shttpMultiServerList = new Array(
	);

//Ŭ���̾�Ʈ�� �ٿ�ε� ���� �� �ִ� �ּҵ�("http://" �� ������ �ּҸ� ������.)
var DownloadURLs = new Array(
					location.host + "/shttp/install"
	);

//�ٿ�ε� �ε��� ����(����) �� ����
var DownloadIndex = parseInt(Math.random() * DownloadURLs.length);
var DownloadRoot = DownloadURLs[DownloadIndex];

//DLL �� Plugin �ٿ�ε� URL
var VcsURL = "http://" + DownloadRoot + "/dll/INIS70.vcs";		//INIS70.vcs �ٿ�ε� URL
var CharsetURL = "http://" + DownloadRoot + "/dll/Charset.vcs";	//Charset �� ���õ� URL
var DllURL = "http://" + DownloadRoot + "/dll/";				//DLL ������ �ٿ�ε� �޴� URL
var ExeURL = "http://" + DownloadRoot + "/down/INIS70.exe"		//���� ��ġ���� �ٿ�ε� �޴� URL

//IE8 �� DLL �� Plugin �ٿ�ε� URL
var IE8VcsURL = "http://" + DownloadRoot + "/dll_ie8/INIS70.vcs";		//INIS70.vcs �ٿ�ε� URL
var IE8CharsetURL = "http://" + DownloadRoot + "/dll_ie8/Charset.vcs";	//Charset �� ���õ� URL
var IE8DllURL = "http://" + DownloadRoot + "/dll_ie8/";				//DLL ������ �ٿ�ε� �޴� URL
var IE8ExeURL = "http://" + DownloadRoot + "/down_ie8/INIS70.exe"		//���� ��ġ���� �ٿ�ε� �޴� URL

//������ ȯ�� üũ
var appEnvCheck = 1;		//0 : üũ ����, 1 : üũ ��
var IEVersion = "5.5"		//���� ������ IE ����(üũ ���ҽ� ���ڿ� �Ǵ� �ּ� ����)
var XMLHTTPVersion = "3"	//���� ������ XMLHTTP ����(üũ ���ҽ� ���ڿ��� �Ǵ� �ּ� ����)

// SOE VISTA ���� üũ
var isSoeVista = false;
checkSoeVista();


//�����
//document.write("Ŭ���̾�Ʈ ��� �ٿ�ε� ��� : http://" + DownloadRoot);
//------------------------------------------------------------------------------------------------------------

//Ŭ���̾�Ʈ ��� ��ġ ������ ����ڿ��� �˷���
function install_error(){
	var errorMsg = "����� ��û �Ǵ� ������ ���� ��ȣȭ ����� ��ġ(�Ǵ� ������Ʈ)���� �ʾҽ��ϴ�.\r\n\r\n -. �� ����Ʈ�� ��ȣȭ ����� ��ġ�Ǿ�߸� �̿��Ͻ� �� �ֽ��ϴ�.\r\n -. ������ ���� ��ȣ�� ���� ��ȣȭ ����� ��ġ�� �ֽñ� �ٶ��ϴ�.\r\n -. ��ȣȭ ��� ��ġ�� �ȵ� ��� ��ġȭ�鿡 �ȳ��� �����Ͻñ� �ٶ��ϴ�.\r\n -. �������� XP ���� ��2 ����ڴ� ��ܿ� ��ġ ���� Ŭ���Ͻʽÿ�.\r\n -. ������ ���ѵ� ������� ��� �ݵ�� ������(Administrator) �������� ��ġ�Ͻñ� �ٶ��ϴ�.";

	try{
		if(typeof(InstallFail)=='function'){
			InstallFail(errorMsg);
			return;
		}
	}
	catch(e){}

	document.body.onload = "";
	alert(errorMsg);
}

//�÷����� �ѷ��ִ� �Լ�
function swf(src,w,h){
	html = '';
	html += '<object type="application/x-shockwave-flash" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" id="param" width="'+w+'" height="'+h+'">';
	html += '<param name="movie" value="'+src+'">';
	html += '<param name="wmode" value="transparent">';
	html += '<param name="quality" value="high">';
	html += '<param name="bgcolor" value="#ffffff">';
	html += '<param name="swliveconnect" value="true">';
	html += '<embed src="'+src+'" quality=high bgcolor="#ffffff" width="'+w+'" height="'+h+'" swliveconnect="true" id="param" name="param" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"><\/embed>';
	html += '<\/object>';
	document.write(html);
}

//Ŭ���̾�Ʈ Installer ActiveX �� ��ġ�ϴ� ������
function client_install(){
	if(isSoeVista) { // SOE Vista�� ��� cab ���� 32�� ����.
		document.write("<OBJECT ID='INISAFELoader' CLASSID='CLSID:39461460-2552-4D51-A062-3AB6A7B902E9' width=0 height=0 CodeBase='http://" + DownloadRoot + "/down/INIS70.cab#version=" + InstallVersion + "' OnError='install_error();' OnErrorUpdate='install_error();' style='position:absolute;top:0;left:0'><PARAM name='RebootURL' value='"+RebootURL+"'></PARAM><PARAM name='RebootMode' value='"+RebootMode+"'></PARAM><PARAM name='NoReboot' value='"+NoReboot+"'></PARAM></OBJECT>");
	}
	else { // �������� ��� 35����
		document.write("<OBJECT ID='INISAFELoader' CLASSID='CLSID:39461460-2552-4D51-A062-3AB6A7B902E9' width=0 height=0 CodeBase='http://" + DownloadRoot + "/down_ie8/INIS70.cab#version=" + IE8InstallVersion + "' OnError='install_error();' OnErrorUpdate='install_error();' style='position:absolute;top:0;left:0'><PARAM name='RebootURL' value='"+RebootURL+"'></PARAM><PARAM name='RebootMode' value='"+RebootMode+"'></PARAM><PARAM name='NoReboot' value='"+NoReboot+"'></PARAM></OBJECT>");
	}
}

//���� ��ġ ���α׷� �ٿ�ε�
function download_setup(){
	if(isSoeVista) {
		location.href = ExeURL;
	}
	else {
		location.href = IE8ExeURL;
	}
	return false;
}

//INISAFE Web v7 Client �� ��밡���� ȯ������ üũ��
function isPossibleApp(){
	if(appEnvCheck==0)
		return true;

	var userAgent = window.clientInformation.userAgent;
	var spos = userAgent.indexOf("MSIE");

	//������ �˻�
	if(spos<0){
		alert("�� ����Ʈ�� Microsoft Internet Explorer �迭�� ��� �����մϴ�.\r\n\r\n���� ������� ������ ���� : " + userAgent);
		return false;
	}
	else{
		if(typeof(IEVersion)!="undefined" && IEVersion!=""){
			spos += 5;
			var epos = userAgent.indexOf(";", spos);
			var ver = userAgent.substring(spos, epos);

			if(ver < IEVersion){
				alert("�� ����Ʈ�� Microsoft Internet Explorer " + IEVersion + " �̻� ��� �����մϴ�.\r\n���� â�� �ݰ� ������ ������Ʈ ����Ʈ(update.microsoft.com)�� ���� IE �ֽ� ������ ��ġ�Ͻñ� �ٶ��ϴ�.");
				return false;
			}
		}
	}

	//64��Ʈ �ü���� �����ϴ��� üũ��
	if(userAgent.indexOf("Win64")>=0){
		alert("�� ����Ʈ�� 64 Bit ���δ� ����Ͻ� �� �����ϴ�. 32 Bit ȣȯ ���� �����ϼ���.");
		return false;
	}

	//XMLHTTP ��ġ ���� �˻�
	if(typeof(XMLHTTPVersion)!="undefined" && XMLHTTPVersion!=""){
		try{
			var xml = new ActiveXObject("Msxml2.XMLHTTP." + XMLHTTPVersion + ".0");
		}
		catch(e){
			if(confirm("�� ����Ʈ�� Web 2.0 ���񽺸� ���� Microsoft XMLHTTP " + XMLHTTPVersion + ".0 �̻��� �ʿ�� �մϴ�.\r\nMicrosoft XMLHTTP " + XMLHTTPVersion + ".0 ��ġ ���α׷��� �ٿ�ε� �����ðڽ��ϱ�?")){
				alert("��ġ �� ���� â�� �ݰ� ���� �����Ͻñ� �ٶ��ϴ�.");
				location.href="http://" + DownloadRoot + "/down/msxml" + XMLHTTPVersion + ".msi";
				return false;
			}

			return false;
		}
	}

	return true;
}

function checkSoeVista()
{
    // 2009/03/26 IP�뿪�� ���� ���ȸ�� �ٿ�ε�
    var clientIP = '';
    var today = '';

    try {
        var cookieValue = "";
        var cookieName = "secip=";
        var allcookies = document.cookie;
        var pos = allcookies.indexOf(cookieName);
        if(pos != -1) {
            var start = pos + cookieName.length;
            var end = allcookies.indexOf(";", start);
            if(end == -1) end = allcookies.length;
            cookieValue = allcookies.substring(start, end);
            cookieValue = decodeURIComponent(cookieValue);
            var values = cookieValue.split("|");
            clientIP = values[0];
            today = values[1];
        }
    }catch(e) {
    }

    var aSOEProxyIP = new Array(
          "192.193.81.41"
        , "192.193.81.42"
        , "192.193.81.70"
        , "192.193.81.71"
        , "192.193.83.41"
        , "192.193.83.42"
        , "192.193.83.70"
        , "192.193.83.71"
    );

    for(var i=0; i<aSOEProxyIP.length; i++) {
        if(aSOEProxyIP[i] == clientIP) {
            if(window.navigator.appVersion.indexOf("NT 6") > 0) {
                isSoeVista = true;
            }
        }
    }

}
