<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%
	// 상담 APP 청취
	// http://localhost:8080/app/player.jsp?date=2022-08-23&keycode=00001025271661214629
	// https://cs-rec.lotteimall.com/app/player.jsp?rec_datm=2022-08-23&rec_keycode=00001025271661214629&user_id=test&user_name=%ED%85%8C%EC%8A%A4%ED%8A%B8
	// 내부 테스트용
	// http://localhost:8080/app/player.jsp?rec_datm=2022-08-23&rec_keycode=00001025181661206381&user_id=test&user_name=%ED%85%8C%EC%8A%A4%ED%8A%B8&reason_code=11
	// DB Connection Object
	Db db = null;

	try 
	{
		// DB Connection
		db = new Db(true);

		// get parameter
		String rec_datm = CommonUtil.getParameter("rec_datm");
		String rec_keycode = CommonUtil.getParameter("rec_keycode");
		String seq_no = CommonUtil.getParameter("seq");
		String user_id = CommonUtil.getParameter("user_id");
		String user_name = CommonUtil.getParameter("user_name");
		String reason_code = CommonUtil.getParameter("reason_code");
		String reason_text = CommonUtil.getParameter("reason_text");
		String rec_seq = CommonUtil.getParameter("rec_seq");

		
		// 파라미터 체크
		if(!CommonUtil.hasText(reason_code) && !CommonUtil.hasText(reason_text))
		{
			out.print("<script>location.replace('player_reason.jsp?rec_datm="+ rec_datm +"&rec_keycode="+ rec_keycode +"&user_id="+ user_id +"&user_name="+ user_name +"&rec_seq="+ rec_seq +"')</script>");
			return;
		}
		
		Map<String, Object> argMap = new HashMap<String, Object>();
		Map<String, Object> curdata = new HashMap();

		argMap.clear();
		argMap.put("seq_no",seq_no);
     	argMap.put("rec_keycode",rec_keycode);
     	argMap.put("rec_date",rec_datm);
				
		// 연관 녹취이력 조회
		List<Map<String, Object>> list = db.selectList("rec_search.selectRelationList", argMap);
		if(list.size() < 1) 
		{
			out.print(CommonUtil.getDocumentMsg(CommonUtil.getErrorMsg("NO_DATA"),"","close"));
			return;
		}

		logger.info("Seq : " + rec_seq);
		// 현재 클릭된 녹취이력 정보 별도 저장
		for(int i=0;i<list.size();i++) 
		{
			logger.info("Check Seq : " + list.get(i).get("rec_seq").toString());
			if(list.get(i).get("rec_seq").toString().equals(rec_seq))
			{
				curdata = list.get(i);
				break;
			}
		}

		// 파일명이 일치하는 데이터가 없을 경우 첫번째 이력으로 데이터 셋팅
		if(curdata.size() < 1) 
		{
			curdata = list.get(0);
			rec_seq = list.get(0).get("rec_seq").toString();
		}
		
		// S : 연관녹취이력 ===========================================
		String htmlRelateRecord = "";
		String dispRelateRecord = "";
		
		if(list.size() > 1) 
		{
			dispRelateRecord = "";
			for(Map<String, Object> item : list) 
			{
				htmlRelateRecord +=	"<tr class='" + (rec_seq.equals(item.get("rec_seq").toString()) ? "odd4" : "") + "'>";
				htmlRelateRecord +="<td>";
				htmlRelateRecord +="<a href='/app/player.jsp?rec_datm="+rec_datm+"&rec_keycode="+rec_keycode+"&user_id="+user_id+"&user_name="+user_name+"&rec_seq="+item.get("rec_seq")+"' >";
				htmlRelateRecord +="<u>" + item.get("rec_datm") + "</u></a></td>";
				htmlRelateRecord +="<td>" + item.get("rec_call_time") + "</td>";
				htmlRelateRecord +="<td>" + Mask.getMaskedName(item.get("user_name")) + "</td>";
				htmlRelateRecord +="<td>" + item.get("local_no") + "</td>";
				htmlRelateRecord +="<td>" + (item.get("cust_tel")!=null ? Mask.getMaskedPhoneNum(item.get("cust_tel").toString().trim()) : "") + "</td>";
				htmlRelateRecord +="</tr>";
			}
		}
		else
		{
			dispRelateRecord = "none";
		}
		// E : 연관녹취이력 ===========================================		

		// 청취 URL 생성
		String file_url = getListenURL2("LISTEN", curdata, logger,"");
		String file_url2 = getListenURL2("LISTEN", curdata, logger);

		String fft_ext = ("88".equals(curdata.get("system_code").toString())) ? "nmf" : "fft";
		if(file_url == null || "".equals(file_url)) 
		{
			out.print(CommonUtil.getDocumentMsg("녹취파일 경로를 가져 오는데 실패했습니다.","","close"));
		}

		if("ERR".equals(file_url.substring(0,3))) {
			out.print(CommonUtil.getDocumentMsg(file_url.substring(3),"","close"));
		}

		// 청취 이력 저장
		argMap.put("rec_seq","0");
		argMap.put("login_id",user_id);
		argMap.put("login_name",user_name);
		argMap.put("listen_ip",request.getRemoteAddr());
		argMap.put("rec_datm",rec_datm);
		argMap.put("rec_keycode",rec_keycode);
		argMap.put("rec_filename",curdata.get("rec_filename").toString());
		argMap.put("user_id",curdata.get("user_id").toString());
		argMap.put("user_name",curdata.get("user_name").toString());
		//argMap.put("local_no",station);
		argMap.put("local_no",curdata.get("local_no").toString());
		argMap.put("listen_src","O");
		argMap.put("reason_code",reason_code);
		argMap.put("reason_text",reason_text);

		/*청취이력 저장제거 20171227  */
		int ins_cnt = db.insert("hist_listen.insertListenHist", argMap);

		// 브라우저 체크
		String ua = request.getHeader("User-Agent");
		String profix = "mb";
		/*
		logger.info("☆☆☆☆☆☆");
		logger.info("ua : "+ua);
		logger.info("ua indexOf : "+ua.toLowerCase().indexOf("trident"));
		logger.info("☆☆☆☆☆☆");
		*/
		
		// IE8
//		if(ua.toLowerCase().indexOf("trident/4.0")>0)
		if(ua.toLowerCase().indexOf("trident") > 0) 
		{
			profix = "ie8";
		}

		// window media player 사용 설정
		//profix = "ie8";

%>
<jsp:include page="/include/popup.jsp" flush="false"/>
<title>청취 플레이어 </title>
<link href="../css/player_<%=profix%>.css" rel="stylesheet">
<link href="../css/player.css" rel="stylesheet">

<script type="text/javascript" src="../js/plugins/wave/waveform.js"></script>
<script type="text/javascript" src="../js/player_<%=profix%>.js"></script>
<script type="text/javascript" src="../js/player.js"></script>

<% if("mb".equals(profix)) { %>
<!-- <script type="text/javascript" src="../js/plugins/jplayer/jquery.jplayer.min.js"></script> -->
<script type="text/javascript" src="../js/plugins/wave/swfobject.js"></script>
<script type="text/javascript" src="../js/plugins/wave/wavesurfer.min.js"></script>
<script type="text/javascript" src="../js/plugins/wave/wavesurfer.swf.js"></script>
<% } %>

<script type="text/javascript">
	var file_url = "<%=file_url%>";
	var file_url2 = "<%=file_url2%>";
	var fft_ext = "<%=fft_ext%>";
	var rec_datm = "<%=rec_datm%>";
	var local_no = "<%=curdata.get("local_no").toString()%>";
	var rec_filename = "<%=curdata.get("rec_filename").toString()%>";

	//var wave_type = "canvas";
	//var wave_type = "img2";
	var wave_type = "img2";
</script>
</head>

<body class="white-bg">
<div id="container" style="width: 556px">
	<div class="memo-body">
	<!--녹음파일 파형 영역 시작-->
		<div id="outer_waveform" class="p-frame1 tableSize4">
			<div id="waveform"></div>
			<p id="curtime"></p>
		</div>
		<!--녹음파일 파형 영역 끝-->
		<!--플레이어 영역-->
		<% if("mb".equals(profix)) { %>
			<jsp:include page="../rec_search/player_mb.jsp" flush="false"/>
		<% } else { %>
			<jsp:include page="../rec_search/player_ie8_app.jsp" flush="false"/>
		<% } %>
		<!--플레이어 영역 끝-->

		<!--ibox 시작-->
		<div class="ibox hidden" id="ui-marking">
			<!--마킹하기 팝업창 띄우기-->
			<div class="p-dialog">
				<div class="p-content">
					<div class="p-header">
						<button type="button" class="close"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="p-title">마킹</h4>
					</div>
					<div class="p-body">
						<div class="cc">
							<form id="marking">
								<input type="hidden" name="rec_datm" value=""/>
								<input type="hidden" name="rec_filename" value=""/>
								<!-- <span>구분 &nbsp;</span>
								<input type="text" class="form-control play-form" id="" name="mk_name" placeholder=""> -->
								<span style="padding-right: 20px;"></span>
								<span>구간 &nbsp;</span>
								<input type="text" class="form-control play-form" name="mk_stime" placeholder="00:00:00"></li> ~
								<input type="text" class="form-control play-form" name="mk_etime" placeholder="00:00:00"></li>
								<button type="button" name="btn_marking" class="btn btn-primary btn-sm" onclick="regiMarking();">마킹</button>
							</form>
						</div>
					</div>
				</div>
			</div>
			<!--마킹하기 팝업창 끝-->
		</div>
		<!--ibox 끝-->

		<!--녹취 이력 정보 table-->
		<div class="tableSize4 p-space">
			<h5 style="margin-top:0;">녹취 이력 정보</h5>
			<table class="table top-line1 table-bordered2">
				<thead>
				<tr>
					<td style="width:35%;" class="table-td">녹취 일시</td>
					<td style="width:65%;"><%=curdata.get("rec_datm") %> (<%=curdata.get("rec_call_time") %>)</td>
				</tr>
				</thead>
				<tr>
					<td class="table-td">상담원 명(ID)</td>
					<td><%=curdata.get("user_name") %>(<%=curdata.get("user_id") %>)</td>
				</tr>
				<tr>
					<td class="table-td">내선 번호</td>
					<td><%=curdata.get("local_no")  %></td>
				</tr>
				<tr>
					<td class="table-td">고객 전화번호</td>
					<td><%=(curdata.get("cust_tel")!=null ? Mask.getMaskedPhoneNum(curdata.get("cust_tel").toString().trim()) : "") %></td>
				</tr>
			</table>
		</div>
		<!--녹취 이력 정보 table 끝-->
		
		<!--연관 녹취 이력 table-->
		<div class="tableSize4 p-space" style=display:<%=dispRelateRecord%>>
			<h5 style="margin-top:0;">연관녹취 이력</h5>
			<table class="table top-line1 table-bordered">
				<thead>
					<tr>
						<th style="width:35%;">녹취일시</th>
						<th style="width:23%;">통화시간</th>
						<th style="width:22%;">상담사명</th>
						<th style="width:20%;">내선번호</th>
						<th style="width:20%;">전화번호</th>
					</tr>
				</thead>
				<tbody>
				<%=htmlRelateRecord%>
				</tbody>
			</table>
		</div>
		<!--연관 녹취 이력 table 끝-->		

	</div>
</div>
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