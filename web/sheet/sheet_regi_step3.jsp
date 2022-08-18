<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// 메뉴 접근권한 체크
	if(!Site.isPmss(out,"sheet","")) return;
	
	try 
	{
		// 세션 데이터
		String _SHEET_REGI_DATA = (String) session.getAttribute("sheet_regi_data");
	
		if(!CommonUtil.hasText(_SHEET_REGI_DATA)) 
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_WRONG"),"sheet_regi_step1.jsp","url"));
		}
	
		// 1단계에서 선택한 카테고리 코드목록 추출
		JSONParser jsonParser = new JSONParser();
		JSONObject jsonObj = (JSONObject) jsonParser.parse(_SHEET_REGI_DATA);
		JSONArray jsonArr = (JSONArray) jsonObj.get("cate");
		JSONArray jsonItemArr = (JSONArray) jsonObj.get("item");
		JSONArray jsonExamArr = (JSONArray) jsonObj.get("exam");
	
	 	// 선택된 카테고리 또는 평가항목이 없다면 에러 처리
		if(jsonArr == null || jsonItemArr == null) 
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_WRONG"),"sheet_regi_step1.jsp","url"));
		}
	
	 	// 선택된 카테고리 코드 리스트 변수 생성
		String cate_codes = "";
		for(int i=0; i<jsonArr.size(); i++)
		{
			JSONObject jsonItem = (JSONObject) jsonArr.get(i);
	
			cate_codes += "," + jsonItem.get("code");
		}
		cate_codes = cate_codes.substring(1);
	
		// 등록된 평가항목 보기 건수
		int regi_exam_cnt = (jsonExamArr!=null) ? jsonExamArr.size() : 0;

%>
<jsp:include page="/include/top.jsp" flush="false"/>
<link rel="stylesheet" href="../css/tree/default/style.css" />
<script type="text/javascript" src="../js/plugins/tree/jstree.min.js"></script>
<script type="text/javascript">
var tree;
//평가항목 보기 등록건수
var regi_exam_cnt = <%=regi_exam_cnt%>;

$(function () {
	//tree
	tree = $("#tree").jstree({
		"core" : {
			"data" : {
				"url": "/common/get_eval_cate_tree.jsp",
				"data": "cate_codes=<%=cate_codes%>&use_yn=1",
				"dataType": "json",
			},
			"themes" : {
				"variant" : "medium"
			}
		},
		"types" : {
			"depth1" : {
				"icon" : "../img/tree_depth1_close.gif"
			},
			"depth2" : {
				"icon" : "jstree-file"
			}
		},
		"plugins" : ["types"]
	});

	tree.bind("loaded.jstree", function() {
		tree.jstree("open_all");
		tree.jstree("select_node", "ul>li:first-child ul>li:first-child");
	});

	// tree checkbox 선택/해제 시
	tree.bind("select_node.jstree", function(obj, data) {
		getItemList(0, "", data.node.id);
	});

	// 이전 버튼 클릭
	$("#regi button[name=btn_prev]").click(function() {
		location.replace("sheet_regi_step2.jsp");
	});

	// 전체 선택
	$("button[name=btn_check_all]").click(function() {
		checkObject($("#regi input[name=exam_code]"), true);
	});

	// 전체 선택해제
	$("button[name=btn_uncheck_all]").click(function() {
		checkObject($("#regi input[name=selected_exam_code]"), true);
	});

	// 전체선택,선택,전체선택해제,선택해제 버튼 클릭
	$("button[name=btn_check_all], button[name=btn_check], button[name=btn_uncheck_all], button[name=btn_uncheck]").click(function() {
		var step = ($(this).attr("name").indexOf("uncheck")>-1) ? "delete" : "insert";

		checkExam(step, "");
	});

	// 저장버튼 클릭
	$("button[name=btn_save]").click(function() {
		regiSheet();
	});

	// 취소버튼 클릭
	$("button[name=btn_cancel]").click(function() {
		checkExam("reset", "");
	});
});

var regiSheet = function() {
	if(regi_exam_cnt<1) {
		alert("평가항목 보기를 하나 이상 선택해 주십시오.");
		return;
	}

	$.ajax({
		type: "POST",
		url: "remote_sheet_regi_proc.jsp",
		async: false,
		data: "step=finish",
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="OK") {
				location.replace("sheet.jsp");
				return true;
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
};

var checkExam = function(proc, exam_code) {
	var exam_list = [];
	var cate_code = $("#item_list").attr("cate_code");
	var parent_idx = $("#exam_list").attr("idx");
	var parent_code = $("#exam_list").attr("item_code");

	if(proc!="reset") {
		var prefix = (proc!="insert") ? "selected_" : "";

		if(exam_code!="") {
			exam_list.push({
				cate_code: cate_code,
				item_code: parent_code,
				code: exam_code,
				name: "",
				score: 0,
				add: 0,
				default_yn: "n"
			});
		} else {
			$("#regi input[name="+prefix+"exam_code]").each(function(idx){
				if($(this).prop("checked")) {
					var score = toNN($("input[name="+prefix+"exam_score]").eq(idx).val(),"0");
					var add = toNN($("input[name="+prefix+"exam_add]").eq(idx).val(),"0");

					var default_yn_obj = $("#regi input[name="+prefix+"default_yn]")[idx];
					var default_yn = (default_yn_obj.checked) ? default_yn_obj.value : "n";

					var tmp = {
						cate_code: cate_code,
						item_code: parent_code,
						code: $(this).val(),
						name: $(".txt_"+prefix+"exam_name").eq(idx).html(),
						score: score,
						add: add,
						default_yn: default_yn
					};
					exam_list.push(tmp);
				}
			});
		}

		if(exam_list.length<1) {
			alert("평가항목 보기를 하나 이상 선택해 주십시오.");
			return;
		}

		if(proc=="insert") {
			regi_exam_cnt += exam_list.length;
		} else {
			regi_exam_cnt -= exam_list.length;
		}
	} else {
		regi_exam_cnt = 0;
	}

	//alert("proc="+proc+", exam_list="+JSON.stringify(exam_list));
	$.ajax({
		type: "POST",
		url: "remote_sheet_regi_proc.jsp",
		async: false,
		data: "step=step3&proc="+proc+"&exam_list="+JSON.stringify(exam_list),
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="OK") {
				// data reload
				getItemList(parent_idx, parent_code, cate_code);
				return true;
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
};

var getItemList = function (idx, parent_code, cate_code) {
	if(cate_code=="") return;

	// 초기화
	$("#exam_list").html("<tr><td colspan=\"5\">등록된 평가 보기가 없습니다.</td></tr>");
	$("#selected_exam_list").html("<tr><td colspan=\"5\">선택된 평가 보기가 없습니다.</td></tr>");

	// 카테고리 코드 설정
	$("#item_list").attr("cate_code", cate_code);

	$.ajax({
		type: "POST",
		url: "remote_sheet_regi.jsp",
		async: false,
		data: "step=step3&cate_code="+cate_code+"&parent_code="+parent_code+"&item_depth=2",
		dataType: "json",
		success:function(dataJSON){
			if(dataJSON.code=="ERR") {
				alert(dataJSON.msg);
				return false;
			} else {
				// 선택된 카테고리별 평가항목 목록
				var html = "";
				if(dataJSON.item!=undefined && dataJSON.item.length>0) {
					var odd = "";
					var n = 0;
					for(var i=0;i<dataJSON.item.length;i++) {
						if(cate_code==dataJSON.item[i].cate_code) {
							odd = (i%2==1) ? " odd" : "";
							html += "<tr class=\"item_row"+odd+"\" prop=\""+dataJSON.item[i].code+"\">";
							html += "	<td>"+(n+1)+"</td>";
							html += "	<td class=\"t-left\"><a href=\"#none\" onclick=\"getItemList("+n+",'"+dataJSON.item[i].code+"','"+dataJSON.item[i].cate_code+"');\" class=\"txt_item_name\">"+dataJSON.item[i].name+"</a></td>";
							html += "</tr>";
							n++;
						}
					}
					$("#item_list").html(html);
				}

				// 카테고리별 평가항목 보기 목록
				var html = "";
				if(dataJSON.exam!=undefined && dataJSON.exam.length>0) {
					var odd = "";
					for(var i=0;i<dataJSON.exam.length;i++) {
						odd = (i%2==1) ? " odd" : "";
						html += "<tr class='exam_row"+odd+"'>"+
								"<td><input type='checkbox' name='exam_code' value='"+dataJSON.exam[i].item_code+"' checked='checked'></td>"+
								"<td class='t-left'><span class='txt_exam_name'>"+dataJSON.exam[i].item_name+"</span></td>"+
								"<td><input type='text' class='form-control' name='exam_score' value='' placeholder=''></td>"+
								"<td><input type='text' class='form-control' name='exam_add' value='' placeholder=''></td>"+
								"<td><input type='checkbox' name='default_yn' value='y' placeholder='' onclick=chgExamDefault("+i+")></td>"+
								"</tr>";
					}
					$("#exam_list").html(html);
				}

				// 선택한 평가항목 보기 목록
				html = "";
				if(dataJSON.selexam!=undefined && dataJSON.selexam.length>0) {
					var odd = "";
					for(var i=0;i<dataJSON.selexam.length;i++) {
						if(dataJSON.selexam[i].item_code==$(".item_row").eq(idx).attr("prop")) {
							odd = (i%2==1) ? " odd" : "";
							//alert("dataJSON.selexam[i].default_yn="+dataJSON.selexam[i].default_yn)
							html += "<tr class='selected_exam_row"+odd+"'>"+
									"<td><input type='checkbox' name='selected_exam_code' value='"+dataJSON.selexam[i].code+"' checked='checked'></td>"+
									"<td class='t-left'><span class='txt_selected_exam_name'>"+dataJSON.selexam[i].name+"</span></td>"+
									"<td><input type='text' class='form-control' name='selected_exam_score' value='"+dataJSON.selexam[i].score+"' readonly='readonly' style='border:0; background:transparent;'></td>"+
									"<td><input type='text' class='form-control' name='selected_exam_add' value='"+dataJSON.selexam[i].add+"' readonly='readonly' style='border:0; background:transparent;'></td>"+
									"<td>"+((dataJSON.selexam[i].default_yn=="y") ? "<img src=../img/icon/ico_selected.gif>" : "")+"</td><input type=hidden name=selected_default_yn value='"+dataJSON.selexam[i].default_yn+"'>"+
									"</tr>";
						}
					}

					if(html!="") {
						$("#selected_exam_list").html(html);
					}
				}
			}
		},
		error:function(req,status,err){
			alertJsonErr(req,status,err);
			return false;
		}
	});

	// all deselect
	$(".item_row").each(function(i){
		$(".item_row").eq(i).removeClass("odd5");
	});
	// select
	$(".item_row").eq(idx).addClass("odd5");

	// 평가 항목 순번 설정
	$("#exam_list").attr("idx", idx);

	// 부모 코드 설정
	$("#exam_list").attr("item_code", (parent_code!="") ? parent_code : $(".item_row").eq(idx).attr("prop"));
};

function chgExamDefault(idx){
	var objs = $("#regi input[name=default_yn]");
	if(objs[idx].checked){
		for(var i=0, len=objs.length; i<len; i++){
			if(i!=idx) objs[i].checked = false;
		}
	}
}
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>시트 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 시트 관리</a></li>
			 <li>시트 관리</li>
			 <li>시트 등록</li>
			 <li class="active"><strong>단계 3</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div style="padding-top: 15px;">
		<!--class conSize 시작-->
		<div class="conSize">
			<!--평가 카테고리 트리메뉴 시작-->
			<div id="frameDiv1">
				<div class="categoryFrame1">
				<h5>평가 카테고리</h5>
				</div>
				<div class="categoryFrame2">
					<!-- 카테고리 tree -->
					<div id="tree"></div>
					<!-- 카테고리 tree 끝 -->
				</div>
			</div>
			<!--평가 카테고리 트리메뉴 끝-->

			<!--컨텐츠 영역 시작-->
			<div id="frameDiv3">
				<form id="regi">
					<div class="bullet"><i class="fa fa-angle-right"></i></div><h5 class="table-title3">평가 보기 등록</h5>
					<!--table-->
					<table class="table top-line1 table-bordered tt">
						<thead>
							<tr>
								<th style="width:60px;">순번</th>
								<th>평가 항목</th>
							</tr>
						</thead>
						<tbody id="item_list" cate_code="">
						</tbody>
					</table>
					<!--table 끝-->

					<!-- s-space -->
					<div class="s-space">
						<!--left table-->
						<div class="colLeft tableSize">
							<table class="table top-line1 table-bordered tt">
								<thead>
									<tr>
										<th style="width:60px;">선택</th>
										<th>평가 보기</th>
										<th style="width:70px;">배점</th>
										<th style="width:70px;">가중치</th>
										<th style="width:70px;">기본선택</th>
									</tr>
								</thead>
								<tbody id="exam_list" idx="0" item_code="">
								</tbody>
							</table>
							<!--버튼 -->
							<div class="colLeft">
								<button type="button" name="btn_prev" class="btn btn-default btn-sm"><i class="fa fa-caret-left"></i> 이전</button>
							</div>

							<div class="colRight">
							</div>
						<!--버튼 끝 -->
						</div>
						<!-- left table 끝-->

						<!--버튼들-->
						<ul class="buttonDiv2">
							<li><button type="button" name="btn_check_all" class="btn btn-default btn-sm b-t"><i class="fa fa-angle-double-right"></i> </button></li>
							<li><button type="button" name="btn_check" class="btn btn-default btn-pp t-space"><i class="fa fa-angle-right"></i> </button></li>
							<li><button type="button" name="btn_uncheck_all" class="btn btn-default btn-sm b-t"><i class="fa fa-angle-double-left"></i> </button></li>
							<li><button type="button" name="btn_uncheck" class="btn btn-default btn-pp t-space"><i class="fa fa-angle-left"></i> </button></li>
						</ul>
						<!--버튼들 끝-->

						<!--right table-->
						<div class="colRight tableSize t-space">
							<table class="table top-line1 table-bordered">
								<thead>
									<tr>
										<th style="width:60px;">선택</th>
										<th>평가 보기</th>
										<th style="width:70px;">배점</th>
										<th style="width:70px;">가중치</th>
										<th style="width:70px;">기본선택</th>
									</tr>
								</thead>
								<tbody id="selected_exam_list">
								</tbody>
							</table>
							<!--버튼 -->
							<div class="colRight">
								<button type="button" name="btn_save" class="btn btn-register btn-sm"><i class="fa fa-check"></i> 저장</button>
								<button type="button" name="btn_cancel" class="btn btn-default btn-sm"><i class="fa fa-times"></i> 취소</button>
							</div>
							<!--버튼 끝 -->
						</div>
						<!-- right table 끝-->
					</div>
					<!-- s-space 끝-->
				</form>
			</div>
			<!--컨텐츠 영역 끝-->

		</div>
		<!--class conSize 끝-->

	</div>
	<!--wrapper-content영역 끝-->

<jsp:include page="/include/bottom.jsp"/>
<%

}
catch(Exception e) {
	logger.error(e.getMessage());
}
finally {

}
%>
