<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	//if(!Site.isPmss(out,"search_setup","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);
		
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "ss_seq");
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
		argMap.put("user_id", _LOGIN_ID);

		// count
		Map<String, Object> cntmap  = db.selectOne("eval_search_setup.selectCount", argMap);
		
		//oracle 오류 발생하여 수정 - CJM(20190521)
		//tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		//page_cnt = ((Double)cntmap.get("page_cnt")).intValue();
		tot_cnt = Integer.valueOf(cntmap.get("tot_cnt").toString()).intValue();
		page_cnt = Double.valueOf(cntmap.get("page_cnt").toString()).intValue();

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

		List<Map<String, Object>> list = db.selectList("eval_search_setup.selectList", argMap);

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