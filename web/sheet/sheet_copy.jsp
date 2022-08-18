<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%!	static Logger logger = Logger.getLogger("sheet_copy.jsp"); %>
<%
	if(!Site.isPmss(out,"sheet","json")) return;

	Db db = null;
	JSONObject json = new JSONObject();

	try {
		db = new Db(true);

		// get parameter
		String sheet_code = CommonUtil.getParameter("sheet_code", "");
		Map<String, String> selmap = new HashMap<String, String>();
		selmap.put("sheet_code", sheet_code);

		int cnt  = db.insert("sheet.copySheet_sheet", selmap);
		cnt = db.insert("sheet.copySheet_item", selmap);
		db.commit();

		json.put("code", "OK");
		json.put("msg", "");
		out.print(json.toJSONString());
	} catch(Exception e) {
		db.rollback();
		logger.error(e.getMessage());
		json.put("code", "ERR");
		json.put("msg", e.getMessage());
	} finally {
		db.close();
	}
%>