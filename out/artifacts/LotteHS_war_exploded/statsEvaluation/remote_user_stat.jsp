<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_stat","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		// get parameter
		String sort_idx = CommonUtil.getParameter("sort_idx", "user_id");
		String sort_dir = CommonUtil.getParameter("sort_dir", "up");
		String eval_date1 = CommonUtil.getParameter("eval_date1");
		String eval_date2 = CommonUtil.getParameter("eval_date2");
		String event_code = CommonUtil.getParameter("event_code");
		String sheet_code = CommonUtil.getParameter("sheet_code");
		String bpart_code = CommonUtil.getParameter("bpart_code");
		String mpart_code = CommonUtil.getParameter("mpart_code");
		String spart_code = CommonUtil.getParameter("spart_code");
		String user_name = CommonUtil.getParameter("user_name");
		String eval_user_name = CommonUtil.getParameter("eval_user_name");
		int eval_order_max = ComLib.getPI(request, "eval_order_max");
		
		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		JSONObject json = new JSONObject();

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();

		//argMap.put("eval_date1",eval_date1.replace("-", ""));
		//argMap.put("eval_date2",eval_date2.replace("-", ""));
		argMap.put("eval_date1",eval_date1);
		argMap.put("eval_date2",eval_date2);
		argMap.put("event_code",event_code);
		argMap.put("sheet_code",sheet_code);
		argMap.put("bpart_code",bpart_code);
		argMap.put("mpart_code",mpart_code);
		argMap.put("spart_code",spart_code);
		argMap.put("user_name",user_name);
		argMap.put("eval_user_name",eval_user_name);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("eval_order_max", eval_order_max);

		List<Map<String, Object>> list = db.selectList("stat_user.selectListAllOrder", argMap);

		json.put("totalRecords", list.size());
		json.put("data", list);
		out.print(json.toJSONString());
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