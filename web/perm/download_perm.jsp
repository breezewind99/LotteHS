<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"menu_perm","json")) return;


	try 
	{
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
	$(function () 
	{
		var colModel = [
			{ title: "IP", width: 400, dataIndx: "download_ip", editable: true},
			{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
					return "<img src='../img/icon/ico_delete.png' class='btn_delete'/>";
				}
			}
		];
	
		var baseDataModel = getBaseGridDM("<%=page_id%>");
		var dataModel = $.extend({}, baseDataModel, {
			sorting:"local",
			//sortIndx: "order_no",
			//sortDir: "up",
			recIndx: "row_id"
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		var baseObj = getBaseGridOption("download_perm", "N", "N", "Y", "Y");
		var obj = $.extend({}, baseObj, {
			colModel: colModel,
			dataModel: dataModel,
			flexWidth: true,
			numberCell:{resizable:true, title:"#"},
		});
	
		$grid = $("#grid").pqGrid(obj);

		// 등록 저장
		$("#regi button[name=modal_regi]").click(function() {
			if(!$("input[name=download_ip]").val().trim())
			{
				alert("다운로드 권한을 부여할 Ip를 입력해 주십시오.");
				$("input[name=download_ip]").focus();
				return false;
			}

			$.ajax({
				type: "POST",
				url: "remote_download_perm_proc.jsp",
				async: false,
				data: "step=insert&"+$("#regi").serialize(),
				dataType: "json",
				success:function(dataJSON){
					if(dataJSON.code == "OK")
					{
						alert("정상적으로 등록되었습니다.");
						$("#modalRegiForm").modal("hide");
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
		<div style="float:left;"><h4>접근보안 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 관리</a></li>
			 <li><a href="#none">접근보안 관리</a></li>
			 <li class="active"><strong>다운로드 접근권한</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--탭 메뉴 영역 -->
		<div class="panel blank-panel conSize">
			<div class="panel-heading">
				<div class="panel-options">
					<ul class="nav nav-tabs">
						<li class=""><a href="menu_perm.jsp">메뉴 접근권한</a></li>
						<li class=""><a href="search_perm.jsp">조회 접근권한</a></li>
						<li class=""><a href="result_perm.jsp">리스트 접근권한</a></li>
						<li class="active"><a href="download_perm.jsp">다운로드 접근권한</a></li>
					</ul>
				</div>
			</div>
		</div>
		<!--탭 메뉴 영역 끝 -->

		<!--Data table 영역-->
		<div class="contentArea" style="padding-top: 10px;">
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
			<!--팝업창 띠우기-->
			<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content animated fadeIn">
						<form id="regi">
							<div class="modal-header">
								<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
								<h4 class="modal-title">다운로드 IP 등록</h4>
							</div>
							<div class="modal-body" >
								<!--업무코드 table-->
								<table class="table top-line1 table-bordered2">
									<thead>
									<tr>
										<td style="width:40%;" class="table-td">다운로드 IP <span class="required">*</span></td>
										<td style="width:60%;">
											<input type="text" name="download_ip" class="form-control" id="" placeholder="">
										</td>
									</tr>
									</thead>
								</table>
								<!--업무코드 table 끝-->
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
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	}
%>
