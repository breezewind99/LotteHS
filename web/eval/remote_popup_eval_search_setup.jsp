<%
/*
	2017. 11. 13
	connick
	검색 조건 관리
*/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	//if(!Site.isPmss(out,"search_setup","json")) return;

	Db db = null;

	try {
		db = new Db(true);
		
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "ss_seq");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");
		
		String event_code = CommonUtil.getParameter("event_code", "");

		//System.out.println("event_code: "+CommonUtil.getParameter("event_code"));
		
		cur_page = (cur_page<1) ? 1 : cur_page;
		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		// paging 변수
		int tot_cnt = 0;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("top_cnt", top_cnt);
		argMap.put("user_id", _LOGIN_ID);
		argMap.put("event_code", event_code);

		// count
		Map<String, Object> cntmap  = db.selectOne("eval_search_setup.popSelectCount", argMap);
		//tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		//page_cnt = ((Double)cntmap.get("page_cnt")).intValue();
		tot_cnt = Integer.valueOf(cntmap.get("tot_cnt").toString()).intValue();
		page_cnt = Double.valueOf(cntmap.get("page_cnt").toString()).intValue();

		json.put("totalRecords", tot_cnt);
		json.put("totalPages", page_cnt);
		json.put("curPage", cur_page);

		// paging 변수
		end_cnt = (cur_page*1)*top_cnt;
		start_cnt = end_cnt-(top_cnt-1);

		// search
		argMap.put("tot_cnt", tot_cnt);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("start_cnt", start_cnt);
		argMap.put("end_cnt", end_cnt);

		List<Map<String, Object>> list = db.selectList("eval_search_setup.popSelectList", argMap);

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