<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/common.jsp" %>
<%!	static Logger logger = Logger.getLogger("download_ext.jsp"); %>
<%
	if(!Site.isPmss(out,"rec_search","close")) return;

	try 
	{
		// get parameter
		String info = CommonUtil.getParameter("info");

		// 파라미터 체크
		if(!CommonUtil.hasText(info)) 
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>다운로드 확장자 체크</title>
<link href="../css/bootstrap.css" rel="stylesheet">
<link href="../css/font-awesome.css" rel="stylesheet">
<link href="../css/animate.css" rel="stylesheet">
<link href="../css/style.css" rel="stylesheet">
<script type="text/javascript" src="../js/jquery-1.11.0.min.js"></script>
<script type="text/javascript" src="../js/jquery-ui-1.10.4.custom.min.js"></script>
<script type="text/javascript" src="../js/bootstrap.js"></script>
<script type="text/javascript" src="../js/common.js"></script>
<script type="text/javascript">
	$(function()
	{
		// 다운로드 버튼 클릭
		$("button[name=modal_regi]").click(function()
		{
			$("#reason_regi").attr("action", "download.jsp");
			$("#reason_regi").attr("target", "hiddenFrame");
			$("#reason_regi").submit();
		});
		
		// 닫기 클릭
		$("button[name=modal_close]").click(function()
		{
			self.close();
			//close();
		});
	});
</script>
</head>

<body class="white-bg">
	<div id="container">
		<form id="reason_regi" method="post">
			<input type="hidden" name="info" value="<%=info %>"/>
			
			<div class="modal-header">
				<h5 class="modal-title">다운로드 확장자 체크</h5>
			</div>
			<div class="modal-body" >
				<table class="table table-bordered2">
					<tr>
						<td style="width:40%;" class="table-td">다운로드 확장자</td>
						<td style="width:60%;">
							<select class="form-control rec_form1" name="extension">
								<option value="WAV">WAV</option>
								<option value="PCM">PCM</option>
							</select>
						</td>
					</tr>
				</table>
			</div>
			<div class="modal-footer">
				<button type="button" name="modal_regi" class="btn btn-primary btn-sm"><i class="fa fa-pencil"></i> 다운로드</button>
				<button type="button" name="modal_close" class="btn btn-default btn-sm" data-dismiss="modal"><i class="fa fa-times"></i> 닫기</button>
			</div>
		</form>
	</div>
	
	<iframe name="hiddenFrame" id="hiddenFrame" style="display: none;"></iframe>
</body>
</html>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally{}
%>