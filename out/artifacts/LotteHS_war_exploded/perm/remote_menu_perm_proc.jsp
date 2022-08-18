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
			String parentCode = null;
			while(iterator.hasNext()) 
			{
				JSONObject jsonItem = (JSONObject) iterator.next();

				argMap.clear();
				argMap.put("business_code",jsonItem.get("business_code"));
				argMap.put("menu_code",jsonItem.get("menu_code"));
				argMap.put("menu_name",jsonItem.get("menu_name"));
				argMap.put("user_level",jsonItem.get("user_level"));
				//argMap.put("order_no",jsonItem.get("order_no"));

				//상위메뉴에 속한 하위 메뉴가 수정 될 경우 비활성화 처리 - CJM(20190715)
				if(parentCode != null && jsonItem.get("parent_code").equals(parentCode))	argMap.put("use_yn", "0");
				else																		argMap.put("use_yn", jsonItem.get("use_yn"));

				upd_cnt += db.update("menu.updateMenu", argMap);
				
				//상위 메뉴 사용 여부 비활성화 할 경우 하위 메뉴 비활성 처리 - CJM(20190715)
				if("1".equals(jsonItem.get("menu_depth").toString()) && "0".equals(jsonItem.get("use_yn")))
				{
					db.update("menu.updateParentMenu", argMap);
					parentCode = jsonItem.get("menu_code").toString();
				}
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