<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"sheet","close")) return;

	Db db = null;

	try 
	{
		db = new Db(true);
		
		String event_code = CommonUtil.getParameter("event_code");
		//System.out.println("event_code : "+event_code);
%>
<jsp:include page="/include/popup.jsp" flush="false"/>
<title>시트 보기</title>
<script type="text/javascript">
	$(function () {
		var colModel = [
			{ title: "순번", maxWidth: 60, align: "center", dataIndx: "idx", editable: false, sortable: false },
			{ title: "이벤트명", minWidth: 130, align: "center", dataIndx: "event_name", editable: false, sortable: false },
			{ title: "녹취일자", align: "center", colModel: [{ title: "시작일", align: "center", minWidth: 80, editable: false, dataIndx: "ss_fdate" }, { title: "종료일", align: "center", minWidth: 80, editable: false, dataIndx: "ss_tdate" }] },
			{ title: "녹취시간", align: "center", colModel: [{ title: "시", align: "center", width: 50, editable: false, dataIndx: "ss_fhour" }, { title: "분", width: 50, align: "center", editable: false, dataIndx: "ss_fminute" }, { title: "시", width: 50, align: "center", editable: false, dataIndx: "ss_thour" }, { title: "분", width: 50, align: "center", editable: false, dataIndx: "ss_tminute" }] },
			{ title: "통화시간", align: "center", colModel: [{ title: "초", align: "center", width: 50, editable: false, dataIndx: "ss_ftime" }, { title: "초", width: 50, align: "center", editable: false, dataIndx: "ss_ttime" }] },
			{ title: "선택", width: 40, align: "center", editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_view.png' class='btn_view' onclick='geCellText(" + ui.rowIndx + ");' style='cursor: pointer;'/>";
			}
		}
		];
		//eval_search_setup -> popup_eval_search_setup 변경 - CJM(20180510)
		var baseDataModel = getBaseGridDM("popup_eval_search_setup");
		var dataModel = $.extend({}, baseDataModel, {
			sorting:"local",
			//sortIndx: "order_no",
			//sortDir: "up",
			recIndx: "idx"
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		//eval_search_setup -> popup_eval_search_setup 변경 - CJM(20180510)
		var baseObj = getBaseGridOption("popup_eval_search_setup", "N", "N", "N", "N");
		var obj = $.extend({}, baseObj, {
			colModel: colModel,
			dataModel: dataModel,
			scrollModel: { autoFit: true }
		});
	
		$grid = $("#grid").pqGrid(obj);
	
		// 닫기 버튼 클릭
		$("button[name=btn_close], button[name=btn_pop_close]").click(function() {
			self.close();
		});
	});
	
	function geCellText(rowIndx) {
		var data =  $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
	
		var ss_fdate = $.trim(data.ss_fdate);
		var ss_tdate = $.trim(data.ss_tdate);
		var ss_fhour = $.trim(data.ss_fhour);
		var ss_thour = $.trim(data.ss_thour);
		var ss_fminute = $.trim(data.ss_fminute);
		var ss_tminute = $.trim(data.ss_tminute);
		var ss_ftime = $.trim(data.ss_ftime);
		var ss_ttime = $.trim(data.ss_ttime);
	
		$(opener.document).find("#rec_date1").val(ss_fdate);
		$(opener.document).find("#rec_date2").val(ss_tdate);
		$(opener.document).find("#rec_start_hour1").val(ss_fhour);
		$(opener.document).find("#rec_start_hour2").val(ss_thour);
		$(opener.document).find("#rec_start_min1").val(ss_fminute);
		$(opener.document).find("#rec_start_min2").val(ss_tminute);
		$(opener.document).find("#rec_call_time1").val(ss_ftime);
		$(opener.document).find("#rec_call_time2").val(ss_ttime);
		
		self.close();
	}
</script>

<body class="white-bg">
<div id="container" style="width: 900px; padding: 2px;">
		<form id="search">
			<input type="hidden" name="event_code" value="<%=event_code%>"/>
		</form>			
	<div class="popup-header">
		<button type="button" name="btn_pop_close" class="close"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
		<h4 class="popup-title">검색 조건</h4>
	</div>
	<div class="memo-body tableRadius2" style="padding-top: 20px;">
		<!--grid 영역-->
		<div id="grid"></div>
		<!--grid 영역 끝-->
	</div>
	<div class="text-center" style="margin: 15px 0;">
		<button type="button" name="btn_close" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 닫기</button>
	</div>
</div>
</body>

</html>
<%
	} 
	catch(Exception e) 
	{
		logger.error(e.getMessage());
	} 
	finally 
	{
		if(db != null)	db.close();
	}
%>