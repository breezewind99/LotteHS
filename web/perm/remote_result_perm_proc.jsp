<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"menu_perm","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		// get parameter
		String step = CommonUtil.getParameter("step");

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("update".equals(step)) 
		{
			// get parameter
			String data_list = CommonUtil.getParameter("data_list");

			// 파라미터 체크
			if(!CommonUtil.hasText(data_list)) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// &quot; -> " 로 replace
			data_list = "{\"data_list\":" + CommonUtil.toTextJSON(data_list) + "}";

			JSONParser jsonParser = new JSONParser();
			JSONObject jsonObj = (JSONObject) jsonParser.parse(data_list);

			JSONArray jsonArr = (JSONArray) jsonObj.get("data_list");
			Iterator<Object> iterator = jsonArr.iterator();

			int upd_cnt = 0;
			while (iterator.hasNext()) 
			{
				JSONObject jsonItem = (JSONObject) iterator.next();

				argMap.clear();
				argMap.put("conf_type","R");
				argMap.put("business_code",jsonItem.get("business_code"));
				argMap.put("conf_code",jsonItem.get("conf_code"));
				argMap.put("conf_name",jsonItem.get("conf_name"));
				argMap.put("user_level",jsonItem.get("user_level"));
				//argMap.put("order_no",jsonItem.get("order_no"));
				argMap.put("use_yn",jsonItem.get("use_yn"));

				upd_cnt += db.update("search_config.updateSearchConfig", argMap);

				argMap.clear();
				argMap.put("change_id", _LOGIN_ID);
				argMap.put("change_name", _LOGIN_NAME);
				argMap.put("change_ip", request.getRemoteAddr());

				argMap.put("menu_name", "리스트 " + jsonItem.get("conf_name"));
				argMap.put("user_level", jsonItem.get("user_level"));
				argMap.put("use_yn", jsonItem.get("use_yn"));

				argMap.put("origin_level", jsonItem.get("origin_level"));
				argMap.put("origin_yn", jsonItem.get("origin_yn"));

				db.update("hist_permission.insertUserChangeHist", argMap);
			}

			if(upd_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} 
		else 
		{
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		Site.writeJsonResult(out,true);
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db != null)	db.close();
	}
%>