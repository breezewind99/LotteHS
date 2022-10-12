<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/common.jsp" %>
<%!	static Logger logger = Logger.getLogger("rec_list.jsp"); %>
<%
//cookie 변수 선언
	String _TEMPLATE_COLOR	= CommonUtil.getCookieValue("ck_template_color");

	// DB Connection Object
	Db db = null;

	try {
		db = new Db(true);
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>녹취관리 시스템</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="Expires" content="-1" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<title>녹취관리 시스템</title>

	<link rel="icon" href="../img/icon/main.ico" type="image/x-icon" />
	<link rel="shortcut icon" href="../img/icon/main.ico" type="image/x-icon" />
	<link href="../css/smoothness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
	<link href="../css/bootstrap.css" rel="stylesheet" />
	<link href="../css/font-awesome.css" rel="stylesheet" />
	<link href="../css/animate.css" rel="stylesheet">
	<link href="../css/grid/pqgrid.min.css" rel="stylesheet" />
	<link href="../css/grid/office/pqgrid.css" rel="stylesheet" />
	<link href="../css/style<%=(!"".equals(_TEMPLATE_COLOR)) ? "_" + _TEMPLATE_COLOR : "" %>.css" rel="stylesheet" />

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

	<!-- jquery 실행하는 함수 -->

	<script type="text/javascript">
	$(function () {
		var colModel = [
			{ title: "순번", width: 40, dataIndx: "idx", sortable: false, editable: false },
			{ title: "일자", width: 40, dataIndx: "rec_date", sortable: false, editable: false },
			{ title: "시작시간", width: 40, dataIndx: "rec_start_time", sortable: false, editable: false },
			{ title: "종료시간", width: 40, dataIndx: "rec_end_time", sortable: false, editable: false },
			{ title: "경과시간", width: 40, dataIndx: "rec_call_time", sortable: false, editable: false },
			{ title: "내선번호", width: 40, dataIndx: "local_no", sortable: false, editable: false },
			{ title: "상담원ID", width: 40, dataIndx: "user_id", sortable: false, editable: false },
			{ title: "상담원명", width: 40, dataIndx: "user_name", sortable: false, editable: false },
			{ title: "전화번호", width: 40, dataIndx: "cust_tel", sortable: false, editable: false },
			{ title: "인아웃", width: 40, dataIndx: "rec_inout", sortable: false, editable: false },
			{ title: "다운로드", width: 40, dataIndx: "rec_filename", sortable: false, editable: false }
		];
		
		var baseDataModel = getBaseGridDM("rec_list");
		var dataModel = $.extend({}, baseDataModel, {
			//sortIndx: "rec_datm",
			sortDir: "down",
		});     
		
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부    
		var baseObj = getBaseGridOption("rec_search", "N", "N", "N", "N");
		// toolbar button add
		baseObj.toolbar.items.push(
			{ type: "button", icon: "ui-icon-gear", label: "", attr: "data-toggle='modal'",  listeners: [{ 
					"click": function () {
						// 리스트 설정버튼 클릭
						popResultConfig('R');		
					}								
				}]
			}    	
		);
		
		var obj = $.extend({}, baseObj, {
			colModel: colModel,
			dataModel: dataModel,
			scrollModel: { autoFit: true },
		});  
		
		// grid
		$grid = $("#grid").pqGrid(obj);
	});

	// 다운로드
	var downloadRecFile = function(rowIndx) {	
		var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
		var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,""); 
		
		$("#hiddenFrame").prop("src", "download.jsp?rec_seq="+rowData["rec_seq"]+"&rec_datm="+rec_datm);	
	};

	// 메모
	var memoRecData = function(rowIndx) {
		var rowData = $grid.pqGrid("getRowData", { rowIndxPage: rowIndx });
		var rec_datm = rowData["rec_datm"].replace(/\s|-|:|\./gi,"");
			
		openPopup("memo.jsp?rec_datm="+rec_datm+"&rec_seq="+rowData["rec_seq"],"_memo","478","590","yes","center");
	};
	</script>
</head>

<body style="overflow-y: scroll;">
<!--wrapper 시작-->
<div id="wrapper">
	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left; margin-left:10px;"><h4>조회</h4></div>
		<ol class="breadcrumb" style="float:right; margin-right:10px;">
	 		<li><a href="#none"><i class="fa fa-home"></i> 조회</a></li>
			<li class="active"><strong>조회</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->
	
	<!--wrapper-content영역-->
	<div class="wrapper-content" style="margin:0 10px 0 10px;">
		<!--ibox 시작-->
        <div class="ibox">
        <form id="search">
        	<input type="hidden" name="user_list" value=""/>
		<!--검색조건 영역-->
            <div class="ibox-content contentRadius1 conSize" >
				<!--1행 시작-->
	            <div id="recDiv1">
					<div id="labelDiv">
						<label class="simple_tag">일자</label>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="rec_date1" class="form-control rec_form1 datepicker" value="<%=DateUtil.getToday("")%>">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
		                </div>
						<!-- 달력 팝업 위치 끝-->
						<div class="input-group" style="display:inline-block;"><span class="form-control" style="padding: 3px 0px;border: 0px">~</span></div>
						<!-- 달력 팝업 위치 시작-->
						<div class="input-group" style="display:inline-block;">
							<input type="text" name="rec_date2" class="form-control rec_form1 datepicker" value="<%=DateUtil.getToday("")%>">
							<div class="input-group-btn">
								<button class="btn btn-default btn-datepicker" type="button"><i class="fa fa-calendar"></i></button>
							</div>
		                </div>
						<!-- 달력 팝업 위치 끝-->
					</div>
				</div>
				
				<div id="recDiv2">
					<div id="labelDiv">
						<label class="simple_tag">전화번호</label>
						<input type='text' class='form-control rec_form5' name='cust_tel' placeholder=''>
					</div>
				</div>
				<!--1행 끝-->	
            </div>
			<!--검색조건 영역 끝-->

			<!--유틸리티 버튼 영역-->
			<div class="contentRadius2 conSize">

				<!--ibox 접히기, 설정버튼 영역-->
				<div class="ibox-tools">
					<a class="collapse-link">
						<button type="button" class="btn btn-default btn-sm"><i class="fa fa-chevron-up"></i> </button>
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
				<!--팝업창 띠우기 끝-->	
			</div>
			<!--treeDiv2 끝-->	
		</div>
		<!--Data table 영역 끝-->
    </div>
	<!--wrapper-content영역 끝-->        
<!--wrapper 끝-->
</div>
<iframe id="hiddenFrame" style="display: none;"></iframe>
</body>
</html>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
    	if(db!=null) db.close();
    }
%>	