<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"abort_hist","")) return;
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () 
{

	var colModel = [
		{ title: "순번", width: 60, dataIndx: "idx", sortable: false },
		{ title: "등록일시", width: 130, dataIndx: "abort_datm" },
		{ title: "상태", width: 130, dataIndx: "abort_state" },
		{ title: "필수중단 시작 일시", width: 130, dataIndx: "start_rec_datm" },
		{ title: "필수중단 종료 일시", width: 130, dataIndx: "end_rec_datm" },
		// { title: "대분류", width: 80, dataIndx: "bpart_name" },
		// { title: "중분류", width: 80, dataIndx: "mpart_name" },
		// { title: "소분류", width: 80, dataIndx: "spart_name" },
		{ title: "로그인ID", width: 80, dataIndx: "abort_id" },
		{ title: "로그인명", width: 80, dataIndx: "abort_name" },
		{ title: "로그인IP", width: 100, dataIndx: "abort_ip" },
		{ title: "SEQ", width: 100, dataIndx: "abort_seq",hidden:true },
		{ title: "취소", width: 40, editable: false, sortable: false, render: function (ui) {
			return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
			}
		}

	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		//sortIndx: "abort_datm",
		sortDir: "down",
	});

 	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("abort_hist", "Y", "Y", "N", "N");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		scrollModel: { autoFit: true },
	});

	$grid = $("#grid").pqGrid(obj);

 // 잠금해제 실행
	$grid.on("pqgridrefresh", function(event, ui) {
		$grid.find(".btn_delete")
		.unbind("click")
		.bind("click", function (evt) {
			if (confirm("정말로 취소 하시겠습니까?")) {
				var $tr = $(this).closest("tr");
				var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;

				var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
				var abort_seq = rowData["abort_seq"];


				var abort_state = rowData["abort_state"].replace(/\s|-|:|\./gi,"");

				if(abort_state=="취소"){
					alert("취소 된 건 입니다.");
					return false;
				}


				//cabort
				$.ajax({
					type: "POST",
					url: "remote_rec_abort_proc.jsp",
					async: false,
					data: "step=delete&abort_seq="+abort_seq,
					dataType: "json",
					success:function(dataJSON){
						if(dataJSON.code=="OK") {
							alert("정상적으로 취소 되었습니다.");
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

			}
		});
	});

	// 필수 중단 팝업 오픈
	$("button[name=btn_abort]").click(function() {
		$("#modalAbort").modal("toggle");
	});

	$("input[name=abort_date1]").mask("y999-m9-d9");
	$("input[name=abort_date2]").mask("y999-m9-d9");

	// 필수 중단 등록 버튼 클릭
	$("#modalAbort button[name=modal_regi]").click(function() {
		if(!$("#abort input[name=rec_date]").val().trim())
		{
			alert("날짜를 선택해 주십시오.");
			$("#abort input[name=rec_date]").focus();
			return false;
		}

		$.ajax({
			type: "POST",
			url: "remote_rec_abort_proc.jsp",
			async: false,
			data: "step=abort&"+$("#abort").serialize(),
			dataType: "json",
			success:function(dataJSON){
				if(dataJSON.code == "OK")
				{
					alert("정상적으로 업데이트 되었습니다.");
					$("#modalAbort").modal("hide");
					$grid.pqGrid("refreshDataAndView");
				}
				else
				{
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
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>필수중단 이력</h4></div>
		<ol class="breadcrumb" style="float:right;">
			<li><a href="#none"><i class="fa fa-home"></i> 이력</a></li>
			<li class="active"><strong>필수중단 이력</strong>	</li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">

	<!--ibox 시작-->
		<div class="ibox">
		<form id="search">
			<!--검색조건 영역-->
			<div class="ibox-content-util-buttons">
				<div class="ibox-content contentRadius1 conSize">
					<!--1행 시작-->
					<div class="SearchDiv">
						<div class="labelDiv">
							<label class="simple_tag">등록일자</label>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="abort_date1" class="form-control search_date datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
							<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="abort_date2" class="form-control search_date datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
						</div>
					</div>

					<div class="SearchDiv">
						<div class="labelDiv">
							<label class="simple_tag">로그인ID</label><input type="text" name="login_id" class="form-control search_input" placeholder="">
						</div>
					</div>

					<div class="SearchDiv">
						<div class="label_Div">
							<label class="simple_tag">로그인명</label><input type="text" name="login_name" class="form-control search_input" placeholder="">
					 	</div>
					</div>
					<!--1행 끝-->

					<!--2행 시작-->
					<div class="SearchDiv">
						<div class="labelDiv">
							<label class="simple_tag">녹취일자</label>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="rec_date1" class="form-control search_date datepicker" value="">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
							<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
							<!-- 달력 팝업 위치 시작-->
							<div class="input-group" style="display:inline-block;">
								<input type="text" name="rec_date2" class="form-control search_date datepicker" value="">
								<div class="input-group-btn">
									<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
								</div>
							</div>
							<!-- 달력 팝업 위치 끝-->
						</div>
					</div>
				</div>
				<!--검색조건 영역 끝-->

				<!--유틸리티 버튼 영역-->
				<div class="contentRadius2 conSize">

					<!--ibox 접히기, 설정버튼 영역-->
					<div class="ibox-tools">
						<button type="button" name="btn_abort" class="btn btn-default btn-sm" style='display:<%=ComLib.getCssDisplayStr(Finals.isExistPilsooJungdan)%>'><i class="fa fa-ban"></i> 필수중단</button>
					</div>
					<!--ibox 접히기, 설정버튼 영역 끝-->
					<div style="float:right">
						<button type="button" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button>
						<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
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
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
			<!-- 필수 중단 콜 -->
			<div class="modal inmodal" id="modalAbort" tabindex="-1" role="dialog"  aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content animated fadeIn">
						<form id="abort">
							<div class="modal-header">
								<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
								<h4 class="modal-title">필수중단 업데이트</h4>
							</div>
							<div class="modal-body">
								<table class="table top-line1 table-bordered2">
									<thead>
									<tr>
										<td style="width:25%;" class="table-td">날짜 <span class="required">*</span></td>
										<td style="width:75%; padding: 6px 9px;">
											<div class="input-group" style="display:inline-block;">
												<input type="text" name="rec_date" class="form-control search_date datepicker" value="<%=ComLib.getNowDate()%>" style="z-index: 99999;">
												<div class="input-group-btn" style="display:block;">
													<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
												</div>
											</div>
										</td>
									</tr>
									</thead>
									<tr>
										<td class="table-td">시간 <span class="required">*</span></td>
										<td style="padding: 6px 9px;">
											<input class="form-control search_time" type="time" name="rec_start_time" value="<%=ComLib.getNowTime()%>"> ~ <input class="form-control search_time" type="time" name="rec_end_time" value="<%=ComLib.getNowTime()%>">
										</td>
									</tr>
								</table>
							</div>
							<div class="modal-footer">
								<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop=""><i class="fa fa-pencil"></i> 등록</button>
								<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
							</div>
						</form>
					</div>
				</div>
			</div>
			<!-- 필수 중단 콜 끝 -->
		</div>
		<!--Data table 영역 끝-->
	</div>
	<!--wrapper-content영역 끝-->

<jsp:include page="/include/bottom.jsp"/>
