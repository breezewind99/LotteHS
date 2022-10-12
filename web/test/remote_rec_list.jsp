<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../common/common.jsp" %>
<%@ include file="../common/function.jsp" %>
<%!	static Logger logger = Logger.getLogger("remote_rec_list.jsp"); %>
<%
	// DB Connection Object
	Db db = null;

	try {
		db = new Db(true);

		// get parameter
		String from_date = CommonUtil.getParameter("rec_date1", "");
		String to_date = CommonUtil.getParameter("rec_date2", "");
		String cust_tel = CommonUtil.getParameter("cust_tel", "");

		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String tmp_sort_idx = CommonUtil.getParameter("sort_idx", "rec_date");
		String sort_idx = OrderBy(tmp_sort_idx,"rec_date, rec_start_time, rec_end_time, rec_call_time, local_no, user_id, user_name, cust_tel");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");
		
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
		argMap.put("from_date", from_date);
		argMap.put("to_date", to_date);
		argMap.put("cust_tel", cust_tel);

		// count
		Map<String, Object> cntmap  = db.selectOne("rec_list.selectRecCount", argMap);
		tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		page_cnt = ((Double)cntmap.get("page_cnt")).intValue();

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

		List<Map<String, Object>> list = db.selectList("rec_list.selectRecList", argMap);

		json.put("data", list);
		out.print(json.toJSONString());
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
    	if(db!=null) db.close();
	}
%>