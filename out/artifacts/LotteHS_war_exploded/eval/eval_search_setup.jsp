<%
/*
	2017. 11. 13
	connick
	검색 조건 관리
*/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	Db db = null;

	try {
		db = new Db(true);
		Map<String, Object> argMap = new HashMap<String, Object>();
	
	
		//이벤트 콤보박스
		String htm_event_list = Site.getEventComboHtml("2N5", "eval_order_max");
		
		String user_id = _LOGIN_ID.replaceAll(System.getProperty("line.separator"), " ");

%>

<jsp:include page="/include/top.jsp" flush="false"/>

<script type="text/javascript">
	$(function() {
		var colModel = [
			{ title: "순번", maxWidth: 60, align: "center", dataIndx: "idx", editable: false, sortable: false },
			{ title: "이벤트명", minWidth: 130, align: "center", dataIndx: "event_name", editable: false },
			{ title: "녹취일자", align: "center", colModel: [{ title: "시작일", align: "center", minWidth: 80, editable: false, dataIndx: "ss_fdate" }, { title: "종료일", align: "center", minWidth: 80, editable: false, dataIndx: "ss_tdate" }] },
			{ title: "녹취시간", align: "center", colModel: [{ title: "시", align: "center", minWidth: 50, editable: false, sortable: false, dataIndx: "ss_fhour" }, { title: "분", minWidth: 50, align: "center", editable: false, sortable: false, dataIndx: "ss_fminute" }, { title: "시", minWidth: 50, align: "center", editable: false, sortable: false, dataIndx: "ss_thour" }, { title: "분", minWidth: 50, align: "center", editable: false, sortable: false, dataIndx: "ss_tminute" }] },
			{ title: "통화시간", align: "center", colModel: [{ title: "초", align: "center", minWidth: 50, editable: false, sortable: false, dataIndx: "ss_ftime" }, { title: "초", minWidth: 50, align: "center", editable: false, sortable: false, dataIndx: "ss_ttime" }] },
			{ title: "수정", align: "center", maxWidth: 30, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_edit.png' class='btn_edit' onclick='editEval("+ui.rowIndx+");'/>";
			}},
			{ title: "삭제", align: "center", maxWidth: 30, editable: false, sortable: false, render: function (ui) {
				return "<img src='../img/icon/ico_delete.png' class='btn_delete' onclick='deleteEval("+ui.rowIndx+");'/>";
			}}
		];
	
		var baseDataModel = getBaseGridDM("<%=page_id%>");
		var dataModel = $.extend({}, baseDataModel, {
			sorting:"local",
			//sortIndx: "order_no",
			//sortDir: "up",
			recIndx: "idx"
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		var baseObj = getBaseGridOption("eval_search_setup", "Y", "N", "Y", "N");
		var obj = $.extend({}, baseObj, {
			colModel: colModel,
			dataModel: dataModel,
			scrollModel: { autoFit: true }
		});
	
		$grid = $("#grid").pqGrid(obj);

		// 팝업 초기화 - CJM(20200721)
		$("#modalRegiForm").on('hidden.bs.modal', function(){
			$('#event_code_combo').removeAttr('disabled');
			$("#step").val("insert");
		});
	
		$("#regi button[name=modal_regi]").click(function() {
			if ($("select[name=event_code_combo]").val() == "") {
				alert("이벤트를 선택해 주세요.");
				return false;
			}
			//$("#regi").attr("action", "remote_eval_search_setup_proc.jsp").submit();
			
			$.ajax({
				type: "POST",
				url: "remote_eval_search_setup_proc.jsp",
				async: false,
				data: $("#regi").serialize(),
				dataType: "json",
				success:function(dataJSON){
					if(dataJSON.code=="OK") {
						alert("정상적으로 등록되었습니다.");
						$("#step").val("insert");
						$("#modalRegiForm").modal("hide");
						$grid.pqGrid("refreshDataAndView");
						
					} else {
						alert(dataJSON.msg);
						return false;
					}
				},
				error:function(req,status,err){
					alertJsonErr(req,status,err);
					return false;
				}
			});
			
		});
	});
	
	
	//결과 삭제
	function deleteEval(rowIndx) {
		var data	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
		//alert(data.ss_seq);
		deleteRowByData("eval_search_setup", rowIndx);
	}
	
	// 수정
	function editEval (rowIndx) {
		var data	= $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
	
		var event_code = $.trim(data.event_code);
		var event_status = $.trim(data.event_status);
		var ss_fdate = $.trim(data.ss_fdate);
		var ss_tdate = $.trim(data.ss_tdate);
		var ss_fhour = $.trim(data.ss_fhour);
		var ss_thour = $.trim(data.ss_thour);
		var ss_fminute = $.trim(data.ss_fminute);
		var ss_tminute = $.trim(data.ss_tminute);
		var ss_ftime = $.trim(data.ss_ftime);
		var ss_ttime = $.trim(data.ss_ttime);
		var ss_seq = $.trim(data.ss_seq);
		var eval_order_max = $.trim(data.eval_order_max);
	
		if (event_status == 2) {
			event_status = 1;
		}
		var event_val = event_code + "/" + eval_order_max;
		
		//$("#event_code_combo").val(event_val);
		$("#regi select[name=event_code_combo]").val(event_val).prop("selected", true);
		$("#event_code_combo").attr("disabled", "true");
		
		$("input[name=rec_date1]").val(ss_fdate);
		$("input[name=rec_date2]").val(ss_tdate);
		$("#rec_start_hour1").val(ss_fhour);
		$("#rec_start_hour2").val(ss_thour);
		$("#rec_start_min1").val(ss_fminute);
		$("#rec_start_min2").val(ss_tminute);
		$("#rec_call_time1").val(ss_ftime);
		$("#rec_call_time2").val(ss_ttime);
		$("#ss_seq").val(ss_seq);
		$("#step").val("update");
		
		$("#modalRegiForm").modal("show");
		
	}
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>조회 조건 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 평가 관리</a></li>
			 <li class="active"><strong>조회 조건 관리</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--Data table 영역-->
		<div class="contentArea" style="padding-top: 10px;">
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
			
			<!--팝업창 띠우기-->
			<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content animated fadeIn">
						<form id="regi" method="get">
						<input type="hidden" name="step" id="step" value="insert">
						<input type="hidden" name="ss_seq" id="ss_seq" value="">
							<div class="modal-header">
								<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
								<h4 class="modal-title">조회 조건 등록</h4>
							</div>
							<div class="modal-body">
								<!--조건 영역 table-->
								<table class="table top-line1 table-bordered2">
									<thead>
									<tr>
										<td style="width:40%;" class="table-td">이벤트 <span class="required">*</span></td>
										<td style="width:60%;">
											<select class="form-control result_form3" name="event_code_combo" id="event_code_combo">
												<option value="">선택하세요</option>
												<%=htm_event_list%>
											</select>
											<input type=hidden name=event_code>
										</td>
									</tr>
									</thead>
									<tr>
										<td class="table-td">녹취일자 <span class="required">*</span></td>
										<td>
											<!-- 달력 팝업 위치 시작-->
											<div class="input-group" style="display:inline-block;">
												<input type="text" name="rec_date1" class="form-control eva_form4" value="<%=DateUtil.getToday("")%>">
											</div>
											<!-- 달력 팝업 위치 끝-->
											<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
											<!-- 달력 팝업 위치 시작-->
											<div class="input-group" style="display:inline-block;">
												<input type="text" name="rec_date2" class="form-control eva_form4" value="<%=DateUtil.getToday("")%>">
											</div>
											<!-- 달력 팝업 위치 끝-->
										</td>
									</tr>
									<tr>
										<td class="table-td">녹취시간 <span class="required">*</span></td>
										<td>
											<select class="form-control" name="rec_start_hour1" id="rec_start_hour1" style=width:54px>
												<script>
												for(var i=0; i<24; i++){
													var hour = fillLeft(i,"0",2);
													document.writeln("<option value='"+hour+"'>"+hour+"시</option>");
												}
												</script>
											</select
											><select class="form-control" name="rec_start_min1" id="rec_start_min1" style=width:54px>
												<script>
												for(var i=0; i<=55; i+=5){
													var min = fillLeft(i,"0",2);
													document.writeln("<option value='"+min+"'>"+min+"분</option>");
												}
												</script>
											</select> ~
											<select class="form-control" name="rec_start_hour2" id="rec_start_hour2" style=width:54px>
												<script>
												for(var i=0; i<24; i++){
													var hour = fillLeft(i,"0",2);
													document.writeln("<option value='"+hour+"' "+((i==23) ? "selected='selected'" : "")+">"+hour+"시</option>");
												}
												</script>
											</select
											><select class="form-control" name="rec_start_min2" id="rec_start_min2" style=width:54px>
												<script>
												for(var i=0; i<=55; i+=5){
													var min = fillLeft(i,"0",2);
													document.writeln("<option value='"+min+"'>"+min+"분</option>");
												}
												</script>
												<option value='59' selected='selected'>59분</option>
											</select>
										</td>
									</tr>
									<tr>
										<td class="table-td">통화시간 <span class="required">*</span></td>
										<td>
											<select class="form-control eva_form5" name="rec_call_time1" id="rec_call_time1">
												<option value="0" selected="selected">0초</option>
												<script>
												for(var i=5; i<=59; i++){
													document.writeln("<option value='"+i+"'>"+i+"초</option>");
												}
												</script>
												<option value="60">1분</option>
												<option value="120">2분</option>
												<option value="180">3분</option>
												<option value="240">4분</option>
												<option value="300">5분</option>
												<option value="600">10분</option>
											</select> ~
											<select class="form-control eva_form5" name="rec_call_time2" id="rec_call_time2">
												<script>
												for(var i=5; i<=59; i++){
													document.writeln("<option value='"+i+"'>"+i+"초</option>");
												}
												</script>
												<option value="60">1분</option>
												<option value="120">2분</option>
												<option value="180">3분</option>
												<option value="240">4분</option>
												<option value="300">5분</option>
												<option value="600">10분</option>
												<option value="3600">60분</option>
												<option value="36000">60분 이상</option>
											</select>
										</td>
									</tr>
								</table>
								<!--메뉴 코드 영역 table 끝-->
							</div>
							<div class="modal-footer">
								<button type="button" name="modal_regi" class="btn btn-primary btn-sm"><i class="fa fa-pencil"></i> 등록</button>
								<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
							</div>
						</form>
					</div>
				</div>
			</div>
			<!--팝업창 띠우기 끝-->
		</div>
		<!--Data table 영역 끝-->
	</div>
	<!--wrapper-content영역 끝-->
<jsp:include page="/include/bottom.jsp"/>
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