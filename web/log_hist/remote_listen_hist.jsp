<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%
	if(!Site.isPmss(out,"listen_hist","jsonerr")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		// get parameter
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "listen_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		String listen_date1 = CommonUtil.getParameter("listen_date1");
		String listen_date2 = CommonUtil.getParameter("listen_date2");
		String login_id = CommonUtil.getParameter("login_id");
		String login_name = CommonUtil.getParameter("login_name");
		String rec_date1 = CommonUtil.getParameter("rec_date1","");
		String rec_date2 = CommonUtil.getParameter("rec_date2","");
		String user_id = CommonUtil.getParameter("user_id");
		String user_name = CommonUtil.getParameter("user_name");
		String reason_code = CommonUtil.getParameter("reason_code");

		cur_page = (cur_page<1) ? 1 : cur_page;
		sort_idx = OrderBy(sort_idx,"listen_datm,listen_id,listen_name,listen_ip,rec_datm,user_id,user_name,rec_filename");
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
		argMap.put("listen_date1",listen_date1);
		argMap.put("listen_date2",listen_date2);
		argMap.put("listen_id",login_id);
		argMap.put("listen_name",login_name);
		argMap.put("rec_date1",rec_date1);
		argMap.put("rec_date2",rec_date2);
		argMap.put("user_id",user_id);
		argMap.put("user_name",user_name);
		argMap.put("reason_code",reason_code);

		// hist count
		Map<String, Object> cntmap  = db.selectOne("hist_listen.selectCount", argMap);

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

		List<Map<String, Object>> list = db.selectList("hist_listen.selectList", argMap);

		int row_indx = 0;
		for(Map<String, Object> item : list) 
		{
			// 듣기
			if(item.containsKey("v_url")) 
			{
				item.put("v_url", "<img src='../img/icon/ico_player.png' onclick=\"playRecFileByIdx('" + row_indx + "');\" style='margin-left: 5px; cursor: pointer;'/>");
			}
			if (item.containsKey("listen_name") && item.get("listen_name") != null) {
				String temp = Mask.getMaskedName(item.get("listen_name"));
				item.put("listen_name", temp);
			}
			if (item.containsKey("user_name") && item.get("user_name") != null) {
				String temp = Mask.getMaskedName(item.get("user_name"));
				item.put("user_name", temp);
			}

			row_indx++;
		}

		json.put("totalRecords", tot_cnt);
		json.put("totalPages", page_cnt);
		json.put("curPage", cur_page);
		json.put("data", list);
		
		out.print(json.toJSONString());
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db != null)	db.close();
	}
%>