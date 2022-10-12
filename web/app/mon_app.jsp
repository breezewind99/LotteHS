<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	Db db = null;

	try 
	{
		db = new Db(true);
		
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("login_level", "A");
		argMap.put("login_business_code", "01");
		argMap.put("bpart_code", "");
		argMap.put("mpart_code", "");
		argMap.put("spart_code", "");
		
		// 사용자 권한에 따른 조직도 대분류 조회
		String htm_bpart_list = Site.getMyPartCodeComboHtml(argMap, 1);
		String htm_mpart_list = Site.getMyPartCodeComboHtml(argMap, 2);
		String htm_spart_list = Site.getMyPartCodeComboHtml(argMap, 3);
		
		// 서버 아이피 조회
		String server_ip = request.getServerName();
%>

<!DOCTYPE html>
<html>
<head>
	<link rel="icon" href="../img/icon/main.ico" type="image/x-icon" />
	<link rel="shortcut icon" href="../img/icon/main.ico" type="image/x-icon" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="-1" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>녹취관리 시스템</title>
	<link href="../css/smoothness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
	<link href="../css/bootstrap.css" rel="stylesheet" />
	<link href="../css/font-awesome.css" rel="stylesheet" />
	<link href="../css/animate.css" rel="stylesheet">
	<link href="../css/grid/pqgrid.min.css" rel="stylesheet" />
	<link href="../css/grid/office/pqgrid.css" rel="stylesheet" />
	<link href="../css/style.css" rel="stylesheet" />	

	<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
	<script type="text/javascript" src="../js/jquery.number.min.js"></script>
	<script type="text/javascript" src="../js/jquery.cookie.js"></script>
	<script type="text/javascript" src="../js/jquery.resize.js"></script>
	<script type="text/javascript" src="../js/bootstrap.js"></script>
	<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
	<!-- 왼쪽메뉴 하위메뉴 접혀지고 펼쳐지는 소스 -->
	<script type="text/javascript" src="../js/plugins/metisMenu/metisMenu.js"></script>
	<!-- 왼쪽메뉴 부드럽게 접히는 소스 -->
	<script type="text/javascript" src="../js/plugins/pace/pace.min.js"></script>
	<script type="text/javascript" src="../js/plugins/grid/pqgrid.min.js"></script>
	<script type="text/javascript" src="../js/site.js"></script>
	<script type="text/javascript" src="../js/common.js"></script>
	<script type="text/javascript" src="../js/commItemz.js"></script>
	<script type="text/javascript" src="../js/finals.js"></script>
	
	<script type="text/javascript">
		var mon = null;
		var timer = null;
		var sec = 1;
		
		var server_url = "<%=Finals.SERVER_URL%>";
		
		$(function () 
		{
			// 모니터링 시작
			var startMon = function() {
				getMonData();
		
				var mon_sec = $("select[name=mon_sec]").val()*1000;
				mon = setInterval(function() {
					sec = 0;
					getMonData();
				}, mon_sec);
		
				startTimer();
				// 상태 표시
				$("input[name=mon_status]").val("시작");
			}
		
			// 모니터링 중지
			var stopMon = function() {
				clearInterval(mon);
				stopTimer();
				// 상태 표시
				$("input[name=mon_status]").val("중지");
			};
		
			// 모니터링 데이터 조회
			var getMonData = function() {
				var url = "remote_mon_app.jsp";
				var param = { bpart_code: $("select[name=bpart_code]").val()
								, mpart_code: $("select[name=mpart_code]").val()
								, spart_code: $("select[name=spart_code]").val()
								, local_no: $("input[name=local_no]").val()
				};
		
				$("#mon").load(url, param, function(response, status, xhr){
					
					if(status=="error") {
						$(this).html("데이터를 가져오는데 실패했습니다. [" + xhr.status + " : " + xhr.statusText + "]");
					}
				});
			};
			
			// timer 시작
			var startTimer = function() {
				timer = setInterval(function() {
					++sec;
					$("#timer").html(sec+"초");
				}, 1000);
			};
		
			// timer 중지
			var stopTimer = function() {
				clearInterval(timer);
				sec = 1;
				$("#timer").html("");
			};
		
			// 시작 버튼 클릭
			$("button[name=mon_start]").click(function(){
				// 기존 mon 중지 후 start
				stopMon();
				startMon();
			});
		
			// 중지 버튼 클릭
			$("button[name=mon_stop]").click(function(){
				stopMon();
			});
		
			// 조직도 변경 시 모니터링 재시작
			$("select[name=bpart_code], select[name=mpart_code], select[name=spart_code]").change(function() {
				// 기존 mon 중지 후 start
				stopMon();
				startMon();
			});
			
			/*
			조직도 정보 노출 기능 강화 - CJM(20200421)
			조직 정보 누락되는 현상 개선
		
			if(($('select[name=mpart_code]').size() == 1 && $('select[name=mpart_code]').val() == ""))		$('select[name=bpart_code]').change();
			else if(($('select[name=spart_code]').size() == 1 && $('select[name=spart_code]').val() == ""))	$('select[name=mpart_code]').change();			
			*/
			// 자동 시작
			startMon();
		});
		
		//감청 플레이어 오픈
		var playRlisten = function(status, ch_no, local_no, system_ip) {
			// 녹취상태일 경우만 감청 플레이어 오픈
			if(status == "1") 
			{
				//ActiveX 대체 방안 확인 - CJM(20190104)
				//console.log("cnettech://"+system_ip+","+parseInt(ch_no)+","+local_no);
				hiddenFrame.location = "cnettech://"+system_ip+","+parseInt(ch_no)+","+local_no;
			}
		};
		
		//감청 플레이어 설치
		var fnPlayerIns = function() 
		{
			hiddenFrame.location = "../Setup/Setup.msi";
		};
		
	</script>	
	
</head>

<body style="overflow-y: scroll;">
<!--wrapper 시작-->
<div id="wrapper">

	<!--wrapper-content영역-->
	<div class="wrapper-content">

		<!--ibox 시작-->
		<div class="ibox">
		<form id="search">
			<!--검색조건 영역-->
			<div class="ibox-content-util-buttons">
				<div class="ibox-content contentRadius1 conSize">
					<!--1행 시작-->
					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">조직도</label>
							<select class="form-control rec_form2" name="bpart_code">
								<%=htm_bpart_list%>
							</select> :
							<select class="form-control rec_form2" name="mpart_code">
								<option value="">중분류</option>
								<%=htm_mpart_list%>
							</select> :
							<select class="form-control result_form2" name="spart_code">
								<%=htm_spart_list%>
							</select>
							<input type="hidden" name="perm_check" value="0"/>
							<input type="hidden" name="it_business_code" value="01"/>
						</div>
					</div>
					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">내선번호</label>
							<input type="text" name="local_no" class="form-control rec_form5" value="">
						</div>
					</div>
					<!--1행 끝-->
					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">조회간격</label>
							<select class="form-control rec_form5" name="mon_sec">
								<option value="5">5초</option>
								<option value="10" selected="selected">10초</option>
								<option value="20">20초</option>
								<option value="30">30초</option>
								<option value="40">40초</option>
								<option value="50">50초</option>
								<option value="60">60초</option>
							</select>
						</div>
					</div>
					<!--2행 시작-->
					<div id="recDiv3">
						<div id="labelDiv">
							<label class="simple_tag">상태</label>
							<input type="text" name="mon_status" class="form-control rec_form5" value="시작" readonly="readonly">
							&nbsp; <span id="timer"></span>
						</div>
					</div>
					<!--2행 끝-->
				</div>
				<!--검색조건 영역 끝-->

				<!--유틸리티 버튼 영역-->
				<div class="contentRadius2 conSize">
					<!--ibox 접히기, 설정버튼 영역-->
					<div class="ibox-tools blank">
						<!--<a class="collapse-link">
							<button type="button" class="btn btn-default btn-sm"><i class="fa fa-chevron-up"></i> </button>
						</a>-->
					</div>
					<!--ibox 접히기, 설정버튼 영역 끝-->
					<div style="float:left">
						<button type="button" name="test" class="btn btn-down btn-sm" onclick="fnPlayerIns();"><i class="fa fa-download"></i> 감청 플레이어 설치</button>
					</div>
					<div style="float:right">
						<button type="button" name="mon_start" class="btn btn-primary btn-sm"><i class="fa fa-play"></i> 시작</button>
						<button type="button" name="mon_stop" class="btn btn-danger btn-sm"><i class="fa fa-stop"></i> 중지</button>
						
					</div>
				</div>
				<!--유틸리티 버튼 영역 끝-->
			</div>

			<!--ibox 접히기, 설정버튼 영역2-->
			<div class="ibox-tools2">
				<a class="collapse-link2">
					<div class="ibox-tools2-btn"><i class="fa fa-caret-up"></i></div>
				</a>
			</div>
			<!--ibox 접히기, 설정버튼 영역2 끝-->
		</form>
		</div>
		<!--ibox 끝-->

		<!--Data table 영역-->
		<div class="contentArea">
			<!--mon 영역-->
			<div id="mon"></div>
			<div id="mon2"></div>
			<!--mon 영역 끝-->
		</div>
		<!--Data table 영역 끝-->
	</div>
	<!--wrapper-content영역 끝-->
</div>
<iframe id="hiddenFrame" name="hiddenFrame" style="width:100%;height:300px;display:none"></iframe>
</body>
</html>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	}
	finally 
	{
		if(db != null)	db.close();
	}
%>