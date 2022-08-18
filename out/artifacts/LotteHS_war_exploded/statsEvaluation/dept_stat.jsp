<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// 메뉴 접근권한 체크
	if(!Site.isPmss(out,"dept_stat","")) return;
	
	Db db = null;
	
	try 
	{
		// DB Connection
		db = new Db(true);
	
		Map<String, Object> argMap = new HashMap<String, Object>();
	
		// 이벤트 콤보박스
		// 상태값 진행중인 이벤트 select CJM 20180511
		//String htm_event_list = Site.getEventComboHtml("5", "eval_order_max");//2:진행중, 5:마감, 9:종료
		String htm_event_list = Site.getEventComboHtml("2", "eval_order_max");//2:진행중, 5:마감, 9:종료
	
		// 시트 콤보박스
		String htmSheetList = Site.getSheetComboHtml(argMap);
	
		//조직도 콤보박스
		String htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
		String htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
		String htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
	var curGaroSero = "garo";
	var statsShowType = 'garo';//표시방식
	var colModel = [
		//{ title: "대분류", width: 100, dataIndx: "bpart_name"},
		//{ title: "중분류", width: 100, dataIndx: "mpart_name"},
		//{ title: "소분류", width: 100, dataIndx: "spart_name"},
		{ title: "부서", width: 200, dataIndx: "part_name", render: function(ui) {
			return (ui.rowData["part_name"]) ? ui.rowData["part_name"] :
				($("#search input[name=groupDepth]").val()==1) ? ui.rowData["bpart_name"]+"<font color=gray> > </font>"+ui.rowData["mpart_name"]+"<font color=gray> > </font>"+ui.rowData["spart_name"] :
					ui.rowData["bpart_name"]+"<font color=gray> > </font>"+ui.rowData["mpart_name"];
			},
		},
		{ title: "평가차수", width: 76, dataIndx: "eval_order", hidden:true, render: function(ui) {return nvl2(ui.rowData["eval_order"],ui.rowData["eval_order"]+"차","-");},},
	
		{ title: "평균점수", width: 66, align:"right", dataIndx: "avg_score", render: function(ui) {return (ui.rowData["tot_eval_cnt"]==0) ? 0 : round(ui.rowData["tot_eval_score"]/ui.rowData["tot_eval_cnt"],2);},},
		{ title: "평가수", width: 60, align:"right", dataIndx: "tot_eval_cnt", render: function(ui) {return $.number(ui.rowData["tot_eval_cnt"]);},},
		{ title: "총점", width: 40, align:"right", dataIndx: "tot_eval_score", render: function(ui) {return $.number(ui.rowData["tot_eval_score"]);},},
		{ title: "항목점수", width: 66, align:"right", dataIndx: "tot_exam_score", render: function(ui) {return $.number(ui.rowData["tot_exam_score"]);},},
		{ title: "가중치점수", width: 80, align:"right", dataIndx: "tot_add_score", render: function(ui) {return $.number(ui.rowData["tot_add_score"]);},},
		{ title: "베스트", width: 60, align:"right", dataIndx: "tot_best_cnt" },
		{ title: "워스트", width: 60, align:"right", dataIndx: "tot_worst_cnt" }
	];
	var evalOrderInputIdx = getIdxColModel(colModel,"eval_order");
	
	$(function () 
	{
		var baseDataModel = getBaseGridDM("<%=page_id%>");
		var dataModel = $.extend({}, baseDataModel, {
			sorting: "local",
			//sortIndx: "bpart_name",
			sortDir: "up",
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		var baseObj = getBaseGridOption("dept_stat", "N", "Y", "N", "N");
	
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
			//if(!data) return;	총계 이전정보 남아있는 현상 발생 CJM 20180511
			//alert("statsShowType="+statsShowType+"\n"+objToStr(data))
	
			var sum = {
					"part_name":"<b>총계</b>"
					,avg_score:0,tot_eval_cnt:0,tot_eval_score:0,tot_exam_score:0,tot_add_score:0,tot_best_cnt:0,tot_worst_cnt:0
			};
			
			for(var i=1; i <= $("#search input[name=eval_order_max]").val(); i++)
			{
				sum["cnt"+i]=0;
				sum["sum"+i]=0;
			}
	
			if(data != undefined && data.length > 0) 
			{
				for(var i=0, len=data.length; i<len; i++) 
				{
					var d = data[i];
					sum.tot_eval_cnt += parseInt(d.tot_eval_cnt);
					sum.tot_exam_score += parseInt(d.tot_exam_score);
					sum.tot_add_score += parseInt(d.tot_add_score);
					sum.tot_eval_score += parseInt(d.tot_eval_score);
					sum.tot_best_cnt += parseInt(d.tot_best_cnt);
					sum.tot_worst_cnt += parseInt(d.tot_worst_cnt);
	
					for(var ii=1, len2=$("#search input[name=eval_order_max]").val(); ii <= len2; ii++)
					{
						//alert(d["sum"+ii]+"/"+d["cnt"+ii])
						sum["cnt"+ii] += parseInt(d["cnt"+ii]);
						sum["sum"+ii] += parseInt(d["sum"+ii]);
					}
				}
				
				//검색조건의 표시방식 클릭시 (모든 데이터 표시후 보여주는 필드 조정 하기 위해) 
				if(statsShowType) 
				{
					var type = statsShowType; 
					statsShowType=""; 
					chgGridField(type); //기능 확인 필요 CJM 20180511
				}			
				
			}
			sum.avg_score = (sum.tot_eval_cnt==0) ? 0 : round(sum.tot_eval_score/sum.tot_eval_cnt,2);
	
			var o = { data: [sum], $cont: $summary };
			$(this).pqGrid("createTable", o);
		}
	
		$("#search select[name=event_code_combo]").change(function(){
			chgEventCode();
		});
	
		// grid
		if(search.event_code_combo.length == 0)
		{
			//마감 제거후 문구 변경 CJM 20180511
			//alert("마감된 이벤트가 없습니다.\n\n이벤트 마감부터 하세요");
			alert("진행 중인 이벤트가 없습니다.\n\n이벤트  진행 부터 하세요");
		}
		else
		{
			var eventInfo = search.event_code_combo.value.split("/"); // event_code / eval_order_max
			search.event_code.value = eventInfo[0];
			$grid = $("#grid").pqGrid(obj);
			$("#grid").pqGrid("option", "dataModel", dataModel );
			setColModel(eventInfo[1]);
			$("#grid").pqGrid("refreshDataAndView");
		}

		/*
			조직도 정보 노출 기능 강화 - CJM(20200421)
			조직 정보 누락되는 현상 개선
		*/
		if(($('select[name=mpart_code]').size() == 1 && $('select[name=mpart_code]').val() == ""))		$('select[name=bpart_code]').change();
		else if(($('select[name=spart_code]').size() == 1 && $('select[name=spart_code]').val() == ""))	$('select[name=mpart_code]').change();
		
	});
	
	function beforeSearchFunc()
	{
		if(search.event_code_combo.length == 0)
		{
			//마감 제거후 문구 변경 CJM 20180511
			//alert("마감된 이벤트가 없습니다.\n\n이벤트 마감부터 하세요");
			alert("진행 중인 이벤트가 없습니다.\n\n이벤트  진행 부터 하세요");
			return false;
		}
		return true;
	}
	
	function chgShowType(depth, type)
	{
		curGaroSero = type;
		setColModel();
	
		window.focus();
		$("#search input[name=groupDepth]").val(depth);
		$("#search input[name=showType]").val(type);
	
		E("mnu_garo1").className = "";
		E("mnu_sero1").className = "";
		E("mnu_garo2").className = "";
		E("mnu_sero2").className = "";
		E("mnu_"+type+depth).className = "active";
	
		statsShowType = type;
		search.btn_search.click();
	}
	
	function chgGridField(type)
	{
		var colM=$grid.pqGrid( "option", "colModel" );
		if(type == "garo")
		{
			colM[evalOrderInputIdx].hidden = true;//평가차수
			for(var i=1, len=$("#search input[name=eval_order_max]").val(); i <= len; i++)
			{
				colM[evalOrderInputIdx+i].hidden = false;
			}
			$grid.pqGrid( "option", "colModel", colM );
		}
		else
		{
			//type=sero
			colM[evalOrderInputIdx].hidden = false;
			$grid.pqGrid( "option", "colModel", colM );
		}
	}
	
	function chgEventCode()
	{
		var obj = search.event_code_combo;
		if(obj.value == "") return;
	
		var eventInfo = obj.value.split("/"); // event_code / eval_order_max
		search.event_code.value = eventInfo[0];
	
		setColModel(eventInfo[1]);
		statsShowType = curGaroSero;
		$("#grid").pqGrid("refreshDataAndView");
	}
	
	//차수 컬럼 설정하기
	function setColModel(evalOrderMax)
	{
		$("#search input[name=eval_order_max]").val( (evalOrderMax) ? parseInt(evalOrderMax) : $("#search input[name=eval_order_max]").val() );//최대평가차수
		var colModelNew = clone(colModel);
		if(curGaroSero == 'garo')
		{
			//이벤트 차수 추가
			for(var i=1; i <= $("#search input[name=eval_order_max]").val(); i++)
			{
				colModelNew.splice(evalOrderInputIdx+i,0,getEvalOrderTitle(i));
			}
		}
		$("#grid").pqGrid("option", "colModel", colModelNew);
	}
	
	//차수 컬럼 정보 HTML 구하기
	function getEvalOrderTitle(order)
	{
		return { title: order+"차", width: 40, align:"right", dataIndx: "avg_score"+order, hidden:true, render: function(ui) {return (!ui.rowData["cnt"+order]) ? "-" : round(ui.rowData["sum"+order]/ui.rowData["cnt"+order],2);}};
	}
</script>

<!--title 영역 -->
<div class="row titleBar border-bottom2">
	<div style="float:left;"><h4>부서별 통계</h4></div>
	<ol class="breadcrumb" style="float:right;">
		<li><a href="#none"><i class="fa fa-home"></i> 평가 통계</a></li>
		<li class="active"><strong>부서별 통계</strong></li>
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
					<li id=mnu_garo1 class="active"><a href="javascript:chgShowType(1, 'garo')">소분류별 :: 차수가로</a></li>
					<li id=mnu_sero1 class=""><a href="javascript:chgShowType(1, 'sero')">소분류별 :: 차수세로</a></li>
					<li id=mnu_garo2 class=""><a href="javascript:chgShowType(2, 'garo')">중분류별 :: 차수가로</a></li>
					<li id=mnu_sero2 class=""><a href="javascript:chgShowType(2, 'sero')">중분류별 :: 차수세로</a></li>
				</ul>
			</div>
		</div>
	</div>

	<!--ibox 시작-->
	<div class="ibox">
	<form id="search">
		<input type=hidden name=groupDepth value="1">
		<input type=hidden name=showType value="garo">
		<input type=hidden name=eval_order_max>
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

			<!-- div id="resultDiv2">
				<div id="labelDiv">
					<label class="simple_tag">시트 명</label>
					<select class="form-control result_form3" name="sheet_code">
						<option value="">시트 선택</option>
						<%=htmSheetList%>
					</select>
				</div>
			</div -->

			<div id="resultDiv1">
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
	finally 
	{
		if(db != null)	db.close();
	}
%>