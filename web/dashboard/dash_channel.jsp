<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>녹취관제 시스템</title>

	<link href="../css/smoothness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
	<link href="../css/bootstrap.css" rel="stylesheet" />
	<link href="../css/font-awesome.css" rel="stylesheet" />
	<link href="../css/dashboard.css" rel="stylesheet" />

	<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="../js/jquery.number.min.js"></script>
	<script type="text/javascript" src="../js/jquery.cookie.js"></script>
	<script type="text/javascript" src="../js/jquery.resize.js"></script>
	<script type="text/javascript" src="../js/bootstrap.js"></script>
	<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
	<script type="text/javascript" src="../js/common.js"></script>
	<script type="text/javascript" src="../js/dashboard.js"></script>
	<script type="text/javascript">
		$(function(){

		});
	</script>
</head>

<body style="background-color:#ffffff; color:#232836; ">
	<!--wrapper 시작-->
	<div id="wrapper">
		<div class="container">
			<!-- 
			<div class="ol_top">
				<div class="ol_top_left"></div>
				<div class="ol_top_bg"></div>
				<div class="ol_top_right"></div>
			</div>
			 -->
			<div class="ol_md">
				<!-- <div class="ol_md_left"></div> -->
				<div class="ol_md_bg" style="background-color:#ffffff;">
					<div class="cont_head clearfix">
						<div class="tit"><strong>채널 모니터링</strong></div>
						<div class="nav">
							<input type="text" id="dash_sec" name="dash_sec" class="form-control" value="10" style="width: 40px;"/> 초 &nbsp;
							<button type="button" id="btn_dash" name="btn_dash" class="btn btn-warning btn-sm"><i class="fa fa-ban"></i> 중지</button> &nbsp;
							<span id="dash_text">모니터링 중</span>
							<span id="dash_timer">(1초)</span> &nbsp;
						</div>
					</div>
					<!-- 데이터 영역 -->
					<div id="channel"></div>
					<!--// 데이터 영역 -->
				</div>
				<!--<div class="ol_md_right"></div>-->
			</div>
			 <!-- 
			<div class="ol_bm">
				<div class="ol_bm_left"></div>
				<div class="ol_bm_bg"></div>
				<div class="ol_bm_right"></div>
			</div>
			 -->
		</div>
	</div>
</body>
</html>