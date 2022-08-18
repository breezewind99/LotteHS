<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_change_hist","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		// get parameter
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "change_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		String change_date1 = CommonUtil.getParameter("change_date1");
		String change_date2 = CommonUtil.getParameter("change_date2");
		String login_id = CommonUtil.getParameter("login_id");
		String login_name = CommonUtil.getParameter("login_name");
		String user_id = CommonUtil.getParameter("user_id");
		String user_name = CommonUtil.getParameter("user_name");
		String change_type = CommonUtil.getParameter("change_type");

		cur_page = (cur_page<1) ? 1 : cur_page;
		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		// paging 변수
		int tot_cnt = 0;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;

		JSONObject json = new JSONObject();

		// search
		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("top_cnt", top_cnt);
		argMap.put("change_date1", change_date1);
		argMap.put("change_date2", change_date2);
		argMap.put("change_id", login_id);
		argMap.put("change_name", login_name);
		argMap.put("user_id", user_id);
		argMap.put("user_name", user_name);
		argMap.put("change_type", change_type);

		// hist count
		Map<String, Object> cntmap  = db.selectOne("hist_user_change.selectCount", argMap);

		//oracle 오류 발생하여 수정 - CJM(20190521)
		tot_cnt = Integer.valueOf(cntmap.get("tot_cnt").toString()).intValue();
		//tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		page_cnt = Double.valueOf(cntmap.get("page_cnt").toString()).intValue();
		//page_cnt = ((Double)cntmap.get("page_cnt")).intValue();
		
		/**
			페이지 맨 끝 이동 후 페이지 노출 갯수 변경시 데이터 미노출 현상 체크 - CJM(20180706)
			count가 0 일 경우 예외 처리  - CJM(20190701)
		*/
		int skip = (top_cnt*(cur_page-1));
		if((tot_cnt != 0) && (skip >= tot_cnt))
		{
			page_cnt = (int)Math.ceil(((double)tot_cnt) / top_cnt);
			cur_page = page_cnt;
		}

		// paging 변수
		end_cnt = (cur_page*1)*top_cnt;
		start_cnt = end_cnt-(top_cnt-1);

		// search
		argMap.put("tot_cnt", tot_cnt);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("start_cnt", start_cnt);
		argMap.put("end_cnt", end_cnt);

		List<Map<String, Object>> list = db.selectList("hist_user_change.selectList", argMap);
		
		json.put("totalRecords", tot_cnt);
		json.put("totalPages", page_cnt);
		json.put("curPage", cur_page);
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