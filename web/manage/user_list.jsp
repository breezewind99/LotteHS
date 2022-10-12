<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_mgmt","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String part_code = CommonUtil.getParameter("part_code", "");
		String user_id = CommonUtil.getParameter("user_id", "");
		String user_name = CommonUtil.getParameter("user_name", "");
		String local_no = CommonUtil.getParameter("local_no", "");

		Map<String,Object> argMap = new HashMap();

		// part_path 조회
		String part_path = "";
		if(CommonUtil.hasText(part_code)) 
		{
			argMap.clear();
			argMap.put("business_code",CommonUtil.leftString(part_code, 2));
			//argMap.put("bpart_code",part_code.substring(2, 7));
			//argMap.put("mpart_code",part_code.substring(7, 12));
			//argMap.put("spart_code",part_code.substring(12, 17));
			argMap.put("bpart_code",part_code.substring(2, 2+(_PART_CODE_SIZE*1)));
			argMap.put("mpart_code",part_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2)));
			argMap.put("spart_code",part_code.substring(2+(_PART_CODE_SIZE*2), 2+(_PART_CODE_SIZE*3)));

			part_path = db.selectOne("user_group.selectUserGroupPath", argMap);
		}

		//시스템 코드 조회
		argMap.clear();
		argMap.put("tb_nm", "system");		//테이블 정보
		argMap.put("system_rec", "1");
		
		String jsnSysList = Site.getCommComboHtml("j", argMap);
		String htm1SysList = Site.getCommComboHtml("h1", argMap);
		
		//공통 코드 조회(등급)
		argMap.clear();
		argMap.put("tb_nm", "code");		//테이블 정보
		argMap.put("_parent_code", "USER_LEVEL");
		
		String jsnUserLvList = Site.getCommComboHtml("j", argMap);
		String htm1UserLvList = Site.getCommComboHtml("h1", argMap);
%>
<script type="text/javascript">

	//평가관리 관련 기능 미노출 여부
	var isEval = <%=Finals.isEval%>;
	
	//녹취 다운로드 여부 미노출 및 기능 사용 여부 - CJM(20181218)
	var isRecDownload = <%=Finals.isRecDownload%>;
	
	//채널 미노출 여부 - CJM(20190625)
	//IP : I TDM : T
	var isChannel = <%=Finals.isChannel%>;
	
	//비밀번호 사용 기간 노출, 미노출 및 기능 사용 여부 - CJM(20201112)
	var isPassChgTerm = <%=Finals.isPassChgTerm%>;
	
	$(function () 
	{
		$(".evalUser").css("display",(isEval) ? "none" : "");
		$(".downUser").css("display",(isRecDownload) ? "none" : "");
		$(".channelExp").css("display",(isChannel) ? "none" : "");
		$(".passTerm").css("display",(isPassChgTerm) ? "none" : "");
		
		var colModel = [
			{ title: "순번", width: 40, dataIndx: "idx", editable: false, sortable: false },
			{ title: "상담원ID", width: 80, dataIndx: "user_id", editable: false },
			{ title: "비밀번호", width: 80, dataIndx: "user_pass", editor: {type: "textbox", attr: "type='password'"},
				validations: [
					{ type: function(ui) {
						var msg = checkPasswd(ui.rowData["user_id"], ui.value, true);
						if(msg != "") 
						{
							ui.msg = msg;
							return false;
						}
					}}
				],
			},
			{ title: "상담사명", width: 90, dataIndx: "user_name",
				validations: [
					{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
				]
			},
			{ title: "내선번호", width: 70, dataIndx: "local_no",
				validations: [
					{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
				]
			},
			//채널 노출 상태에 따라 변경 - CJM(20190625)
			{ title: "채널번호", width: 80, dataIndx: "channel_no", editable: !isChannel, sortable: false},
			{ title: "녹취구분", dataIndx: "rec_div", hidden: true },
			
			/*
			{ title: "채널번호", width: 80, dataIndx: "channel_no", hidden: isChannel,
				validations: [
					{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
					{ type: "maxLen", value: "3", msg: "3자리 이하로 입력해 주십시오." },
				]
			},*/
			{ title: "시스템명", width: 80, dataIndx: "system_code",
				editor: {
					type: 'select',
					options: [<%=jsnSysList%>]
				},
				render: function(ui) {
	
					var options = ui.column.editor.options,
						cellData = ui.cellData;
					for(var i = 0; i < options.length; i++) 
					{
						var option = options[i];
						if(option[cellData]) 
						{
							return option[cellData];
						}
					}
	
				},
			},
			{ title: "등급", width: 80, dataIndx: "user_level",
				editor: {
					type: 'select',
					options: [<%=jsnUserLvList%>]
				},
				render: function(ui) {
	
					var options = ui.column.editor.options,
						cellData = ui.cellData;
					for(var i = 0; i < options.length; i++) 
					{
						var option = options[i];
						if(option[cellData]) 
						{
							return option[cellData];
						}
					}
	
				},
			},
			{ title: "평가자", width: 80, dataIndx: "eval_yn",hidden: isEval,
				editor: {
					type: 'select',
					options: [{'n':'×'}, {'y':'o'}]
				},
				render: function(ui) {
					var options = ui.column.editor.options,
						cellData = ui.cellData;
					for(var i = 0; i < options.length; i++) 
					{
						var option = options[i];
						if(option[cellData]) 
						{
							return option[cellData];
						}
					}
				},
			},
			//상담원 별 세부 다운로드 권한 추가 -CJM(20181217)
			{ title: "녹취 다운로드", width: 95, dataIndx: "rec_down_yn", align: "center",hidden: isRecDownload,
				editor: {
					type: 'select',
					options: [{'n':'×'}, {'y':'o'}]
				},
				render: function(ui) {
					var options = ui.column.editor.options,
						cellData = ui.cellData;
					for(var i = 0; i < options.length; i++) 
					{
						var option = options[i];
						if(option[cellData]) 
						{
							return option[cellData];
						}
					}
				},
			},
			{ title: "기존등급", dataIndx: "origin_level", hidden: true },
			
			// 비밀번호 사용 기간 노출, 미노출 기능 적용 - CJM(20201112)
			{ title: "비밀번호 사용기간", width: 80, dataIndx: "pass_chg_term", hidden: isPassChgTerm,
				editor: {
					type: 'select',
					options: [{'90':'90일'}, {'60':'60일'}, {'30':'30일'}, {'10':'10일'}, {'7':'7일'}, {'1':'1일'}, {'0':'제한없음'}]
				},
				render: function(ui) {
					var options = ui.column.editor.options,
						cellData = ui.cellData;
					for (var i = 0; i < options.length; i++) {
						var option = options[i];
						if (option[cellData]) {
							return option[cellData];
						}
					}
				},
			},
			{ title: "비밀번호 만료일자", width: 80, dataIndx: "pass_expire_date", hidden: isPassChgTerm, editable: false },
			
			{ title: "비밀번호 변경일자", width: 120, dataIndx: "pass_upd_date", editable: false },
			{ title: "아이피", width: 100, dataIndx: "user_ip"},
			{ title: "퇴사여부", width: 80, dataIndx: "resign_yn",
				editor: {
					type: 'select',
					options: [{'1':'퇴사'}, {'0':'재직'}]
				},
				render: function(ui) {
	
					var options = ui.column.editor.options,
						cellData = ui.cellData;
					for(var i = 0; i < options.length; i++) 
					{
						var option = options[i];
						if(option[cellData])
						{
							return option[cellData];
						}
					}
	
				},
			},
			{ title: "사용여부", width: 80, dataIndx: "use_yn",
				editor: {
					type: 'select',
					options: fn.usedCode.colModel
				},
				render: function(ui) {
	
					var options = ui.column.editor.options,
						cellData = ui.cellData;
					for(var i = 0; i < options.length; i++) 
					{
						var option = options[i];
						if(option[cellData]) 
						{
							return option[cellData];
						}
					}
	
				},
			},
			{ title: "등록일자", width: 80, dataIndx: "regi_datm", editable: false,
				render: function (ui) {
					return ui.rowData["regi_datm"].substring(0,10);
				}
			},
			{ title: "잠금해제", width: 65, editable: false, sortable: false,
				render: function (ui) {
					if(ui.rowData["lock_yn"] == "1") 
					{
						return "<img src='../img/icon/ico_unlock.png' class='btn_unlock' style='position: absolute; padding: 0px 0px 0px 15px;'/>";
					} 
					else 
					{
						return "";
					}
				}
			}
			<%if(Finals.isManageModify) {%>
			,{ title: "수정", width: 40, editable: false, sortable: false,
				render: function (ui) {
					//return "<img src='../img/icon/ico_edit.png' class='btn_edit' onclick='editUser("+ui.rowIndx+");' style='margin:0; padding:0px 1px 5px 2px; width:11.2px;height:auto;cursor: pointer;'/>";
					// 이미지 영역 문제로 스크롤 이상 현상 - CJM(20180808)
					return "<img src='../img/icon/ico_edit.png' class='btn_edit' onclick='editUser("+ui.rowIndx+");' style='position: absolute; padding: 0px 0px 0px 5px; cursor: pointer;'/>";
					//return "<img src='../img/icon/ico_edit.png' class='btn_edit' onclick='editUser("+ui.rowIndx+");' style='margin:0; padding:0px; cursor: pointer;'/>";
					
					//margin: 0px; padding: 0px 1px 5px 2px; height: auto; cursor: pointer;
					//padding: 0px 0px 0px 5px; cursor: pointer;
				}
			},		
			{ title: "삭제", width: 40, editable: false, sortable: false, render: function (ui) {
					return "<img src='../img/icon/ico_delete.png' class='btn_delete' style='position: absolute; padding: 0px 0px 0px 5px;'/>";
				}
			}
			<%}%>
		];
		
		var baseDataModel = getBaseGridDM("<%=page_id%>");
		var dataModel = $.extend({}, baseDataModel, {
			//sortIndx: "regi_datm",
			sortDir: "down",
			recIndx: "user_id"
		});
	
		// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
		<%if(Finals.isManageModify) {%>
		var baseObj = getBaseGridOption("user_list", "Y", "Y", "Y", "Y");
		<%} else {%>
		var baseObj = getBaseGridOption("user_list", "Y", "N", "N", "N");
		<%}%>
		// grid 크기 조절 활성화 - CJM(20180808)
		var obj = $.extend({}, baseObj, {
			colModel: colModel,
			dataModel: dataModel,
			scrollModel: { autoFit: false, theme : true },
			//scrollModel: { autoFit: false, lastColumn : 'none', flexContent : true },
		});
	
		$grid = $("#grid").pqGrid(obj);
		
	
		// 상담원 등록폼 오픈시
		$("#modalRegiForm").on("show.bs.modal", function(e) {
			// 업무 구분/대분류/중분류/소분류 셋팅
			var part_path = "<%=part_path%>";
			if(part_path == "") 
			{
				alert("선택된 조직도가 존재해야만 등록 가능합니다.");
				return false;
			}
	
			var part_arr = part_path.split(":");
	  		$("#regi #business_name").text(part_arr[0]);
	  		$("#regi #bpart_name").text(part_arr[1]);
	  		$("#regi #mpart_name").text(part_arr[2]);
	  		$("#regi #spart_name").text(part_arr[3]);
	  		
			$("#regi select[name=user_level]").html("");
			$("#regi select[name=user_level]").append("<%=htm1UserLvList%>");
			
			$("#regi select[name=system_code]").html("");
			$("#regi select[name=system_code]").append("<%=htm1SysList%>");
			
			// 비밀번호 사용기간 제한 없음 selected - CJM(20201112)
			if(!isPassChgTerm)	$("#regi select[name=pass_chg_term]").val("0").prop("selected", true);
			
		});
	
		// 상담원 등록 저장
		$("#regi button[name=modal_regi]").click(function() {
			if(!$("#regi input[name=user_id]").val().trim()) 
			{
				alert("상담원ID를 입력해 주십시오.");
				$("#regi input[name=user_id]").focus();
				return false;
			}
			if(!$("#regi input[name=user_pass]").val().trim()) 
			{
				alert("비밀번호를 입력해 주십시오.");
				$("#regi input[name=user_pass]").focus();
				return false;
			}
			if(!checkPasswd($("#regi input[name=user_id]").val().trim(), $("#regi input[name=user_pass]").val().trim(), false)) 
			{
				$("#regi input[name=user_pass]").focus();
				return false;
			}
			if(!$("#regi input[name=user_name]").val().trim()) 
			{
				alert("상담사명을 입력해 주십시오.");
				$("#regi input[name=user_name]").focus();
				return false;
			}
			if(!$("#regi input[name=local_no]").val().trim()) 
			{
				alert("내선 번호를 입력해 주십시오.");
				$("#regi input[name=local_no]").focus();
				return false;
			}
			if(!isChannel)
			{
				if($("#regi input[name=channel_no]") && !$("#regi input[name=channel_no]").val().trim()) {
					alert("채널 번호를 입력해 주십시오.");
					$("#regi input[name=channel_no]").focus();
					return false;
				}
			}
	
			$.ajax({
				type: "POST",
				url: "remote_user_list_proc.jsp",
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
		
		// 상담원 수정폼 오픈시
		$("#edModalRegiForm").on("show.bs.modal", function(e) 
		{
	//		console.log("상담원 수정폼 오픈 START");
	
			//대분류
			var businessCode = $("#partRegi input[name=business_code]");
			chgPartCode(businessCode);
			
			//중분류
			var bpartCode = $("#partRegi input[name=bpart_code]");
			chgPartCode(bpartCode);
			
			//소분류
			var mpartCode = $("#partRegi input[name=mpart_code]");
			chgPartCode(mpartCode);
			
			$("#partRegi select[name=user_level]").html("");
			$("#partRegi select[name=user_level]").append("<%=htm1UserLvList%>");
			
			$("#partRegi select[name=system_code]").html("");
			$("#partRegi select[name=system_code]").append("<%=htm1SysList%>");
			
	//		console.log("상담원 수정폼 오픈 END");
		});
		
		// 상담원 수정 저장
		$("#partRegi button[name=edModal_regi]").click(function() 
		{
			if(!$("#partRegi select[name=bpart_code]").val().trim()) 
			{
				alert("대분류를 선택해 주십시오.");
				$("#partRegi select[name=bpart_code]").focus();
				return false;
			}
			if(!$("#partRegi select[name=mpart_code]").val().trim()) 
			{
				alert("중분류를 선택해 주십시오.");
				$("#partRegi select[name=mpart_code]").focus();
				return false;
			}
			if(!$("#partRegi select[name=spart_code]").val().trim()) 
			{
				alert("소분류를 선택해 주십시오.");
				$("#partRegi select[name=spart_code]").focus();
				return false;
			}
			if(!$("#partRegi input[name=user_name]").val().trim()) 
			{
				alert("상담사명을 입력해 주십시오.");
				$("#partRegi input[name=user_name]").focus();
				return false;
			}
			if(!$("#partRegi input[name=local_no]").val().trim()) 
			{
				alert("내선 번호를 입력해 주십시오.");
				$("#partRegi input[name=local_no]").focus();
				return false;
			}
			if(!isChannel)
			{
				if(!$("#partRegi input[name=channel_no]").val().trim()) 
				{
					alert("채널 번호를 입력해 주십시오.");
					$("#partRegi input[name=channel_no]").focus();
					return false;
				}
			}
			
			$.ajax({
				type: "POST",
				url: "remote_user_list_proc.jsp",
				async: false,
				data: "step=partUp&"+$("#partRegi").serialize(),
				dataType: "json",
				success:function(dataJSON){
					if(dataJSON.code == "OK") 
					{
						alert("정상적으로 수정되었습니다.");
						$("#edModalRegiForm").modal("hide");
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
	
		// 잠금해제 실행
		$grid.on("pqgridrefresh", function(event, ui) {
			$grid.find(".btn_unlock")
			.unbind("click")
			.bind("click", function (evt) {
				if(confirm("정말로 잠금해제 하시겠습니까?")) 
				{
					var $tr = $(this).closest("tr");
					var rowIndx = $grid.pqGrid("getRowIndx", { $tr: $tr }).rowIndx;
					var recIndx = $grid.pqGrid("getRecId", { rowIndx: rowIndx });
	
					$.ajax({
						type: "POST",
						url: "remote_user_list_proc.jsp",
						async: false,
						data: "step=unlock&row_id="+recIndx,
						dataType: "json",
						success:function(dataJSON){
							if(dataJSON.code == "OK") 
							{
								alert("정상적으로 잠금해제 되었습니다.");
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
				}
			});
		});
		
		/*상담사 관리 수정 조직도 조회*/
		$("#partRegi select[name=bpart_code], #partRegi select[name=mpart_code]").change(function(){
			chgPartCode($(this));
	
			$("#partRegi input[name=bpart_code]").val($("#partRegi select[name=bpart_code]").val());
			$("#partRegi input[name=mpart_code]").val($("#partRegi select[name=mpart_code]").val());
		});
	});

	//수정
	function editUser (rowIndx) {
		var data = $grid.pqGrid("getRowData", { rowIndxPage:	rowIndx	});
		
		$("#partRegi input[name=business_code]").val(data.business_code);
		$("#partRegi input[name=bpart_code]").val(data.bpart_code);
		$("#partRegi input[name=mpart_code]").val(data.mpart_code);
		
		//패스워드 수정 일자  - CJM(20201202)
		$("#partRegi input[name=pass_upd_date]").val(data.pass_upd_date);
		
		$("#edModalRegiForm").modal("show");
		
	//	console.log("editUser START");
	
		//업무구분
		$("#partRegi #business_name").text(data.business_name);
		
		//대분류
		//$("#partRegi select[name=bpart_code]").val(data.bpart_code);
		$("#partRegi select[name=bpart_code]").val(data.bpart_code).prop("selected", true);
		
		//중분류
		//$("#partRegi select[name=mpart_code]").val(data.mpart_code);
		$("#partRegi select[name=mpart_code]").val(data.mpart_code).prop("selected", true);
		//$("#partRegi select[name=mpart_code]").val(data.mpart_code).attr("selected", "selected");
		//소분류
		$("#partRegi select[name=spart_code]").val(data.spart_code).prop("selected", true);
		
		//상담원ID
		$("#partRegi input[name=user_id]").val(data.user_id);
		$("#partRegi input[name=user_id]").attr("readonly", "true");
		
		//상담사명
		$("#partRegi input[name=user_name]").val(data.user_name);
		//$("#partRegi input[name=user_name]").attr("disabled", "true");
		
		//내선번호
		$("#partRegi input[name=local_no]").val(data.local_no);
		//$("#partRegi input[name=local_no]").attr("disabled", "true");
		
		//채널번호
		$("#partRegi input[name=channel_no]").val(data.channel_no);
		//$("#partRegi input[name=channel_no]").attr("disabled", "true");
		
		//시스템명
		$("#partRegi select[name=system_code]").val(data.system_code).prop("selected", true);
		
		//등급
		$("#partRegi select[name=user_level]").val(data.user_level).prop("selected", true);
		$("#partRegi input[name=origin_level]").val(data.origin_level);
		
		//평가자 여부
		$("#partRegi input:radio[name=eval_yn]:radio[value="+data.eval_yn+"]").prop("checked", true);
	
		//아이피
		$("#partRegi input[name=user_ip]").val(data.user_ip);
		
	//	console.log("editUser END");
	}

</script>
	<div class="bullet"><i class="fa fa-angle-right"></i></div>
	<h5 style="margin-top:0;color:#2e71b9">상담사 관리</h5>
	<div class="hr2" style="margin-bottom: 12px;"></div>
	<form id="search">
		<input type="hidden" name="part_code" value="<%=part_code%>"/>
		<input type="hidden" name="user_id" value="<%=user_id%>"/>
		<input type="hidden" name="user_name" value="<%=user_name%>"/>
		<input type="hidden" name="local_no" value="<%=local_no%>"/>
	</form>
	<!--grid 영역-->
	<div id="grid"></div>
	<!--grid 영역 끝-->
	<!--팝업창 띠우기-->
	<div class="modal inmodal" id="modalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content animated fadeIn">
				<form id="regi">
					<input type="hidden" name="part_code" value="<%=part_code%>"/>

					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="modal-title">상담사 등록</h4>
					</div>
					<div class="modal-body" >
						<!--업무코드 table-->
						<table class="table top-line1 table-bordered2">
							<thead>
							<tr>
								<td style="width:40%;" class="table-td">업무구분</td>
								<td style="width:60%; padding: 6px 9px;">
									<span id="business_name"></span>
								</td>
							</tr>
							</thead>
							<tr>
								<td class="table-td">대분류</td>
								<td style="padding: 6px 9px;">
									<span id="bpart_name"></span>
								</td>
							</tr>
							<tr>
								<td class="table-td">중분류</td>
								<td style="padding: 6px 9px;">
									<span id="mpart_name"></span>
								</td>
							</tr>
							<tr>
								<td class="table-td">소분류</td>
								<td style="padding: 6px 9px;">
									<span id="spart_name"></span>
								</td>
							</tr>
							<tr>
								<td class="table-td">상담원ID <span class="required">*</span></td>
								<td>
									<input type="text" name="user_id" class="form-control" id="" placeholder="" maxlength="20">
								</td>
							</tr>
							<tr>
								<td class="table-td">비밀번호 <span class="required">*</span></td>
								<td>
									<input type="password" name="user_pass" class="form-control" id="" placeholder="" maxlength="30">
								</td>
							</tr>
							<tr>
								<td class="table-td">상담사명 <span class="required">*</span></td>
								<td>
									<input type="text" name="user_name" class="form-control" id="" placeholder="" maxlength="20">
								</td>
							</tr>
							<tr>
								<td class="table-td">내선번호 <span class="required">*</span></td>
								<td>
									<input type="text" name="local_no" class="form-control" id="" placeholder="" maxlength="15">
								</td>
							</tr>
							<tr>
							<tr class="channelExp">
								<td class="table-td">채널번호 <span class="required">*</span></td>
								<td>
									<input type="text" name="channel_no" class="form-control" id="" placeholder="" maxlength="3">
								</td>
							</tr>
							<tr>
								<td class="table-td">시스템명</td>
								<td>
									<select class="form-control" name="system_code">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">등급 <span class="required">*</span></td>
								<td>
									<select class="form-control" name="user_level">
									</select>
								</td>
							</tr>
							<tr class="passTerm">
								<td class="table-td">비밀번호 사용 기간 <span class="required">*</span></td>
								<td>
									<select class="form-control" name="pass_chg_term">
										<option value="90">90일</option>
										<option value="60">60일</option>
										<option value="30">30일</option>
										<option value="10">10일</option>
										<option value="7">7일</option>
										<option value="1">1일</option>
										<option value="0">제한없음</option>
									</select>
								</td>
							</tr>
							<tr class="evalUser">
								<td class="table-td">평가자여부</td>
								<td>
									<label><input type=radio name="eval_yn" value="y"> 예</label>
									<label><input type=radio name="eval_yn" value="n" checked> 아니오</label>
								</td>
							</tr>
							<tr class="downUser">
								<td class="table-td">녹취 다운로드여부</td>
								<td>
									<label><input type=radio name="rec_down_yn" value="y"> 예</label>
									<label><input type=radio name="rec_down_yn" value="n" checked> 아니오</label>
								</td>
							</tr>
							<tr>
								<td class="table-td">아이피</td>
								<td>
									<input type="text" name="user_ip" class="form-control" id="" placeholder="" maxlength="15">
								</td>
							</tr>
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
	
	<!-- 수정 팝업창-->
	<div class="modal inmodal" id="edModalRegiForm" tabindex="-1" role="dialog"  aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content animated fadeIn">
				<form id="partRegi">
					<input type="hidden" name="part_code" value="<%=part_code%>"/>
					<input type="hidden" name="origin_level" value=""/>
					<input type="hidden" name="business_code" value=""/>
					<input type="hidden" name="bpart_code" value=""/>
					<input type="hidden" name="mpart_code" value=""/>
					<input type="hidden" name="pass_upd_date" value=""/>
					
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
						<h4 class="modal-title">상담사 수정</h4>
					</div>
					<div class="modal-body" >
						<!--업무코드 table-->
						<table class="table top-line1 table-bordered2">
							<thead>
							<tr>
								<td style="width:40%;" class="table-td">업무구분</td>
								<td style="width:60%; padding: 6px 9px;">
									<span id="business_name"></span>
								</td>
							</tr>
							</thead>
							<tr>
								<td class="table-td">대분류</td>
								<td>
									<select class="form-control" name="bpart_code">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">중분류</td>
								<td>
									<select class="form-control" name="mpart_code">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">소분류</td>
								<td>
									<select class="form-control" name="spart_code">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">상담원ID <span class="required">*</span></td>
								<td>
									<input type="text" name="user_id" class="form-control" id="" placeholder="" maxlength="20">
								</td>
							</tr>
							<tr>
								<td class="table-td">상담사명 <span class="required">*</span></td>
								<td>
									<input type="text" name="user_name" class="form-control" id="" placeholder="" maxlength="20">
								</td>
							</tr>
							<tr>
								<td class="table-td">내선번호 <span class="required">*</span></td>
								<td>
									<input type="text" name="local_no" class="form-control" id="" placeholder="" maxlength="15">
								</td>
							</tr>
							<tr class="channelExp">
								<td class="table-td">채널번호 <span class="required">*</span></td>
								<td>
									<input type="text" name="channel_no" class="form-control" id="" placeholder="" maxlength="3">
								</td>
							</tr>
							<tr>
								<td class="table-td">시스템명</td>
								<td>
									<select class="form-control" name="system_code">
									</select>
								</td>
							</tr>
							<tr>
								<td class="table-td">등급 <span class="required">*</span></td>
								<td>
									<select class="form-control" name="user_level">
									</select>
								</td>
							</tr>
							<tr class="passTerm">
								<td class="table-td">비밀번호 사용 기간 <span class="required">*</span></td>
								<td>
									<select class="form-control" name="pass_chg_term">
										<option value="90">90일</option>
										<option value="60">60일</option>
										<option value="30">30일</option>
										<option value="10">10일</option>
										<option value="7">7일</option>
										<option value="1">1일</option>
										<option value="0">제한없음</option>
									</select>
								</td>
							</tr>
							<tr class="evalUser">
								<td class="table-td">평가자여부</td>
								<td>
									<label><input type="radio" name="eval_yn" value="y"> 예</label>
									<label><input type="radio" name="eval_yn" value="n"> 아니오</label>
								</td>
							</tr>
							<tr class="downUser">
								<td class="table-td">녹취 다운로드여부</td>
								<td>
									<label><input type=radio name="rec_down_yn" value="y"> 예</label>
									<label><input type=radio name="rec_down_yn" value="n" checked> 아니오</label>
								</td>
							</tr>
							<tr>
								<td class="table-td">아이피</td>
								<td>
									<input type="text" name="user_ip" class="form-control" id="" placeholder="" maxlength="15">
								</td>
							</tr>
						</table>
						<!--업무코드 table 끝-->
					</div>
					<div class="modal-footer">
						<button type="button" name="edModal_regi" class="btn btn-primary btn-sm"><i class="fa fa-pencil"></i> 수정</button>
						<button type="button" name="edModal_cancel" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 취소</button>
					</div>
				</form>
			</div>
		</div>
	</div>	
	<!--팝업창 띠우기 끝-->
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