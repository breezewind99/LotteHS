<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"average_stat","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		String act = CommonUtil.getParameter("act");
		if(act.equals("list"))
		{
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
			sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

			Map<String, Object> argMap = new HashMap<String, Object>();
			//argMap.put("eval_date1",eval_date1.replace("-", ""));
			//argMap.put("eval_date2",eval_date2.replace("-", ""));
			argMap.put("eval_date1",eval_date1);
			argMap.put("eval_date2",eval_date2);
			argMap.put("event_code",event_code);
			argMap.put("sheet_code",sheet_code);
			argMap.put("bpart_code",bpart_code);
			argMap.put("mpart_code",mpart_code);
			argMap.put("spart_code",spart_code);
			argMap.put("user_name",user_name);
			argMap.put("eval_user_name",eval_user_name);
			argMap.put("sort_idx", sort_idx);
			argMap.put("sort_dir", sort_dir);

			List<HashMap<String, Object>> list = db.selectList("stat_average.selectListAverage", argMap);
			List<HashMap<String, Object>> resultList = new ArrayList<HashMap<String, Object>>();
			HashMap<String, Object> resultMap = new HashMap<String, Object>();
			String newInfo="", oldInfo="", newUserId="", oldUserId="", newOrder="";
			int tot_score=0;

			for(int i=0; i<list.size(); i++)
			{
				HashMap<String, Object> item = list.get(i);
				HashMap<String, Object> nextItem = new HashMap<String, Object>();
				
				newUserId = item.get("bpart_code").toString()+item.get("mpart_code").toString();

				if(i<list.size()-1)
				{
					nextItem = list.get(i+1);
					oldUserId = nextItem.get("bpart_code").toString()+nextItem.get("mpart_code").toString();
				}
				
				int eval_cnt = Integer.parseInt(item.get("eval_cnt").toString());
				int eval_order = Integer.parseInt(item.get("eval_order").toString());
				
				resultMap.put("mpart_code",item.get("mpart_code"));
				resultMap.put("mpart_name",item.get("mpart_name"));
				resultMap.put("bpart_code",item.get("bpart_code"));
				resultMap.put("bpart_name",item.get("bpart_name"));
				
				resultMap.put("eval_cnt",item.get("eval_cnt"));
				resultMap.put("eval_order",item.get("eval_order"));
				
				//resultMap.put("exam_score_"+item.get("item_code"),item.get("exam_score"));
				//resultMap.put("add_score_"+item.get("item_code"),item.get("add_score"));
				
				//resultMap.put("tot_score",item.get("tot_score"));
				
				resultMap.put("exam_score_"+item.get("item_code"),Math.round(Integer.parseInt(item.get("exam_score").toString())/(eval_cnt*eval_order)*10)/10);
				resultMap.put("add_score_"+item.get("item_code"),Math.round(Integer.parseInt(item.get("add_score").toString())/(eval_cnt*eval_order)*10)/10);
				
				resultMap.put("item_score_"+item.get("item_code"),Math.round(Integer.parseInt(item.get("exam_score").toString())/(eval_cnt*eval_order)*10)/10+"<font color=#bbbbbb>/</font>"+Math.round(Integer.parseInt(item.get("add_score").toString())/(eval_cnt*eval_order)*10)/10);
				
				//tot_score += Integer.parseInt(item.get("tot_score").toString())/(eval_cnt*eval_order);
				tot_score += Integer.parseInt(item.get("tot_score").toString())/eval_order;
				resultMap.put("tot_score",tot_score);
				
				if(i == 0)
				{}
				else if(i==list.size()-1)
				{
					resultList.add(resultMap);	
				}
				else
				{
					if(!newUserId.equals(oldUserId))
					{
						resultList.add(resultMap);
						resultMap = new HashMap<String, Object>();
						tot_score = 0;
					}
				}
			}
			
			
			JSONObject json = new JSONObject();
			json.put("totalRecords", resultList.size());
			json.put("data", resultList);
			out.print(json.toJSONString());
		}
		else if(act.equals("getItem"))
		{
			Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("sheet_code",CommonUtil.getParameter("sheet_code"));
			
			//List<Map<String, Object>> list = db.selectList("stat_user.getItem", argMap);
			List<Map<String, Object>> list = db.selectList("stat_user.getCate", argMap);

			JSONObject json = new JSONObject();
			json.put("code", "OK");
			json.put("data", list);
			out.print(json.toJSONString());
		}
	} 
	catch(Exception e) 
	{
		logger.error(e.getMessage());
		Site.writeJsonResult(out,e);
	} 
	finally 
	{
		if(db != null)	db.close();
	}

%>