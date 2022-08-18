<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>녹취관리 시스템</title>

	<link href="../css/bootstrap.css" rel="stylesheet" />
	<link href="../css/font-awesome.css" rel="stylesheet" />
	<link href="../css/animate.css" rel="stylesheet">
	<link href="../css/smoothness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
	<link href="../css/style.css" rel="stylesheet" />

	<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
	<script type="text/javascript" src="../js/jquery.cookie.js"></script>
	<script type="text/javascript" src="../js/plugins/metisMenu/metisMenu.js"></script>
	<script type="text/javascript" src="../js/bootstrap.js"></script>
	<script type="text/javascript" src="../js/site.js"></script>
	<script type="text/javascript" src="../js/common.js"></script>
</head>

<body>
<script type="text/javascript">
	$(function () 
	{
		$("button[name=btn_mon]").click(function() 
		{
			fnPopupView("mon");
		});
		
		$("button[name=btn_player]").click(function() 
		{
			fnPopupView("player");
		});

		$("button[name=btn_clientApi]").click(function() 
		{
			fnPopupView("clientApi");
		});
	
		//팝업 오픈
		var fnPopupView = function(step) 
		{
			var fvUrl = "";
			var fvParam = "";
			var fvTarger = "";
			var fvWidth = 556;
			var fvHeight = 376;
			if(step == "mon")
			{
				fvUrl = "../app/mon_app.jsp";
				fvTarger = "_mon_app";
				fvWidth = parseInt(screen.width)-400;
				fvHeight = parseInt(screen.height)-439;
			}
			else if(step == "player")
			{
				fvUrl = "../app/player.jsp";
				fvParam = "?info="+encodeURIComponent("20200925181220|20200901213610202|202");
				fvTarger = "_player";
				fvWidth = 556;
				fvHeight = 376;
			}
			else if(step == "clientApi")
			{
				fvUrl = "../app/clientApi.jsp";
				fvParam = "?REC=REC7&DN=200&DATA1=11&DATA2=22&DATA3=33&DATA4=한글&DATA5=55&DATA6=66&DATA7=77&DATA8=88&DATA9=1";
				
				fvTarger = "_clientApi";
				fvWidth = 200;
				fvHeight = 200;
			}			
			
			openPopup(fvUrl+fvParam, fvTarger, fvWidth, fvHeight, "yes","center");
			//openPopup(fvUrl+fvParam,fvWidth,popupHeight,"yes","center");			
			
			//location.replace("../rec_search/player.jsp?info="+encodeURIComponent(info));
		};
		
	});
</script>

<div class="loginColumns">
	<div class="loginRadius1">녹취관리 시스템 <span style="float:right; font-size: 14px;"><img alt='image' src='../img/logo/main_title_login.png' /></span></div>
	<div class="loginRadius2">
		<div class="form-box1">
			<form id="app" class="form-horizontal" method="post" >
				<div class="space01">APP TEST</div>
				<button type="button" name="btn_mon" class="btn btn-primary btn-sm">모니터링</button>
				<button type="button" name="btn_player" class="btn btn-primary btn-sm">청취</button>
				<button type="button" name="btn_clientApi" class="btn btn-primary btn-sm">연동 API</button>
			</form>
		</div>
	</div>
</div>

</body>
</html>