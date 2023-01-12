<%@ page import="static com.cnet.crec.util.CommonUtil.getClientIP" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// 메뉴 접근권한 체크
	if(!Site.isPmss(out,"rec_search","")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		Map<String, Object> confmap = new HashMap<String, Object>();
	
		// config (session value mapping)
		confmap.put("business_code", _BUSINESS_CODE);
		confmap.put("user_id", _LOGIN_ID);
		confmap.put("user_level", _LOGIN_LEVEL);
		confmap.put("login_ip", _LOGIN_IP);
		confmap.put("default_used", "1");
		
		/*
			녹취 다운로드 여부 정보 - CJM(20181218)
			등급 권한에서 세부적으로 상담원별 권한 부여
		*/
		String _REC_DOWN_YN = (String) session.getAttribute("rec_down_yn");
	
		//검색결과 목록 필드 구하기
		List<Map<String, Object>> fld_list = db.selectList("rec_search.selectResultConfig", confmap);
		String htmSearchListField = "";
		
		if(fld_list.size() > 0) 
		{
			for(Map<String, Object> item : fld_list) 
			{
				
				String sort_flag = item.get("order_used").equals("1") ? "true" : "false";
				String min_width = CommonUtil.hasText(item.get("conf_etc").toString()) ? item.get("conf_etc").toString() : "50";
				//녹취 다운로드 여부 정보 - CJM(20181218)
				String down_perm = ("N".equals(_REC_DOWN_YN.toUpperCase()) && "v_download".equals(item.get("result_value").toString())) ? ", hidden : true" : "";
				
				// 리스트 설정에서 hidden 개념 삭제
				//if(!"hidden".equals(item.get("result_value"))) {
					//htmSearchListField += ",{ title: '"+item.get("conf_name")+"', minWidth: " + min_width + ", dataIndx: '"+item.get("result_value")+"', sortable: "+sort_flag+" }\n";
					htmSearchListField += ",{ title: '"+item.get("conf_name")+"', minWidth: " + min_width + ", dataIndx: '"+item.get("result_value")+"', sortable: "+sort_flag+""+down_perm+" }\n";
				//}
			}
		}
		
		// config search select
		List<Map<String, Object>> sel_list = db.selectList("rec_search.selectSearchConfig", confmap);
	
		//조직도 콤보박스
		String htm_bpart_list = "";
		String htm_mpart_list = "";
		String htm_spart_list = "";
	
		List<Map<String, Object>> system_list = null;
		List<Map<String, Object>> bpart_list = null;
		
		for(Map<String, Object> item : sel_list) 
		{
			if(item.get("conf_value").equals("system_code")) 
			{
				system_list = db.selectList("system.selectCodeList", confmap);
			} 
			else if(item.get("conf_value").equals("part_code")) 
			{
				htm_bpart_list = Site.getMyPartCodeComboHtml(session, 1);
				htm_mpart_list = Site.getMyPartCodeComboHtml(session, 2);
				htm_spart_list = Site.getMyPartCodeComboHtml(session, 3);
			}
		}
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../css/tree/default/style.css" />
<link rel="stylesheet" href="../css/tree/default/tree.css" />
<!-- 청취 클릭 시 배경변경 -->
<style type="text/css">
	tr.cls_clicked td { background:#5f9bdb !important; }
	tr.red td { background:#5f9bdb !important; }
</style>
<script type="text/javascript" src="../js/plugins/tree/jstree.min.js"></script>
<script type="text/javascript" src="../js/clipboard.min.js"></script>
<script type="text/javascript">

	new ClipboardJS('.copy');

	//청취/다운 사유입력 유무
	var isExistPlayDownReason = <%=Finals.isExistPlayDownReason%>;
	//다운로드 확장자 선택 유무
	var isDownloadExt = <%=Finals.isDownloadExt%>;



	$(function () {
		$("input[name=rec_date1]").mask("y999-m9-d9");
		$("input[name=rec_date2]").mask("y999-m9-d9");

		//검색목록 필드
		var colModel = [
			{ title: "", dataIndx: "state", minWidth: 25, align: "center", type:"checkBoxSelection", cls: "ui-state-default", resizable: false, sortable:false },
			/*
            { title: "", dataIndx: "state", maxWidth: 30, minWidth: 30, align: "center", resizable: false, type: 'checkBoxSelection', cls: 'ui-state-default', sortable: false
				, editable: false, cb: { all: true, header: true }},
			*/
			{ title: "순번", width: 40, dataIndx: "idx", sortable: false, editable: false}
			<%=htmSearchListField%>
		];
			
		/*
			조회 기능 수정 - CJM(20180504)
			on load시 자동 조회 기능 제거후 두번 조회되는 현상 현상 발생하여 예외 처리 - CJM(20190107)
			on load시 자동 조회 기능 활성화 방법은  첫번째 주석 제거 두번째 주석 처리
			var baseDataModel = getBaseGridDM("rec_search");
			var baseDataModel = "";
		*/
		//$("button[name=btn_search]").click(function() 부분 주석 처리
		//var baseDataModel = getBaseGridDM("<%=page_id%>");
		
		var baseDataModel = "";
		var dataModel = $.extend({}, baseDataModel, {
			//sortIndx: "rec_datm",
			sortDir: "down",
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		var baseObj = getBaseGridOption("rec_search", "Y", "Y", "N", "N");
		// toolbar button add
		baseObj.toolbar.items.push(
			{type:"button", icon:"ui-icon-gear", label:"설정", style:"float:right; margin-right:5px;", attr:"data-toggle='modal'",  listeners:[{"click":function() {popResultConfig('R');}}]} ,
			{type:"button", icon:"ui-icon-gear", label:"다중다운로드", style:"float:right; margin-right:5px;display:<%=ComLib.getCssDisplayStr(Finals.isExistMultiDownload)%>", attr:"data-toggle='modal'",  listeners:[{"click":function() {getSelectedRows();}}]} ,
			{type:"button", icon:"ui-icon-gear", label:"다중청취", style:"float:right; margin-right:5px;", attr:"data-toggle='modal'",  listeners:[{	"click":function() {playRecFileMulti('rec');}}]}
		);
	
		var obj = $.extend({}, baseObj, {
			colModel: colModel,
			dataModel: dataModel,
			scrollModel: { autoFit: true},
			//scrollModel: { autoFit: false, theme : true },
		 	//selectionModel: { type: "cell", mode: "block" }
			selectionModel: { type: "none", subtype:"incr", cbHeader:true, cbAll:true }
		});
		//var cls = colModel[1].cls;
		//console.log("녹취조회 colModel : "+JSON.stringify(obj));

		// grid
		$grid = $("#grid").pqGrid(obj);
		//$grid.pqGrid("refreshDataAndView");//타이틀 체크박스가 안나타 나서 추가함 : 조회가 두번 호출 되는게 아닌가? (체크 필요)
		//$grid.pqGrid("disable");
		//console.log("녹취조회 : "+JSON.stringify($("#grid").pqGrid( "option", "scrollModel")));
		
		// search 설정버튼 클릭
		$("button[name=btn_search_config]").click(function() {
			popResultConfig('S');
		});
		
		//조회 기능 수정 - CJM(20180504)
		$("button[name=btn_search]").click(function() 
		{
			recSearch();
		});
		
		// 녹취 조회 기능 - CJM(20190107)
		var recSearch = function()
		{
			//공통모듈 실행하기 전에 해당페이지 펑션 체크 (유효성 체크등..)
			//on load시 자동 조회 기능 제거후 두번 조회되는 현상 현상 발생하여 예외 처리 - CJM(20190107)
			//var dataChek = $grid.pqGrid( "option", "dataModel.data" );

			//console.log("녹취조회1");
			//console.log("dataChek : "+dataChek);
			//console.log("baseGridChk : "+baseGridChk);
			//if(dataChek == null)
			
			if(!baseGridChk)
			{
				//조회 조건 일자 체크 - CJM(20190715)
				//공통 validation 체크 적용 - CJM(20200728)
				/*
				var date1 = $("#search input[name=rec_date1]");
				var date2 = $("#search input[name=rec_date2]");
				if(!recSearchChk(date1, date2)) return;
				*/
				if(!fnValidation("<%=page_id%>"))	return;
				
				baseDataModel = getBaseGridDM("<%=page_id%>");
				
				dataModel = $.extend({}, baseDataModel, {
					//sortIndx: "rec_datm",
					sortDir: "down",
				});
				
				/*
					필드가 많을 경우 화면 영역이 벗어나 하단 스크롤이 생성된 경우
					다시 조회시 리사이즈 되면서 GRID 크기가 조절되어 하단 스크롤이 사라지는 현상 발생
					flexWidth: true 추가 - CJM(20190710)
				*/
				obj = $.extend({}, baseObj, {
					colModel: colModel,
					dataModel: dataModel,
					//flexWidth: true,
				 	//scrollModel: { autoFit: true },
					//scrollModel: { pace:"fast",horizontal:true, lastColumn:"auto",autoFit: false,theme:true},
					//scrollModel: {horizontal:true, autoFit: true},
					//selectionModel: { type: "cell", mode: "block"}
					selectionModel: { type: "none", subtype:"incr", cbHeader:true, cbAll:true}
				});
				
				//console.log("obj : "+JSON.stringify(obj));
				//console.log("녹취조회2-2 : "+JSON.stringify($("#grid").pqGrid( "option", "scrollModel")));
				// grid
				$grid = $("#grid").pqGrid(obj);
				$grid.pqGrid("refreshDataAndView");	//타이틀 체크박스가 안나타 나서 추가함 : 조회가 두번 호출 되는게 아닌가? (체크 필요)
				//$("#grid").pqGrid( "option", "scrollModel", { flexContent: true } );
			}
		};
	
		// 조회목록 설정
		var popResultConfig = function (conf_type) {
			$.ajax({
				type: "POST",
				url: "remote_search_config_list.jsp",
				async: false,
				data: "conf_type="+conf_type,
				dataType: "json",
				success:function(dataJSON){
					$("#modalSearchConfig #sortableSearchConfig").html("");
	
					if(dataJSON.code != "ERR") 
					{
						if(dataJSON.data.length > 0) 
						{
							var html = "";
							for(var i=0; i<dataJSON.data.length; i++) 
							{
								// 조직도의 경우 노출순서 변경 불가 (첫번째로 고정)
								html += "<li class='"+((i%2==0) ? "odd " : "") +" "+((dataJSON.data[i].conf_value=="part_code") ? "drag-disabled" : "")+"'><a href='#'>";
								html += "<input type='checkbox' name='conf_used' value='"+dataJSON.data[i].conf_code+"'"+((dataJSON.data[i].selected=="1") ? " checked=checked" : "")+""+((dataJSON.data[i].default_used=="1") ? " disabled=disabled" : "")+">"
								html += " "+dataJSON.data[i].conf_name;
								html += (dataJSON.data[i].default_used=="1") ? "<span class='colRight font_red'>필수</span>" : "";
								html += "</a></li>";
							}
	
							$("#modalSearchConfig #sortableSearchConfig").append(html);
							$("#modalSearchConfig button[name=modal_regi]").attr("prop", conf_type);
						} 
						else 
						{
							alert("설정 데이터가 없습니다.");
							return false;
						}

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
	
			var title = (conf_type == "S") ? "조회" : "리스트";
	
			$("#modalSearchConfig .modal-title").html(title+" 설정");
			$("#modalSearchConfig").modal("toggle");
		};
	
		// config 저장
		$("#modalSearchConfig button[name=modal_regi]").click(function() {
			var conf_type = $("#modalSearchConfig button[name=modal_regi]").attr("prop");
			var conf_codes = getCheckedValue($("#modalSearchConfig input[name=conf_used]"));
	
			if(conf_type!="" && conf_codes!="") 
			{
				$.ajax({
					type: "POST",
					url: "remote_search_config_proc.jsp",
					async: false,
					data: "conf_type="+conf_type+"&conf_codes="+conf_codes,
					dataType: "json",
					success:function(dataJSON){
						if(dataJSON.code == "OK") 
						{
							alert("정상적으로 등록되었습니다.");
							$("#modalSearchConfig").modal("hide");
							location.reload();
						}  else if (dataJSON.code == "ERRLOGIN") {
							alert(dataJSON.msg);
							top.location.replace('/index.jsp');
							return false;
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
	
		// 설정 drag & drop
		$("#modalSearchConfig #sortableSearchConfig").sortable({
			placeholder: "ui-state-highlight",
			items: "li:not(.drag-disabled)",
			stop: function(event,ui) {
			}
		});
		$("#modalSearchConfig #sortableSearchConfig").disableSelection();
	
		// tree open/close
		$("button[name=btn_tree_view]").click(function() {
			var open_flag = ($("#treeDiv1").css("display")=="none") ? false : true;
	
			if(open_flag) 
			{
				// 조직도 close
				$("#treeDiv1").css("display", "none");
				$("#treeDiv2").css("width", "100%");
			} 
			else 
			{
				// 조직도 open
				$("#treeDiv1").css("display", "block");
				$("#treeDiv2").css("width", "");
			}
	
			if($.jstree.reference("#tree")==null) {
				// tree
				var tree = $("#tree").jstree({
					"core" : {
						"data" : {
							"url": "/common/get_user_group_tree.jsp",
							"data": "business_code=<%=_BUSINESS_CODE%>&select_user=1",
							"dataType": "json",
						},
						"themes" : {
							"variant" : "small"
						}
					},
					"checkbox" : {
						  "keep_selected_style" : false,
						  "tie_selection" : false,
						  "three_state" : false
					},
					"types" : {
						"depth0" : {
							"icon" : "../img/tree_root.gif",
							"a_attr" : {
								"class" : "hide_checkbox"
							}
						},
						"depth1" : {
							"icon" : "../img/tree_depth1_close.gif",
							"a_attr" : {
								"class" : "hide_checkbox"
							}
						},
						"depth2" : {
							"icon" : "../img/tree_depth2_close.gif",
							"a_attr" : {
								"class" : "hide_checkbox"
							}
						},
						"depth3" : {
							"icon" : "../img/tree_depth3_close.gif",
							"a_attr" : {
								"class" : "hide_checkbox"
							}
						},
						"depth4" : {
							"icon" : "../img/tree_user.gif"
						}
					},
					"plugins" : ["checkbox","types"]
				});
	
				tree.bind("loaded.jstree", function() {
					//tree.jstree("open_all");
					tree.jstree("open_node", "ul > li:first");
				});
	
				tree.bind("check_node.jstree uncheck_node.jstree", function(obj, data) {
					// 선택된 상담원 id 셋팅
					$("#search input[name=user_list]").val(tree.jstree("get_checked"));
				});
			}
	
			// grid refresh
			$grid.pqGrid("refreshDataAndView");
			
		});
	
		// 필수 중단 팝업 오픈
		// $("button[name=btn_abort]").click(function() {
		// 	$("#modalAbort").modal("toggle");
		// });
	
		// 필수 중단 등록 버튼 클릭
		// $("#modalAbort button[name=modal_regi]").click(function() {
		// 	if(!$("#abort input[name=rec_date]").val().trim())
		// 	{
		// 		alert("날짜를 선택해 주십시오.");
		// 		$("#abort input[name=rec_date]").focus();
		// 		return false;
		// 	}
		//
		// 	$.ajax({
		// 		type: "POST",
		// 		url: "remote_rec_abort_proc.jsp",
		// 		async: false,
		// 		data: "step=abort&"+$("#abort").serialize(),
		// 		dataType: "json",
		// 		success:function(dataJSON){
		// 			if(dataJSON.code == "OK")
		// 			{
		// 				alert("정상적으로 업데이트 되었습니다.");
		// 				$("#modalAbort").modal("hide");
		// 				$grid.pqGrid("refreshDataAndView");
		// 			}
		// 			else
		// 			{
		// 				alert(dataJSON.msg);
		// 				return false;
		// 			}
		// 		},
		// 		error:function(req,status,err){
		// 			alertJsonErr(req,status,err);
		// 			return false;
		// 		}
		// 	});
		// });
		
		//달력 수동 입력시 - 자동 입력 CJM(20181204)
		//$(".rec_form1").on("change paste keyup select", function()
		$(".rec_form1").on("change keyup", function(e)
		{
			$(this).val(getDateToNum($(this).val().replace(/[^0-9]/g,""),"-"));
			
			//녹취 조회 기능 추가 - CJM(20190110)
			if(e.keyCode == 13)	recSearch(); 
		});
		
		/*
			조직도 정보 노출 기능 강화 - CJM(20200421)
			조직 정보 누락되는 현상 개선
		*/
		if(($('select[name=mpart_code]').size() == 1 && $('select[name=mpart_code]').val() == ""))		$('select[name=bpart_code]').change();
		else if(($('select[name=spart_code]').size() == 1 && $('select[name=spart_code]').val() == ""))	$('select[name=mpart_code]').change();

	});

	// 메모
	var memoRecData = function(rowIndx) 
	{
		var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
		var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,"");
	
		openPopup("memo.jsp?rec_datm="+rec_datm+"&local_no="+rowData["local_no"]+"&rec_filename="+rowData["rec_filename"],"_memo","478","590","yes","center");
	};

	function copyTel(rowIndx) {
		var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
		var Tel = rowData["n_cust_tel"].replace(/\s|-|:|\./gi,"");
		console.log(Tel);

		var tempInput = document.createElement("input");
		tempInput.setAttribute("type", "text");
		tempInput.setAttribute("value", Tel);
		tempInput.select();
		document.execCommand( 'Copy' );
		alert( 'URL 이 복사 되었습니다.' );
	}
	//다중다운로드
	function getSelectedRows() 
	{
		var selarray = $grid.pqGrid('selection', { type: 'row', method: 'getSelection' });
		var ids = [];
	
		var len = selarray.length;
		if(len == 0)
		{
			alert("먼저 왼쪽체크박스를 선택 후 다중다운로드를 클릭하세요!");
			return;
		}
	
		for(var i=0; i < len; i++) 
		{
			var rowData = selarray[i].rowData;
			//"|" + rowData["local_no"] + "|" + rowData["rec_filename"], "1"
			ids.push(rowData.rec_datm.replace(/\s|-|:|\./gi,"")+"|" + rowData.local_no + "|" + rowData.rec_filename);
			//downloadRecFile2(rowData.rec_datm.replace(/\s|-|:|\./gi,"")+"|" + rowData.local_no + "|" + rowData.rec_filename);
		}
		
		downloadRecFile2(ids);
	}
	
	function f_chg_background(arg_this) 
	{
		$(arg_this).closest('tr').addClass('cls_clicked');
	}
	
	

	function fvClickChk(ix, th)
	{
		var rowData = $grid.pqGrid("getRowData", { rowIndxPage: ix });
		//console.log("rec_datm :"+rowData["rec_datm"]);
		$(th).html(rowData["rec_datm"]);

		
		//$(th).attr("disabled",true);
	}
</script>

<!--title 영역 -->
<div class="row titleBar border-bottom2">
	<div style="float:left;"><h4>조회</h4></div>
	<ol class="breadcrumb" style="float:right;">
		<li><a href="#none"><i class="fa fa-home"></i> 조회</a></li>
		<li class="active"><strong>조회</strong></li>
	</ol>
</div>
<!--title 영역 끝 -->

<!--wrapper-content영역-->
<div class="wrapper-content" style="overflow: auto;">
	<!--ibox 시작-->
	<div class="ibox">
	<form id="search">
		<input type="hidden" name="user_list" value=""/>
		<!--검색조건 영역-->
		<div class="ibox-content-util-buttons">
			<div class="ibox-content contentRadius1 conSize" >
				<!--1행 시작-->
				<div id="recDiv3">
					<div class="labelDiv" >
						<label class="simple_tag">일자</label>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="rec_date1" class="form-control search_date datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
						</div>
						<!-- 달력 팝업 위치 끝-->
						<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="rec_date2" class="form-control search_date datepicker" value="<%=DateUtil.getToday("")%>" maxlength="10">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
						</div>
						<!-- 달력 팝업 위치 끝-->
					</div>
				</div>

				<div id="recDiv3">
					<div class="labelDiv">
						<label class="simple_tag">녹취시간</label>
						<input class="form-control search_time" type="time" name="rec_start_hour1" value="00:00:00" step="1"> ~ <input class="form-control search_time" type="time" name="rec_start_hour2" value="23:59:59" step="1">
					</div>
				</div>

				<div id="recDiv3">
					<div class="labelDiv">
						<label class="simple_tag">통화시간</label>
						<select class="form-control search_combo_range_2" name="rec_call_time1">
							<option value="0">0초</option>
							<option value="20">20초</option>
                            <option value="30">30초</option>
							<option value="60">1분</option>
                            <option value="90">1분30초</option>
							<option value="120">2분</option>
							<option value="180">3분</option>
							<option value="300">5분</option>
							<option value="600">10분</option>
							<option value="1200">20분</option>
							<option value="1800">30분</option>
							<option value="3600">60분</option>
						</select> ~
						<select class="form-control search_combo_range_2" name="rec_call_time2">
							<option value="0">0초</option>
                            <option value="20">20초</option>
                            <option value="30">30초</option>
                            <option value="60">1분</option>
                            <option value="90">1분30초</option>
							<option value="120">2분</option>
							<option value="180">3분</option>
							<option value="300">5분</option>
							<option value="600">10분</option>
							<option value="1200">20분</option>
							<option value="1800">30분</option>
							<option value="3600" selected="selected">60분</option>
							<option value="36000">60분 이상</option>
						</select>
					</div>
				</div>
				<!--1행 끝-->
<%
		// search config
		if(sel_list.size() > 0) 
		{
			int n=0;
			for(Map<String, Object> item : sel_list) 
			{
				StringBuffer sb = new StringBuffer();
				String conf_name = item.get("conf_name").toString();
				String conf_field = item.get("conf_field").toString();
				String conf_value = item.get("conf_value").toString();
				String div_num = (n%3==0) ? "1" : "2";
				String text_num = (n%3==0) ? "4" : "5";
				String etc_num = (n%3==0) ? "2" : "3";
	
				sb.append("<div id='recDiv3'><div id='labelDiv'>\n");
				sb.append("<label class='simple_tag'>"+conf_name+"</label>\n");
	
				if("local_no".equals(conf_value)) 
				{
					// 내선번호
					sb.append("<input type='text' class='form-control search_combo_range_2' name='"+conf_field+"1' placeholder=''> ~");
					sb.append(" <input type='text' class='form-control search_combo_range_2' name='"+conf_field+"2' placeholder=''>");
				} 
				else if("rec_inout".equals(conf_value)) 
				{
					// 인아웃
					sb.append("<select class='form-control search_combo_range_2' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					sb.append("	<option value='I'>인</option>\n");
					sb.append("	<option value='O'>아웃</option>\n");
					sb.append("	<option value='L'>내선</option>\n");
					sb.append("</select>");
				} 
				else if("system_code".equals(conf_value)) 
				{
					// 시스템
					sb.append("<select class='form-control search_combo_range_2' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					if(system_list != null) 
					{
						for(Map<String, Object> system_item : system_list) 
						{
							sb.append("<option value='"+system_item.get("system_code")+"'>"+system_item.get("system_name")+"</option>\n");
						}
					}
					sb.append("</select>\n");
				} 
				else if("part_code".equals(conf_value)) 
				{
					// 조직도
					sb.append("<select class='form-control search_combo_range_3' name='bpart_code'>\n");
					sb.append(htm_bpart_list);
					sb.append("</select> : \n");
					sb.append("<select class='form-control search_combo_range_3' name='mpart_code'>\n");
					sb.append(htm_mpart_list);
					sb.append("</select> : \n");
					sb.append("<select class='form-control search_combo_range_3' name='spart_code'>\n");
					sb.append(htm_spart_list);
					sb.append("</select>\n");
					sb.append("<input type='hidden' name='perm_check' value='1'/>\n");
				} 
				else if ("rec_succ_code".equals(conf_value)) 
				{
					// 통화 성공
					sb.append("<select class='form-control rec_form"+etc_num+"' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					sb.append("	<option value='1' selected='selected'>성공</option>\n");
					sb.append("	<option value='0'>실패</option>\n");
					//sb.append("	<option value='0'>미연결</option>\n");
					//sb.append("	<option value='3'>부분녹취</option>\n");
					sb.append("</select>");
				}
				else if ("rec_gubun".equals(conf_value))
				{
					// 영구 보관
					sb.append("<select class='form-control search_combo_range_2' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					sb.append("	<option value='0'>일반녹취</option>\n");
					sb.append("	<option value='1'>영구보관</option>\n");
					sb.append("</select>");
				}
				else if ("rec_mode".equals(conf_value))
				{
					// 메인 백업 구분
					sb.append("<select class='form-control search_combo_range_2' name='"+conf_field+"'>\n");
					sb.append("	<option value='A'>전체</option>\n");
					sb.append("	<option value='0' selected>메인</option>\n");
					sb.append("	<option value='1'>백업</option>\n");
					sb.append("</select>");
				}

				/*
				else if ("rec_abort_code".equals(conf_value))
				{
					// 필수 중단
					sb.append("<select class='form-control rec_form"+etc_num+"' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					sb.append("	<option value='1'>필수중단</option>\n");
					sb.append("</select>");
				}
				else if ("rec_mystery_code".equals(conf_value))
				{
					// 미스테리콜
					sb.append("<select class='form-control rec_form"+etc_num+"' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					sb.append("	<option value='1'>미스테리콜</option>\n");
					sb.append("</select>");
				}  
				else if ("custom_fld_02".equals(conf_value)) 
				{
					// VIP유무
					sb.append("<select class='form-control rec_form"+etc_num+"' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					sb.append("	<option value='0'>N</option>\n");
					sb.append("	<option value='1'>Y</option>\n");
					sb.append("</select>");
				} 
				else if ("custom_fld_03".equals(conf_value)) 
				{
					// CALLTYPE
					sb.append("<select class='form-control rec_form"+etc_num+"' name='"+conf_field+"'>\n");
					sb.append(" <option value=''>전체</option>\n");
					sb.append(" <option value='1'>미안내</option>\n");
					sb.append(" <option value='2'>생활안내</option>\n");
					sb.append(" <option value='3'>육성안내</option>\n");
					sb.append(" <option value='4'>자동안내</option>\n");
					sb.append(" <option value='5'>다량안내</option>\n");
					sb.append("</select>");
				} 
				else if ("custom_fld_05".equals(conf_value)) 
				{
					// 호종료주체
					sb.append("<select class='form-control rec_form"+etc_num+"' name='"+conf_field+"'>\n");
					sb.append("	<option value=''>전체</option>\n");
					sb.append("	<option value='0'>시스템</option>\n");
					sb.append("	<option value='1'>상담사</option>\n");
					sb.append("</select>");
				}				
				*/ 
				else 
				{
					sb.append("<input type='text' class='form-control search_input' name='"+conf_field+"' placeholder=''>\n");
				}
	
				sb.append("</div></div>\n\n");
	
				out.print(sb.toString());
				n++;
			}
		}
%>
			</div>
			<!--검색조건 영역 끝-->

			<!--유틸리티 버튼 영역-->
			<div class="contentRadius2 conSize">

				<!--ibox 접히기, 설정버튼 영역-->
				<div class="ibox-tools">
					<button type="button" name="btn_search_config" class="btn btn-default btn-sm" data-toggle='modal'><i class="fa fa-cog"></i> 설정</button>
					<button type="button" name="btn_tree_view" class="btn btn-default btn-sm"><i class="fa fa-sitemap"></i> 조직도</button>
<%--					<button type="button" name="btn_abort" class="btn btn-default btn-sm" style='display:<%=ComLib.getCssDisplayStr(Finals.isExistPilsooJungdan)%>'><i class="fa fa-ban"></i> 필수중단</button>--%>
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
		<!--treeDiv1 시작-->
		<div id="treeDiv1" style="display: none;">
			<!--조직도 구분-->
			<div class="selectRadius1">조직도</div>
			<div class="selectRadius2" style="background-color: #FFF;">
				<!-- 조직도 tree -->
				<div id="tree"></div>
				<!-- 조직도 끝 -->
			</div>
			<!--조직도 구분 끝-->
		</div>
		<!--treeDiv1 끝-->
		<!--treeDiv2 시작-->
		<div id="treeDiv2" style="width: 100%;">
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
			<!--팝업창 띠우기-->
			<!-- 조회/리스트 -->
			<div class="modal inmodal" id="modalSearchConfig" tabindex="-1" role="dialog"  aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content animated fadeIn">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
							<h4 class="modal-title"></h4>
						</div>
						<div class="modal-body">
							<!--리스트 설정 항목-->
							<div class="item-frame">
								<ul id="sortableSearchConfig" class="item-list" style="padding:0">
								</ul>
							</div>
							<!--리스트 설정 항목 끝-->
						</div>
						<div class="modal-footer">
							<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop=""><i class="fa fa-pencil"></i> 등록</button>
							<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
						</div>
					</div>
				</div>
			</div>
			<!-- 조회/리스트 끝 -->
			<!-- 필수 중단 콜 -->
<%--			<div class="modal inmodal" id="modalAbort" tabindex="-1" role="dialog"  aria-hidden="true">--%>
<%--				<div class="modal-dialog">--%>
<%--					<div class="modal-content animated fadeIn">--%>
<%--						<form id="abort">--%>
<%--							<div class="modal-header">--%>
<%--								<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>--%>
<%--								<h4 class="modal-title">필수중단 업데이트</h4>--%>
<%--							</div>--%>
<%--							<div class="modal-body">--%>
<%--								<table class="table top-line1 table-bordered2">--%>
<%--								<thead>--%>
<%--								<tr>--%>
<%--									<td style="width:25%;" class="table-td">날짜 <span class="required">*</span></td>--%>
<%--									<td style="width:75%; padding: 6px 9px;">--%>
<%--										<div class="input-group" style="display:inline-block;">--%>
<%--											<input type="text" name="rec_date" class="form-control datepicker" value="" style="z-index: 99999;">--%>
<%--											<div class="input-group-btn" style="display:block;">--%>
<%--												<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>--%>
<%--											</div>--%>
<%--										</div>--%>
<%--									</td>--%>
<%--								</tr>--%>
<%--								</thead>--%>
<%--								<tr>--%>
<%--									<td class="table-td">시간 <span class="required">*</span></td>--%>
<%--									<td style="padding: 6px 9px;">--%>
<%--										<select class="form-control" name="rec_shour" style="width: 60px;">--%>
<%--<%--%>
<%--										for(int i=0; i<=23; i++) --%>
<%--										{--%>
<%--											String tmp_hour = CommonUtil.getFormatString(Integer.toString(i), "00");--%>
<%--											out.print("<option value='"+tmp_hour+"'>"+tmp_hour+"시</option>\n");--%>
<%--										}--%>
<%--%>--%>
<%--										</select> :--%>
<%--										<select class="form-control" name="rec_smin" style="width: 60px;">--%>
<%--<%--%>
<%--										for(int i=0; i<=59; i++) --%>
<%--										{--%>
<%--											String tmp_min = CommonUtil.getFormatString(Integer.toString(i), "00");--%>
<%--											out.print("<option value='"+tmp_min+"'>"+tmp_min+"분</option>\n");--%>
<%--										}--%>
<%--%>--%>
<%--										</select> ~--%>
<%--										<select class="form-control" name="rec_ehour" style="width: 60px;">--%>
<%--<%--%>
<%--										for(int i=0; i<=23; i++) --%>
<%--										{--%>
<%--											String tmp_hour = CommonUtil.getFormatString(Integer.toString(i), "00");--%>
<%--											out.print("<option value='"+tmp_hour+"'>"+tmp_hour+"시</option>\n");--%>
<%--										}--%>
<%--%>--%>
<%--										</select> :--%>
<%--										<select class="form-control" name="rec_emin" style="width: 60px;">--%>
<%--<%--%>
<%--										for(int i=0; i<=59; i++) --%>
<%--										{--%>
<%--											String tmp_min = CommonUtil.getFormatString(Integer.toString(i), "00");--%>
<%--											out.print("<option value='"+tmp_min+"'>"+tmp_min+"분</option>\n");--%>
<%--										}--%>
<%--%>--%>
<%--										</select>--%>
<%--									</td>--%>
<%--								</tr>--%>
<%--								</table>--%>
<%--							</div>--%>
<%--							<div class="modal-footer">--%>
<%--								<button type="button" name="modal_regi" class="btn btn-primary btn-sm" prop=""><i class="fa fa-pencil"></i> 등록</button>--%>
<%--								<button type="button" name="modal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>--%>
<%--							</div>--%>
<%--						</form>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>
			<!-- 필수 중단 콜 끝 -->
			<!--팝업창 띠우기 끝-->
		</div>
		<!--treeDiv2 끝-->
	</div>
	<!--Data table 영역 끝-->
</div>
<!--wrapper-content영역 끝-->
<script>
	document.querySelector('input[name="cust_tel"]').addEventListener('input', function(e){
		// e.value = e.value.replace('/[^0-9]/g','');
		this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\.*)\./g, '$1');
	});
</script>
<jsp:include page="/include/bottom.jsp"/>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db != null)	db.close();
	}
%>

