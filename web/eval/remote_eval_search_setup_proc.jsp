<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"eval_search_setup","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) 
		{
			// get parameter
			String event_code_combo = CommonUtil.getParameter("event_code_combo");
			String rec_date1 = CommonUtil.getParameter("rec_date1");
			String rec_date2 = CommonUtil.getParameter("rec_date2");
			String rec_start_hour1 = CommonUtil.getParameter("rec_start_hour1");
			String rec_start_hour2 = CommonUtil.getParameter("rec_start_hour2");
			String rec_start_min1 = CommonUtil.getParameter("rec_start_min1");
			String rec_start_min2 = CommonUtil.getParameter("rec_start_min2");
			String rec_call_time1 = CommonUtil.getParameter("rec_call_time1");
			String rec_call_time2 = CommonUtil.getParameter("rec_call_time2");
			
			// 파라미터 체크
			if(!CommonUtil.hasText(event_code_combo) 
					|| !CommonUtil.hasText(rec_date1) 
					|| !CommonUtil.hasText(rec_date2) 
					|| !CommonUtil.hasText(rec_start_hour1)
					|| !CommonUtil.hasText(rec_start_hour2)
					|| !CommonUtil.hasText(rec_start_min1)
					|| !CommonUtil.hasText(rec_start_min2)
					|| !CommonUtil.hasText(rec_call_time1)
					|| !CommonUtil.hasText(rec_call_time2)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			String event_code = event_code_combo.substring(0, event_code_combo.indexOf("/"));

			argMap.put("user_id", _LOGIN_ID);
			argMap.put("event_code",event_code);
			argMap.put("ss_fdate",rec_date1);
			argMap.put("ss_tdate",rec_date2);
			argMap.put("ss_fhour",rec_start_hour1);
			argMap.put("ss_thour",rec_start_hour2);
			argMap.put("ss_fminute",rec_start_min1);
			argMap.put("ss_tminute",rec_start_min2);
			argMap.put("ss_ftime",rec_call_time1);
			argMap.put("ss_ttime",rec_call_time2);
			
			
			int ins_cnt = db.insert("eval_search_setup.insertSetup", argMap);
			if(ins_cnt<1) {
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}
			
		} else if("delete".equals(step)) {
			// get parameter
			String ss_seq = CommonUtil.getParameter("ss_seq");

			// 파라미터 체크
			if(!CommonUtil.hasText(ss_seq)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			// 시트 삭제
			int del_cnt = db.delete("eval_search_setup.deleteSearchSetup", ss_seq);
			if(del_cnt<1) {
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
		} else if("update".equals(step)) {
			// get parameter
			String ss_seq = CommonUtil.getParameter("ss_seq");
			String rec_date1 = CommonUtil.getParameter("rec_date1");
			String rec_date2 = CommonUtil.getParameter("rec_date2");
			String rec_start_hour1 = CommonUtil.getParameter("rec_start_hour1");
			String rec_start_hour2 = CommonUtil.getParameter("rec_start_hour2");
			String rec_start_min1 = CommonUtil.getParameter("rec_start_min1");
			String rec_start_min2 = CommonUtil.getParameter("rec_start_min2");
			String rec_call_time1 = CommonUtil.getParameter("rec_call_time1");
			String rec_call_time2 = CommonUtil.getParameter("rec_call_time2");
			
			// 파라미터 체크
			if(!CommonUtil.hasText(ss_seq) 
					|| !CommonUtil.hasText(rec_date1) 
					|| !CommonUtil.hasText(rec_date2) 
					|| !CommonUtil.hasText(rec_start_hour1)
					|| !CommonUtil.hasText(rec_start_hour2)
					|| !CommonUtil.hasText(rec_start_min1)
					|| !CommonUtil.hasText(rec_start_min2)
					|| !CommonUtil.hasText(rec_call_time1)
					|| !CommonUtil.hasText(rec_call_time2)) {
				throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
			}

			argMap.put("user_id", _LOGIN_ID);
			argMap.put("ss_seq",ss_seq);
			argMap.put("ss_fdate",rec_date1);
			argMap.put("ss_tdate",rec_date2);
			argMap.put("ss_fhour",rec_start_hour1);
			argMap.put("ss_thour",rec_start_hour2);
			argMap.put("ss_fminute",rec_start_min1);
			argMap.put("ss_tminute",rec_start_min2);
			argMap.put("ss_ftime",rec_call_time1);
			argMap.put("ss_ttime",rec_call_time2);
			
			
			int ins_cnt = db.update("eval_search_setup.updateSetup", argMap);
			if(ins_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} else {
			throw new Exception(CommonUtil.getErrorMsg("NO_PARAM"));
		}

		Site.writeJsonResult(out,true);
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>