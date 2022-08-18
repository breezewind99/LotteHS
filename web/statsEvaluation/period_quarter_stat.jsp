<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// 메뉴 접근권한 체크
	if(!Site.isPmss(out,"period_stat","")) return;
	
	try 
	{
		Map<String, Object> argMap = new HashMap<String, Object>();
	
		// 이벤트 콤보박스
		// 상태값 진행중인 이벤트 select CJM 20180514
		//String htm_event_list = Site.getEventComboHtml("5", "eval_order_max");//2:진행중, 5:마감, 9:종료
		String htm_event_list = Site.getEventComboHtml("2", "eval_order_max");//2:진행중, 5:마감, 9:종료
	
		// 시트 콤보박스
		String htmSheetList = Site.getSheetComboHtml(argMap);
		
		// 년도 콤보박스
		String htm_year_list = Site.getYearComboHtml(argMap);
	
		//조직도 콤보박스
		String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
		String htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
		String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
	var dataModel;
	var colModel = [
		{ title: "부서", width: 200, dataIndx: "part_name", render: function(ui) {
			return (ui.rowData["part_name"]) ? ui.rowData["part_name"] : ui.rowData["bpart_name"]+"<font color=gray> > </font>"+ui.rowData["mpart_name"]+"<font color=gray> > </font>"+ui.rowData["spart_name"];},
		},
		{ title: "상담원 ID", width: 100, dataIndx: "user_id" },
		{ title: "상담원 명", width: 100, dataIndx: "user_name" },
	];
	
	var colTotScore = { title: "총점", width: 40, align:"right", dataIndx: "tot_eval_score", 
		render: function(ui) {
			var totSum = 0;
			for(var i=1; i <=4; i++)
			{
				totSum += ui.rowData["sum"+i];
			}
			return $.number(totSum);
		}
	};
	var colTotAvg = { title: "평균", width: 66, align:"right", dataIndx: "avg_score", 
		render: function(ui) {
			var avgCnt = 0;
			var totSum = 0;
			for(var i=1; i <=4; i++)
			{
				if(ui.rowData["sum"+i] > 0)
				{
					totSum += round(ui.rowData["sum"+i]/ui.rowData["cnt"+i],2);
					avgCnt++;
				}	
			}
			
			if(avgCnt > 0)
			{
				return round(totSum/avgCnt,2);
			}
			else
			{
				return 0;
			}
		}
	};
	
	var evalOrderInputIdx = getIdxColModel(colModel,"user_name");
	var event_code = "<%=htm_event_list%>";
	
	$(function () 
	{
		$("#search select[name=year_code]").change(function(){
			chgEventCode();
		});
		
		var baseDataModel = getBaseGridDM("<%=page_id%>");
		dataModel = $.extend({}, baseDataModel, {
			sorting: "local",
			//sortIndx: "rec_date",
			sortDir: "up",
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		var baseObj = getBaseGridOption("<%=page_id%>", "N", "Y", "N", "N");
	
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
			
			//if(!data) return;	총계 이전정보 남아있는 현상 발생 CJM 20180514
	
			var sum = {
					"part_name":"<b>총계</b>", "user_id":"-","user_name":"-"
					,tot_eval_score:0,avg_score:0
			};
			for(var i=1, len=4; i <= len; i++)
			{
				sum["cnt"+i]=0;
				sum["sum"+i]=0;
			}
	
			if(data != undefined && data.length > 0) 
			{
				for(var i=0, len=data.length; i<len; i++) 
				{
					var d = data[i];
					
					for(var ii=1, len2=4; ii <= len2; ii++)
					{
						sum["cnt"+ii] += d["cnt"+ii];
						sum["sum"+ii] += d["sum"+ii];
					}
				}
			}
	
			var o = { data: [sum], $cont: $summary };
			$(this).pqGrid("createTable", o);
		}
	
		// grid
		if(event_code.length == 0)
		{
			//마감 제거후 문구 변경 CJM 20180514
			//alert("마감된 이벤트가 없습니다.\n\n이벤트 마감부터 하세요");
			alert("진행 중인 이벤트가 없습니다.\n\n이벤트  진행 부터 하세요");		
		}
		else
		{
			$grid = $("#grid").pqGrid(obj);
			
			chgEventCode();
		}
		
		/*
			조직도 정보 노출 기능 강화 - CJM(20200421)
			조직 정보 누락되는 현상 개선
		*/
		if(($('select[name=mpart_code]').size() == 1 && $('select[name=mpart_code]').val() == ""))		$('select[name=bpart_code]').change();
		else if(($('select[name=spart_code]').size() == 1 && $('select[name=spart_code]').val() == ""))	$('select[name=mpart_code]').change();
		
	});
	
	//차수 컬럼 설정하기
	function setColModel()
	{
		var colModelNew = clone(colModel);
		
		for(var i=1; i <= 4; i++)
		{
			var cateName = new Object();
			
			cateName.title = i+"분기";
			cateName.width = 40;
			cateName.align = "center";
			
			var itemArray = new Array();
			itemArray[0] = getEvalOrderScore(i);	
			itemArray[1] = getEvalOrderAverage(i);
			
			cateName.colModel = itemArray;
			colModelNew.push(cateName);
		}
		
		colModelNew.push(colTotScore);
		colModelNew.push(colTotAvg);
		
		$("#grid").pqGrid("option", "colModel", colModelNew);
		$("#grid").pqGrid("option", "dataModel", dataModel );
		$("#grid").pqGrid("refreshDataAndView");
	}
	
	//차수 컬럼 정보 HTML 구하기
	function getEvalOrderScore(order)
	{
		return { title: "총점", width: 40, align:"center", dataIndx: "sum"+order, render: function(ui) {return (!ui.rowData["sum"+order]) ? "-" : ui.rowData["sum"+order];}};
	}
	
	function getEvalOrderAverage(order)
	{
		return { title: "평균", width: 40, align:"center", dataIndx: "avg_count"+order, render: function(ui) {return (!ui.rowData["cnt"+order]) ? "-" : round(ui.rowData["sum"+order]/ui.rowData["cnt"+order],2);}};
	}
	
	function beforeSearchFunc()
	{
		if(event_code.length == 0)
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
			document.location = "period_stat.jsp";
		}
		else if(kind == "item")
		{
			document.location = "<%=page_id%>.jsp";
		}
	}
	
	function chgEventCode()
	{
		var obj = search.year_code;
		if(obj.value=="") return;
	
		setColModel();
	}
</script>

<!--title 영역 -->
<div class="row titleBar border-bottom2">
	<div style="float:left;"><h4>기간별 통계</h4></div>
	<ol class="breadcrumb" style="float:right;">
		<li><a href="#none"><i class="fa fa-home"></i> 평가 통계</a></li>
		<li class="active"><strong>기간별 통계</strong></li>
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
					<li class=""><a href="javascript:goStats('score')">월별</a></li>
					<li class="active"><a href="javascript:goStats('item')">분기별</a></li>
				</ul>
			</div>
		</div>
	</div>

	<!--ibox 시작-->
	<div class="ibox">
	<form id="search">
		<input type=hidden name=eval_order_max>
		<!--검색조건 영역-->
		<div class="ibox-content contentRadius1 conSize">
			<!-- 
			<div id="resultDiv1">
				<div id="labelDiv">
					<label class="simple_tag">이벤트 명</label>
					<select class="form-control result_form3" name="event_code_combo"">
						<%=htm_event_list%>
					</select>
					<input type=hidden name=event_code>
				</div>
			</div>
			 -->
			 
			<div id="resultDiv1">
				<div id="labelDiv">
					<label class="simple_tag">평가년도</label>
					<select class="form-control result_form3" name="year_code"">
						<%=htm_year_list%>
					</select>
				</div>
			</div>

			<!-- div id="resultDiv2">
				<div id="labelDiv">
					<label class="simple_tag">시트 명</label>
					<select class="form-control result_form3" name="sheet_code">
						<option value="">시트 선택</option>
						<%=htmSheetList%>
					</select>
				</div>
			</div -->

			<!--1행 끝-->
			<!--2행 시작-->
			<div id="resultDiv2">
				<div id="labelDiv">
					<label class="simple_tag">조직도</label>
					<select class="form-control result_form2" name="bpart_code">
						<%=htm_bpart_list%>
					</select> :
					<select class="form-control result_form2" name="mpart_code">
						<%=htm_mpart_list%>
					</select> :
					<select class="form-control result_form2" name="spart_code">
						<%=htm_spart_list%>
					</select>
				</div>
			</div>

			<div id="resultDiv1">
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
	} 
	catch(Exception e) 
	{
		logger.error(e.getMessage());
	}
%>