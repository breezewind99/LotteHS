<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"event","json")) return;

	Db db = null;

	try 
	{
		db = new Db();

		String step = CommonUtil.getParameter("step");

		String client_ip = request.getRemoteAddr();

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("delete".equals(step)) 
		{
			// get parameter
			String rec_filename = CommonUtil.getParameter("rec_filename");

			// 파라미터 체크
			if(!CommonUtil.hasText(rec_filename)) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 평가결과 조회
			argMap.put("rec_filename",rec_filename);

			Map<String, Object> resmap = db.selectOne("eval_result.selectItem", argMap);
			if(resmap == null) 
			{
				Site.writeJsonResult(out, false, "평가결과 조회에 실패했습니다.");
				return;
			}

			String event_code = resmap.get("event_code").toString();
			String assign_user_id = resmap.get("assign_user_id").toString();
			String user_id = resmap.get("user_id").toString();

			// 평가대상자 조회
			argMap.clear();
			argMap.put("event_code",event_code);
			argMap.put("eval_user_id",assign_user_id);
			argMap.put("user_id",user_id);

			Map<String, Object> usermap = db.selectOne("eval_target.selectItem", argMap);
			if(usermap == null) 
			{
				Site.writeJsonResult(out, false, "평가대상자 조회에 실패했습니다.");
				return;
			}

			// 평가결과 삭제
			argMap.clear();
			
			argMap.put("_eval_user_id", _LOGIN_ID);
			argMap.put("_user_level", _LOGIN_LEVEL);
			argMap.put("rec_filename",resmap.get("rec_filename"));

			int del_cnt = db.delete("eval_result.deleteEvalEventResultList", argMap);
			if(del_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}

			// 평가결과 상세 삭제
			del_cnt = db.delete("eval_result.deleteEvalEventResultItem", argMap);
			if(del_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
			
			// 2017.11.13 connick
			// 평가 상세코멘트 삭제
			del_cnt = db.delete("eval_result.deleteEvalEventResultComment", argMap);
			if(del_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
			// 2017.11.13 connick

			/*
			//이벤트별 배정기능을 없앴으므로 사용 안함 : 2017-09-06
			// 평가대상자 정보 업데이트
			String eval_status = (Integer.parseInt(usermap.get("eval_cnt").toString())<=1) ? "0" : "";
			argMap.clear();
			argMap.put("event_code",event_code);
			argMap.put("eval_user_id",assign_user_id);
			argMap.put("user_id",user_id);
			argMap.put("eval_status",eval_status);
			argMap.put("eval_cnt_minus","1");// 평가건수 -1

			int upd_cnt = db.update("eval_target.updateEventAgentList", argMap);
			if(upd_cnt<1) {
				Site.writeJsonResult(out, false, "평가대상자 업데이트에 실패했습니다.");
				return;
			}
			*/

			Site.writeJsonResult(out,true);
		}
		else if("chg2to9".equals(step)) 
		{
			// 검색조건 전체 받아옴 - CJM(20180910)
			String eval_date1 = CommonUtil.getParameter("eval_date1");
			String eval_date2 = CommonUtil.getParameter("eval_date2");
			String eval_user_id = CommonUtil.getParameter("eval_user_id");
			String bpart_code = CommonUtil.getParameter("bpart_code");
			String mpart_code = CommonUtil.getParameter("mpart_code");
			String spart_code = CommonUtil.getParameter("spart_code");
			String user_name = CommonUtil.getParameter("user_name");
			String event_code = CommonUtil.getParameter("event_code");
			String eval_order = CommonUtil.getParameter("eval_order");
			String chg_status = CommonUtil.getParameter("chg_status");
			
			//등록상태 일괄 완료처리
			argMap.put("eval_date1", eval_date1);
			argMap.put("eval_date2", eval_date2);
			argMap.put("eval_user_id", eval_user_id);
			argMap.put("bpart_code", bpart_code);
			argMap.put("mpart_code", mpart_code);
			argMap.put("spart_code", spart_code);
			argMap.put("user_name", user_name);
			argMap.put("event_code", event_code);
			argMap.put("eval_order", eval_order);
			argMap.put("chg_status", chg_status);
			
			int cnt = db.update("eval_result.updateStatus2To9", argMap);

			if(cnt < 1) 
			{
				throw new Exception("평가 상태 수정에 실패했습니다.");
			}
			
			out.print("{\"code\":\"OK\", \"msg\":\"\", \"cnt\":"+cnt+"}");
			
		}
		else 
		{
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// commit
		db.commit();
	} 
	catch(Exception e) 
	{
		// rollback
		if(db != null)	db.rollback();

		logger.error(e.getMessage());
	} 
	finally 
	{
		if(db != null)	db.close();
	}
%>