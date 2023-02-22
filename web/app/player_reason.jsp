<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	try
	{
		// get parameter
		String rec_datm = CommonUtil.getParameter("rec_datm");
		String rec_keycode = CommonUtil.getParameter("rec_keycode");
		String seq_no = CommonUtil.getParameter("seq");
		String user_id = CommonUtil.getParameter("user_id");
		String user_name = CommonUtil.getParameter("user_name");
		String rec_seq = CommonUtil.getParameter("rec_seq");
		//out.print(info);
		// 파라미터 체크
		if(!CommonUtil.hasText(user_id))
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
%>
<jsp:include page="/include/popup.jsp" flush="false"/>
<title>청취 사유 등록</title>
<script type="text/javascript">
	console.log("test");
	$(function()
	{
		// 등록 버튼 클릭
		$("button[name=modal_regi]").click(function(){
			if(reasonFormChk()) {
				$('#reason_regi input[name="reason_code"]').val($("#modalReasonForm select[name=reason_code]").val());
				$('#reason_regi input[name="reason_text"]').val($("#modalReasonForm input[name=reason_text]").val());
				$("#reason_regi").attr("action", "player.jsp");
				$("#reason_regi").submit();
			}
		});
	});
</script>
</head>

<body class="white-bg">
<div id="container" style="width: 556px">
	<div class="memo-body">
		<form id="reason_regi" method="post">
			<input type="hidden" name="rec_datm" value="<%=rec_datm %>"/>
			<input type="hidden" name="rec_keycode" value="<%=rec_keycode %>"/>
			<input type="hidden" name="rec_keycode" value="<%=seq_no %>"/>
			<input type="hidden" name="user_id" value="<%=user_id %>"/>
			<input type="hidden" name="user_name" value="<%=user_name %>"/>
			<input type="hidden" name="rec_seq" value="<%=rec_seq %>"/>
			<input type="hidden" name="reason_code" value="">
			<input type="hidden" name="reason_text" value="">
		</form>
		<jsp:include page="/include/reason_inc.jsp" flush="false"/>
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
	{}

%>