<%@page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","close")) return;

	Db db = null;

	try 
	{
		db = new Db(true);
		
		// get parameter
		//String info = CommonUtil.getParameter("info");
		
		String info = CommonUtil.getParameter("info");

		//r:고객정보수정 p:고객정보수정/부분녹취 - CJM(20181119)
		String step = CommonUtil.getParameter("step", "p");

		// 파라미터 체크
		if(!CommonUtil.hasText(info)) 
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}

		// 파리미터 복호화
		CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
		info = aes.Decrypt(info);

		String tmp_arr[] = info.split("\\|");
		String rec_datm = DateUtil.getDateFormatByIntVal(tmp_arr[1], "yyyy-MM-dd HH:mm:ss");
		String local_no = tmp_arr[2];
		String rec_filename = tmp_arr[3];
		
		// 복호화 후 파라미터 체크
		if(!CommonUtil.hasText(rec_datm) || !CommonUtil.hasText(local_no) || !CommonUtil.hasText(rec_filename)) 
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
		/*
		System.out.println("rec_datm : "+rec_datm);
		System.out.println("local_no : "+local_no);
		System.out.println("rec_filename : "+rec_filename);
		*/

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("rec_datm", rec_datm);
		argMap.put("local_no", local_no);
		argMap.put("rec_filename", rec_filename);
		
		//고객 정보 조회
		Map<String, Object> data  = db.selectOne("rec_search.selectOmission", argMap);
		
		String cust_id = data.get("cust_id").toString();				//고객번호
		String rec_keycode = data.get("rec_keycode").toString();		//녹취 Call ID
		String custom_fld_02 = data.get("custom_fld_02").toString();	//일련번호
		String custom_fld_03 = data.get("custom_fld_03").toString();	//완료코드
		String custom_fld_04 = data.get("custom_fld_04").toString();	//자동이체동의번호
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>고객  정보 수정/부분 녹취</title>
<link href="../css/bootstrap.css" rel="stylesheet">
<link href="../css/font-awesome.css" rel="stylesheet">
<link href="../css/animate.css" rel="stylesheet">
<link href="../css/style.css" rel="stylesheet">

<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
<script type="text/javascript" src="../js/bootstrap.js"></script>
<script type="text/javascript" src="../js/common.js"></script>
<script type="text/javascript" src="../js/commItemz.js"></script>
<script type="text/javascript">

	$(function()
	{
		var msg = "정상적으로 수정/부분녹취 되었습니다.";
		
		if($("input[name=step]").val() == "r")
		{
			document.title = "고객  정보 수정";
			$(".modal-title").text("고객  정보 수정");
			$("button[name=modal_regi]").text("고객  정보 수정");
			msg = "정상적으로 수정 되었습니다."
		}
		
		$("#modalReasonForm").modal("toggle");
		
		// 등록 버튼 클릭
		$("button[name=modal_regi]").click(function()
		{
			if(reasonFormChk()) 
			{
				//$("#omi_regi").attr("action", "remote_part_proc.jsp");
				//$("#omi_regi").attr("target", "hiddenFrame");
				//$("#omi_regi").submit();

				$.ajax({
			       	type: "POST",
			       	url: "remote_part_proc.jsp",
					async: false,
			       	//data: "step=insert&"+$("#omi_regi").serialize(),
			       	data: $("#omi_regi").serialize(),
			       	dataType: "json",
			       	success:function(dataJSON){
						if(dataJSON.code == "OK") 
						{
							alert(msg);
							self.close();
						} 
						else 
						{
							alert(dataJSON.msg);
							return false;
						}
					},
					error:function(req,status,err){
				    	alert("에러가 발생하였습니다. [" + req.responseText + "]");
						return false;
					}
			   	});
			}
		});
	});

	// form check
	function reasonFormChk() 
	{
		var cnt = getByteLen($("#modalReasonForm input[name=cust_id]").val());
		if(cnt > 20)
		{
			alert("고객번호 입력길이가 초과 하였습니다!\n최대 입력 가능 길이는 20Byte 입니다\n( 현재 입력 한 길이 : "+cnt+"Byte )");
			$("#modalReasonForm input[name=cust_id]").focus();
			return false;
		}
		cnt = getByteLen($("#modalReasonForm input[name=rec_keycode]").val());
		if(cnt > 50)
		{
			alert("녹취 Call ID 입력길이가 초과 하였습니다!\n최대 입력 가능 길이는 50Byte 입니다\n( 현재 입력 한 길이 : "+cnt+"Byte )");
			$("#modalReasonForm input[name=rec_keycode]").focus();
			return false;
		}
		cnt = getByteLen($("#modalReasonForm input[name=custom_fld_02]").val());
		if(cnt > 255)
		{
			alert("일련번호 입력길이가 초과 하였습니다!\n최대 입력 가능 길이는 255Byte 입니다\n( 현재 입력 한 길이 : "+cnt+"Byte )");
			$("#modalReasonForm input[name=custom_fld_02]").focus();
			return false;
		}
		cnt = getByteLen($("#modalReasonForm input[name=custom_fld_03]").val());
		if(cnt > 255)
		{
			alert("완료코드 입력길이가 초과 하였습니다!\n최대 입력 가능 길이는 255Byte 입니다\n( 현재 입력 한 길이 : "+cnt+"Byte )");
			$("#modalReasonForm input[name=custom_fld_03]").focus();
			return false;
		}
		cnt = getByteLen($("#modalReasonForm input[name=custom_fld_04]").val());
		if(cnt > 255)
		{
			alert("자동이체동의번호 입력길이가 초과 하였습니다!\n최대 입력 가능 길이는 255Byte 입니다\n( 현재 입력 한 길이 : "+cnt+"Byte )");
			$("#modalReasonForm input[name=custom_fld_04]").focus();
			return false;
		}

		return true;
	}
</script>

</head>

<body class="white-bg">
<div id="container" style="width: 556px">
	<div class="memo-body">
		<form id="omi_regi" method="post">
			<input type="hidden" name="info" value="<%=info %>"/>
			<input type="hidden" name="step" value="<%=step%>"/>
			
			<div class="modal inmodal" id="modalReasonForm" tabindex="-1" role="dialog" data-backdrop="static">
				<div class="modal-dialog">
					<div class="modal-content animated fadeIn">
						<div class="modal-header">
							<h4 class="modal-title">고객  정보 수정/부분 녹취</h4>
						</div>
						<div class="modal-body" >
							<!--업무코드 table-->	
							<table class="table top-line1 table-bordered2">
								<thead></thead>
								<tbody>
								<tr>
									<td class="table-td">고객번호</td>
									<td>
										<input type="text" name="cust_id" class="form-control" id="" placeholder="" value="<%=cust_id%>">
									</td>
								</tr>
								<tr>
									<td class="table-td">녹취 Call ID</td>
									<td>
										<input type="text" name="rec_keycode" class="form-control" id="" placeholder="" value="<%=rec_keycode%>">
									</td>
								</tr>
								<tr>
									<td class="table-td">일련번호</td>
									<td>
										<input type="text" name="custom_fld_02" class="form-control" id="" placeholder="" value="<%=custom_fld_02%>">
									</td>
								</tr>
								<tr>
									<td class="table-td">완료코드</td>
									<td>
										<input type="text" name="custom_fld_03" class="form-control" id="" placeholder="" value="<%=custom_fld_03%>">
									</td>
								</tr>
								<tr>
									<td class="table-td">자동이체동의번호</td>
									<td>
										<input type="text" name="custom_fld_04" class="form-control" id="" placeholder="" value="<%=custom_fld_04%>">
									</td>
								</tr>
								</tbody>
							</table>
							<!--업무코드 table 끝-->	
						</div>
						<div class="modal-footer">
							<button type="button" name="modal_regi" class="btn btn-primary btn-sm"><i class="fa fa-pencil"></i> 수정/부분녹취</button>
							<button type="button" name="modal_cancel" class="btn btn-default btn-sm" onclick="self.close();"><i class="fa fa-times"></i> 취소</button>
						</div>				
					</div>
				</div>
			</div>
		</form>
	</div>
</div>

</body>
</html>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db!=null) db.close();
	}
%>