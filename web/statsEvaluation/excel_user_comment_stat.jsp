<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_stat","")) return;

	Db db = null;

	try 
	{
		Site.setExcelHeader(response, out, "상담원별통계-상담원별의견");

		db = new Db(true);

		// get parameter
		String sort_idx = "user_id";//CommonUtil.getParameter("sort_idx", "user_id");
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
		int eval_order_max = ComLib.getPI(request,"eval_order_max");

		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		StringBuffer sb = new StringBuffer();

		sb.append("<table border='1' bordercolor='#bbbbbb'>");
		sb.append("<tr align='center'>");
		sb.append("<td class=th>대분류</td>");
		sb.append("<td class=th>중분류</td>");
		sb.append("<td class=th>소분류</td>");

		sb.append("<td class=th>상담원 ID</td>");
		sb.append("<td class=th>상담원 명</td>");
		
		sb.append("<td class=th>평가차수</td>");
		
		sb.append("<td class=th>중분류</td>");
		sb.append("<td class=th>소분류</td>");

		sb.append("<td class=th>배점</td>");
		sb.append("<td class=th>득점</td>");
		sb.append("<td class=th>코멘트</td>");
		sb.append("</tr>");

		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("eval_date1",eval_date1.replace("-", ""));
		argMap.put("eval_date2",eval_date2.replace("-", ""));
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

		List<HashMap<String, Object>> list = db.selectList("stat_user.selectListComment", argMap);
		
		List<HashMap<String, Object>> resultList = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		String newUserId="", oldUserId="", newOrder="", oldOrder="", newCateName="", oldCateName="";
		
		for(HashMap<String, Object> item : list)
		{
			newUserId = item.get("user_id").toString();
			newOrder = item.get("eval_order").toString();
			newCateName = item.get("cate_name").toString();
					
			resultMap = (HashMap<String, Object>) item.clone();
			
			if(newUserId.equals(oldUserId))
			{
				resultMap.put("part_name", " ");
				resultMap.put("user_id", "");
				resultMap.put("user_name", "");
				if(newOrder.equals(oldOrder))
				{
					resultMap.put("eval_order", "");
					if(newCateName.equals(oldCateName))
					{
						resultMap.put("cate_name", "");
					}
				}
			}
			
			oldUserId = newUserId;
			oldOrder = newOrder;
			oldCateName = newCateName;
			
			resultList.add(resultMap);
		}
		
		int sum_tot_score = 0;
		int sum_eval_score = 0;

		for(Map<String, Object> item : resultList) 
		{
			// 총계 저장
			sum_tot_score		+= ComLib.toINN(item.get("tot_score"));
			sum_eval_score		+= ComLib.toINN(item.get("eval_score"));

			sb.append("<tr align=right>");
			if(item.get("user_id").equals(""))
			{
				if(item.get("eval_order").equals(""))
				{
					sb.append("<td></td><td></td><td></td><td></td><td></td><td></td>");
					if(item.get("cate_name").equals(""))
					{
						sb.append("<td></td>");
					}
					else
					{
						sb.append("<td>" + item.get("cate_name") + "</td>");
					}
				}
				else
				{
					sb.append("<td></td><td></td><td></td><td></td><td></td>");
					sb.append("<td>" + item.get("eval_order") + "</td>");
					if(item.get("cate_name").equals(""))
					{
						sb.append("<td></td>");
					}
					else
					{
						sb.append("<td>" + item.get("cate_name") + "</td>");
					}
				}
			}
			else
			{
				sb.append("<td>" + ComLib.toNN(item.get("bpart_name"),"-") + "</td>");
				sb.append("<td>" + ComLib.toNN(item.get("mpart_name"),"-") + "</td>");
				sb.append("<td>" + ComLib.toNN(item.get("spart_name"),"-") + "</td>");
				sb.append("<td>" + item.get("user_id") + "</td>");
				sb.append("<td>" + item.get("user_name") + "</td>");
				sb.append("<td>" + item.get("eval_order") + "</td>");
				sb.append("<td>" + item.get("cate_name") + "</td>");
			}

			sb.append("<td>" + item.get("item_name") + "</td>");
			sb.append("<td align=right>" + item.get("tot_score") + "</td>");
			sb.append("<td align=right>" + item.get("eval_score") + "</td>");
			sb.append("<td>" + ComLib.toNN(item.get("item_comment")) + "</td>");
			sb.append("</tr>");
		}

		if(list.size() > 0) 
		{
			sb.append("<tr>");
			sb.append("<td class=sum colspan=8 style=text-align:center><b>총계</b></td>");
			sb.append("<td class=sum>" + sum_tot_score + "</td>");
			sb.append("<td class=sum>" + sum_eval_score + "</td>");
			sb.append("<td class=sum></td>");
			sb.append("</tr>");
		}

		sb.append("</table>");
		out.print(sb.toString());
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