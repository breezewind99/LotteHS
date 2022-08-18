<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// 메뉴 접근권한 체크
	if(!Site.isPmss(out,"average_stat","")) return;
	
	try 
	{
		// 이벤트 콤보박스
		// 상태값 진행중인 이벤트 select CJM 20180514
		//String htm_event_list = Site.getEventComboHtml("5", "sheet_code");//2:진행중, 5:마감, 9:종료
		String htm_event_list = Site.getEventComboHtml("2", "sheet_code");//2:진행중, 5:마감, 9:종료
	
		//조직도 콤보박스
		String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
		String htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
		String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<style>
.red {background-color:brown;color:yellow;}
</style>
<script type="text/javascript">
	//항목타이틀 부터 구하고 데이터 구하기 위해 전역 변수로 뺌
	var dataModel;
	//항목 타이틀 정보
	var itemData;
	
	var colModel = [
		{ title: "부서", width: 150, dataIndx: "part_name", render: function(ui) {
			return (ui.rowData["part_name"]) ? ui.rowData["part_name"] : ui.rowData["bpart_name"]+"<font color=gray> > </font>"+ui.rowData["mpart_name"];
		}},
		{ title: "인원", width: 80, align:"center", dataIndx: "eval_cnt" },
		{ title: "총점", width: 80, align:"center", dataIndx: "tot_score" },
	
	];
	
	$(function () 
	{
		$("#search select[name=event_code_combo]").change(function(){
			chgEventCode();
		});
	
		var baseDataModel = getBaseGridDM("<%=page_id%>");
		dataModel = $.extend({}, baseDataModel, {
			sorting: "local",
			//sortIndx: "rec_date",
			sortDir: "up",
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		var baseObj = getBaseGridOption("<%=page_id%>", "N", "N", "N", "N");
	
		baseObj.toolbar.items.push(
				// 엑셀다운로드 버튼 추가
				{ type:	"button", icon:	"ui-icon-excel", label:	"엑셀", style: 'float: right;	margin-right: 5px;', listeners:	[{
						"click": function () {
							var data = $grid.pqGrid("option","dataModel.data");
							var args = {"data":objToStr(data), "itemData":objToStr(itemData)};
							makeFormAndGo("fExcel", "excel_<%=page_id%>.jsp", "hiddenFrame", args);
					}
				}]
			}
		);
	
		/*
		baseObj.toolbar.items.push(
				{type:"button", icon:"ui-icon-gear", label:"엑셀테스트", style:"float:right; margin-right:5px;", attr:"data-toggle='modal'",  listeners:[{	"click":function() {$("#grid").pqGrid("exportExcel", { url: "/test/excel.jsp", sheetName: "pqGrid sheet" });}}]}
		);
		*/
	
		var obj = $.extend({}, baseObj, {
			colModel: colModel,
			//dataModel: dataModel,
			scrollModel: { autoFit: true },
		});
	
		var $summary = "";
		obj.render = function (evt, ui) {
			$summary = $("<div class='pq-grid-summary'></div>")
			.prependTo($(".pq-grid-bottom", this));
		}
	
		obj.refresh = function (evt, ui) {
			var data = ui.dataModel.data;
			//if(data==undefined || data.length==0) return;
			
	
			var sum = {"kind":"sum", "part_name":"<b>총계</b>", "eval_cnt":"-","tot_score":"-"
				,eval_cnt:0,eval_order:0,tot_score:0
			};
			
			if(itemData != undefined && itemData.length > 0)
			{
		 		for(var i=0, len=itemData.length; i<len; i++) 
		 		{
					sum["item_code"] = itemData[i].item_code;
					sum["exam_score_"+sum["item_code"]] = 0;
					sum["add_score_"+sum["item_code"]]  = 0;
				}			
			}
			
	 		if(data!=undefined && data.length>0) 
	 		{
	 			for(var i=0, len=data.length; i<len; i++) 
	 			{
	 				var d = data[i];
	 				if(d.kind!="subSum")
	 				{
	 					sum.eval_cnt		+= parseInt(d.eval_cnt);
	 					sum.eval_order		+= parseInt(d.eval_order);
	 					sum.tot_score		+= parseInt(d.tot_score);
	 					sum.exam_score 		+= parseInt(d.exam_score);
	 					sum.eval_score 		+= parseInt(d.eval_score);
	 					sum.add_score 		+= parseInt(d.add_score);
	
	 					for(var i2=0, len2=itemData.length; i2<len2; i2++) 
	 					{
	 						var itemCode = itemData[i2].item_code
	 						sum["exam_score_"+itemCode] += parseInt(d["exam_score_"+itemCode]);
	 						sum["add_score_" +itemCode] += parseInt(d["add_score_" +itemCode]);
	 					}
	 				}
	 			}
	 			
	 			for(var i=0, len=itemData.length; i<len; i++) 
	 			{
	 				var itemCode = itemData[i].item_code;
	 				sum["item_score_" +itemCode] = round( sum["exam_score_"+itemCode] / data.length,1 )
	 												+  "<font color=#bbbbbb>/</font>"  
	 												+  round( sum["add_score_"+itemCode] / data.length,1 );
	 			}
	 		}
			
			var o = { data: [sum], $cont: $summary };
			$(this).pqGrid("createTable", o);
		}
	
		// grid
		if(search.event_code.length == 0)
		{
			//마감 제거후 문구 변경 CJM 20180514
			//alert("마감된 이벤트가 없습니다.\n\n이벤트 마감부터 하세요");
			alert("진행 중인 이벤트가 없습니다.\n\n이벤트  진행 부터 하세요");
		}
		else
		{
			$grid = $("#grid").pqGrid(obj);
		}
	
		chgEventCode();
		
		/*
			조직도 정보 노출 기능 강화 - CJM(20200421)
			조직 정보 누락되는 현상 개선
		*/
		if(($('select[name=mpart_code]').size() == 1 && $('select[name=mpart_code]').val() == ""))		$('select[name=bpart_code]').change();
		else if(($('select[name=spart_code]').size() == 1 && $('select[name=spart_code]').val() == ""))	$('select[name=mpart_code]').change();
		
	});
	
	function beforeSearchFunc()
	{
		if(!search.event_code.value)
		{
			//마감 제거후 문구 변경 CJM 20180514
			//alert("마감된 이벤트가 없습니다.\n\n이벤트 마감부터 하세요");
			alert("진행 중인 이벤트가 없습니다.\n\n이벤트  진행 부터 하세요");
			return false;
		}
		return true;
	}
	
	function goStats(kind)
	{
		if(kind == "score")
		{
			document.location = "average_stat.jsp";
		}
		else if(kind == "item")
		{
			document.location = "<%=page_id%>.jsp";
		}
	}
	
	function chgEventCode()
	{
		var obj = search.event_code_combo;
		if(obj.value == "") return;
	
		var eventInfo = obj.value.split("/");//event_code / sheet_code
		search.event_code.value = eventInfo[0];
	
		setTitleBySheet(eventInfo[1]);
	}
	
	function setTitleBySheet(sheet_code)
	{
		goToAjaxSite("remote_average_stat.jsp","act=getItem&sheet_code="+sheet_code,"callBackSetTitleBySheet");
	}
	
	function callBackSetTitleBySheet(jData)
	{
		itemData = jData.data;
		var cm = clone(colModel);
		
		for(var i=0, len=jData.data.length;i<len;i++) 
		{
			var d = jData.data[i];
			
			if(d.obj_type == 'C')
			{
				cateName = new Object();
				var itemArray = new Array();
				
				cateName.title = d.item_name;
				cateName.width = 160;
				cateName.align = "center";
				
				var itemI = 0;
				for(var j=0, len2=jData.data.length;j<len2;j++) 
				{
					var d2 = jData.data[j];
	
					if(d.item_code == d2.up_code && d2.obj_type == 'I')
					{
						itemArray[itemI] = {title: ""+d2.item_name+"<br>("+d2.exam_score_max+"<font color=#bbbbbb>/</font>"+d2.add_score_max+")", width: 50*jData.data.length, align:"center", dataIndx: "item_score_"+d2.item_code}
						itemI++;
					}
				}
				
				cateName.colModel = itemArray;
				cm.push(cateName);
			}
		}
		
		$("#grid").pqGrid("option", "colModel", cm );
		$("#grid").pqGrid("option", "dataModel", dataModel );
		//$grid.pqGrid( 'option', 'dataModel.data', new_data );
		$("#grid").pqGrid("refreshDataAndView");
	}
</script>

<!--title 영역 -->
<div class="row titleBar border-bottom2">
	<div style="float:left;"><h4>부서별항목별 통계</h4></div>
	<ol class="breadcrumb" style="float:right;">
		<li><a href="#none"><i class="fa fa-home"></i> 평가 통계</a></li>
		<li class="active"><strong>부서별항목별 통계</strong></li>
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
					<li class=""><a href="javascript:goStats('score')">평가점수</a></li>
				</ul>
			</div>
		</div>
	</div>

	<!--ibox 시작-->
	<div class="ibox">
	<form id="search">
		<input type=hidden name=act value="list">
		<!--검색조건 영역-->
		<div class="ibox-content contentRadius1 conSize">
			<div id="resultDiv1">
				<div id="labelDiv">
					<label class="simple_tag">이벤트 명</label>
					<select class="form-control result_form3" name="event_code_combo">
						<%=htm_event_list%>
					</select>
					<input type=hidden name=event_code>
				</div>
			</div>


			<div id="resultDiv2">
				<div id="labelDiv">
					<label class="simple_tag">평가일자</label>
					<!-- 달력 팝업 위치 시작-->
					<div class="input-group" style="display:inline-block;">
						<input type="text" name="eval_date1" class="form-control result_form1 datepicker">
						<div class="input-group-btn">
							<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
						</div>
					</div>
					<!-- 달력 팝업 위치 끝-->
					<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
					<!-- 달력 팝업 위치 시작-->
					<div class="input-group" style="display:inline-block;">
						<input type="text" name="eval_date2" class="form-control result_form1 datepicker">
						<div class="input-group-btn">
							<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
						</div>
					</div>
					<!-- 달력 팝업 위치 끝-->
				</div>
			</div>

			<!--1행 끝-->
			<!--2행 시작-->
			<div id="resultDiv1">
				<div id="labelDiv">
					<label class="simple_tag">조직도</label>
					<select class="form-control result_form2" name="bpart_code">
						<%=htm_bpart_list%>
					</select> :
					<select class="form-control result_form2" name="mpart_code">
						<%=htm_mpart_list%>
					</select><!-- :
					<!-- 
					<select class="form-control result_form2" name="spart_code">
						<%=htm_spart_list%>
					</select>
					 -->
				</div>
			</div>

			<!-- 
			<div id="resultDiv2">
				<div id="labelDiv">
					<label class="simple_tag">상담원 명</label>
					<input type="text" name="user_name" class="form-control result_form3" id="" placeholder="">
				</div>
			</div>
			 
			<div id="resultDiv2">
				<div id="label_Div">
					<label class="simple_tag">평가자 명</label>
					<input type="text" name="eval_user_name" class="form-control result_form3" id="" placeholder="">
				</div>
			</div>
			-->
		</div>
		<!--검색조건 영역 끝-->

		<!--유틸리티 버튼 영역-->
		<div class="contentRadius2 conSize">
			<!--ibox 접히기, 설정버튼 영역-->
			<div class="ibox-tools">
				<a class="collapse-link">
					<button type="button" class="btn btn-default"><i class="fa fa-chevron-up"></i></button>
				</a>
			</div>
			<!--ibox 접히기, 설정버튼 영역 끝-->
			<div style="float:right">
				<button type="button" name="btn_search" class="btn btn-primary btn-sm"><i class="fa fa-search"></i> 조회</button>
				<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
			</div>
		</div>
		<!--유틸리티 버튼 영역 끝-->
	</form>
	</div>
	<!--ibox 끝-->

	<!--Data table 영역-->
	<div class="contentArea">
		<!--grid 영역-->
		<div id="grid"></div>
		<!--grid 영역 끝-->
	</div>
	<!--Data table 영역 끝-->
</div>
<!--wrapper-content영역 끝-->

<jsp:include page="/include/bottom.jsp"/>
<%
} catch(Exception e) {
	logger.error(e.getMessage());
}
%>