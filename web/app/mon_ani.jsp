<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	Db db = null;

	try 
	{
		db = new Db(true);
		String local_phone = CommonUtil.getParameter("local");
		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("phone", local_phone);
		// config select
		Map<String, Object> cntmap = db.selectOne("mon_db.selectAni", argMap);

		//oracle 오류 발생하여 수정 - CJM(20190521)
		String ani = "";
		try {
			ani = cntmap.get("ani").toString();
		} catch (Exception e) {}
		//ani = "01098580428";
%>
<%=ani%>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	}
	finally 
	{
		if(db != null)	db.close();
	}
%>