<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"user_stat","")) return;

	Db db = null;

	try 
	{
		Site.setExcelHeader(response, out, "상담원별통계-평가항목");

		db = new Db(true);

		//String act = CommonUtil.getParameter("act");
		
		//System.out.println("act : "+act);

		String itemDataStr 	= ComLib.getPSNN(request,"itemData");
		JSONParser jsonParser = new JSONParser();
		JSONArray itemData 	= (JSONArray) jsonParser.parse(itemDataStr);
		//System.out.println("itemDataStr : "+itemDataStr);		
		
		int itemSize = itemData.size();
		
		StringBuffer sb = new StringBuffer();

		sb.append("<table border='1' bordercolor='#bbbbbb'>");
		sb.append("<tr align='center'>");
		sb.append("<td class=th>대분류</td>");
		sb.append("<td class=th>중분류</td>");
		sb.append("<td class=th>소분류</td>");

		sb.append("<td class=th>상담원 ID</td>");
		sb.append("<td class=th>상담원 명</td>");
		
		sb.append("<td class=th>평가차수</td>");
		sb.append("<td class=th>평가자</td>");
		sb.append("<td class=th>평가일</td>");

		
		for(int i=0; i<itemSize; i++) {
			JSONObject d = (JSONObject) itemData.get(i);
			sb.append("<td class=th><nobr>"+d.get("item_name")+"<br>["+d.get("exam_score_max")+"<font color=gray>/</font>"+d.get("add_score_max")+"]</td>");
			// 2017.11.13 connick
			sb.append("<td class=th>코멘트</td>");
			// 2017.11.13 connick
		}		
		
		sb.append("<td class=th>총점</td>");
		sb.append("<td class=th>코멘트</td>");
		sb.append("<td class=th>총평</td>");
		sb.append("</tr>");		

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

		List<HashMap<String, Object>> list = db.selectList("stat_user.selectListItem", argMap);
		List<HashMap<String, Object>> resultList = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		String newInfo="", oldInfo="", newUserId="", oldUserId="", newOrder="";
		int idx = 0;
		
		//이벤트코드 + 사용자ID + 평가차수 별 :: 유일
		for(HashMap<String, Object> item : list)
		{
			newUserId = item.get("user_id").toString();
			newOrder  = item.get("eval_order").toString();
			newInfo   = newUserId +"/"+ newOrder;
				
			//System.out.println("newInfo="+newInfo+" , oldInfo="+oldInfo+" , resultList.size()="+resultList.size());
				
			if(!newInfo.equals(oldInfo))
			{
				//맨최초 레코드일 때 소계와 레코드 정보 안넣기 위함
				if(!oldInfo.equals(""))
				{
					resultList.add(resultMap);
					//사용자ID + 차수 : 정보가 모두 병합되고 사용자가 바뀔 때 아래 실행
					//소계 입력
					if(!newUserId.equals(oldUserId))
					{
						resultList.add(getSubSum(list, idx, oldUserId));
					}
				}
				
				resultMap = (HashMap<String, Object>) item.clone();

				if(newUserId.equals(oldUserId))
				{
					resultMap.put("part_name", " ");
					resultMap.put("user_id", "");
					resultMap.put("user_name", "");
				}
			}

			//  2017.11.13 connick 
			resultMap.put("item_comment_"+item.get("item_code"),item.get("item_comment"));
			//  2017.11.13 connick
			resultMap.put("exam_score_"+item.get("item_code"),item.get("exam_score"));
			resultMap.put("add_score_"+item.get("item_code"),item.get("add_score"));
			resultMap.put("item_score_"+item.get("item_code"),item.get("exam_score")+"<font color=#bbbbbb>/</font>"+item.get("add_score"));
			resultMap.remove("exam_score");
			resultMap.remove("add_score");

			oldUserId = newUserId;
			oldInfo   = newInfo;
			idx++;
		}
			
		if(!oldUserId.equals(""))
		{
			resultList.add(resultMap);
			resultList.add(getSubSum(list, idx, oldUserId));
		}
		
		int sum_eval_cnt = 0;
		int sum_exam_score_tot = 0;
		int sum_add_score_tot = 0;
		int sum_eval_score = 0;
		int sum_best_cnt = 0;
		int sum_worst_cnt = 0;
		
		for(Map<String, Object> item : resultList) 
		{
			//System.out.println("kind : "+item.get("kind"));
			//System.out.println("eval_cnt : "+item.get("eval_cnt"));
			//System.out.println("size : "+item.size());
			
			if(ComLib.toNN(item.get("kind")).equals("subSum"))
			{
				int eval_cnt = ComLib.toINN(item.get("eval_cnt"),1);
				sb.append("<tr><td class=subSum colspan=8 style=text-align:left>소계</td>");
				
				for(int j=0; j<itemSize; j++) 
				{
					JSONObject dd = (JSONObject) itemData.get(j);
					sb.append("<td class=subSum>&nbsp;"+ComLib.toNN(item.get("item_score_"+dd.get("item_code")))+"</td>");
					// 2017.11.13 connick
					sb.append("<td class=subSum>" + ComLib.toNN(item.get("item_comment_"+dd.get("item_code")))+"</td>");
					// 2017.11.13 connick
					
					
					//System.out.println("item_code : "+dd.get("item_code"));
					//System.out.println("item_code : "+dd.get("item_code"));
					//System.out.println("subSum : "+ComLib.toNN(item.get("item_score_"+dd.get("item_code"))));
				}
				/*
				System.out.println("eval_cnt : "+eval_cnt);
				System.out.println("sum_exam_score_tot : "+sum_exam_score_tot);
				System.out.println("sum_exam_score_tot/eval_cnt : "+ComLib.round((double)sum_exam_score_tot/eval_cnt,0));
				*/
				sb.append("<td class=subSum><font color=blue>"+item.get("best_cnt")+"</font><font color=#aaaaaa>/</font><font color=red>"+ item.get("worst_cnt") +"</font><font color=#aaaaaa>/</font>"+ ComLib.round(Double.parseDouble(item.get("eval_score").toString())/eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ ComLib.round((double)sum_exam_score_tot/eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ item.get("add_score_tot")+"</td><td class=subSum colspan=2></td>");
				
				sum_eval_cnt = 0;
				sum_exam_score_tot = 0;
				sum_add_score_tot = 0;
				sum_eval_score = 0;
				sum_best_cnt = 0;
				sum_worst_cnt = 0;				
			}
			else
			{
				//System.out.println("best_cnt  : "+item.get("best_cnt"));

				// 총계 저장
				
				sum_eval_cnt		+= ComLib.toINN(Integer.parseInt(item.get("eval_cnt").toString()),1);
				sum_exam_score_tot	+= ComLib.toINN(item.get("exam_score_tot"));
				sum_add_score_tot	+= ComLib.toINN(item.get("add_score_tot"));
				sum_eval_score		+= ComLib.toINN(item.get("eval_score"));
				sum_best_cnt		+= ComLib.toINN(item.get("best_cnt"));
				sum_worst_cnt		+= ComLib.toINN(item.get("worst_cnt"));
				
				//System.out.println("sum_best_cnt : "+sum_best_cnt);

				sb.append("<tr class=l>");
				
				if(item.get("user_id").equals(""))
				{
					sb.append("<td colspan=5></td>");
					//sb.append("<td></td><td></td><td></td><td></td><td></td>");
				}
				else
				{
					sb.append("<td>" + ComLib.toNN(item.get("bpart_name"),"-") + "</td>");
					sb.append("<td>" + ComLib.toNN(item.get("mpart_name"),"-") + "</td>");
					sb.append("<td>" + ComLib.toNN(item.get("spart_name"),"-") + "</td>");
					sb.append("<td>" + item.get("user_id") + "</td>");
					sb.append("<td>" + item.get("user_name") + "</td>");
				}

				sb.append("<td>" + ComLib.nvl2(item.get("eval_order"), item.get("eval_order") + "차","-")+"</td>");
				sb.append("<td>" + item.get("eval_user_name") + "</td>");
				sb.append("<td class=c>" + item.get("upd_datm") + "</td>");
				
				for(int j=0; j<itemSize; j++) 
				{
					JSONObject dd = (JSONObject) itemData.get(j);
					sb.append("<td class=r>&nbsp;"+ComLib.toNN(item.get("item_score_"+dd.get("item_code")))+"</td>");
					// 2017.11.13 connick
					sb.append("<td class=c>" + ComLib.toNN(item.get("item_comment_"+dd.get("item_code")))+"</td>");
					// 2017.11.13 connick
				}			

				String bestWorst = (item.get("best_cnt").toString().equals("1")) ? "<font color=blue>ⓑ</font>" : (item.get("worst_cnt").toString().equals("1")) ? "<font color=red>ⓦ</font>" : "";
				sb.append("<td class=r>"+bestWorst + ComLib.toINN(item.get("eval_score")) +"<font color=#arraaaaa>/</font>"+ ComLib.toINN(item.get("exam_score_tot")) +"<font color=#aaaaaa>/</font>"+ ComLib.toINN(item.get("add_score_tot"))+"</td>");
				sb.append("<td>" + ComLib.toNN(item.get("eval_comment")) + "</td>");
				sb.append("<td>" + ComLib.toNN(item.get("eval_text")) + "</td>");
			}			
		}
		
		if(list.size() > 0) 
		{
			//sb.append("<tr><td class=sum colspan="+(8+itemSize*2)+" style=text-align:left><b>총계</b></td>");
			/*
			for(int j=0; j<itemSize; j++) 
			{
				JSONObject dd = (JSONObject) itemData.get(j);
				sb.append("<td class=c>" + "111"+"</td>");
				sb.append("<td class=r>&nbsp;</td>");
			}
			*/
			//sb.append("<td class=sum><font color=blue>"+sum_best_cnt+"</font><font color=#aaaaaa>/</font><font color=red>"+ sum_worst_cnt +"</font><font color=#aaaaaa>/</font>"+ ComLib.round((double)sum_eval_score/sum_eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ ComLib.round((double)sum_exam_score_tot/sum_eval_cnt,0) +"<font color=#aaaaaa>/</font>"+ sum_add_score_tot+"</td><td class=sum colspan=2></td>");			
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
<%!

	public HashMap<String, Object> getSubSum(List<HashMap<String, Object>> list, int idx, String user_id)
	{
		//System.out.println(idx+" , user_id="+user_id+" , list="+list);
		HashMap<String, Object> rsltMap = new HashMap<String, Object>();
		HashMap<String, Integer> itemMap = new HashMap<String, Integer>();
		rsltMap.put("kind", "subSum");
		rsltMap.put("part_name", "<font color=gray>소계</font>");
		rsltMap.put("user_id", "-");
		rsltMap.put("user_name", "-");
		rsltMap.put("eval_order", "");
		rsltMap.put("eval_user_name", "-");
		rsltMap.put("upd_datm", "-");
		rsltMap.put("pq_rowcls", "red");
	
	
		int best_cnt=0, worst_cnt=0, eval_score=0, exam_score_tot=0, add_score_tot=0;
		double eval_cnt=0;
		String evalOrderOld = "";
		for(HashMap<String, Object> item : list)
		{
			//System.out.println(item.get("user_id")+" : "+item.get("eval_order"));
			if(item.get("user_id").toString().equals(user_id))
			{
				if(!item.get("eval_order").toString().equals(evalOrderOld))
				{
					eval_cnt++;
					//System.out.println(item.get("user_id")+" : "+item.get("eval_order"));
					best_cnt += Integer.parseInt(item.get("best_cnt").toString());
					worst_cnt += Integer.parseInt(item.get("worst_cnt").toString());
					eval_score += Integer.parseInt(item.get("eval_score").toString());
					exam_score_tot += Integer.parseInt(item.get("exam_score_tot").toString());
					add_score_tot += Integer.parseInt(item.get("add_score_tot").toString());
				}
				itemMap.put("exam_score_"+item.get("item_code"), ComLib.toINN(itemMap.get("exam_score_"+item.get("item_code"))) + ComLib.toINN(item.get("exam_score")));
				itemMap.put("add_score_"+item.get("item_code"),  ComLib.toINN(itemMap.get("add_score_"+item.get("item_code")))  + ComLib.toINN(item.get("add_score")));
				rsltMap.put("item_score_"+item.get("item_code"),"<b><font color=blue>"+ComLib.round(itemMap.get("exam_score_"+item.get("item_code"))/eval_cnt,1)+"<font color=#bbbbbb>/</font>"+ComLib.round(itemMap.get("add_score_"+item.get("item_code"))/eval_cnt,1)+"</font></b>");
				evalOrderOld = item.get("eval_order").toString();
			}
			else
			{
				evalOrderOld = "";
			}
		}
		rsltMap.put("eval_cnt", (int) eval_cnt);
		rsltMap.put("best_cnt", best_cnt);
		rsltMap.put("worst_cnt", worst_cnt);
		rsltMap.put("eval_score", eval_score);
		rsltMap.put("exam_score_tot", exam_score_tot);
		rsltMap.put("add_score_tot", add_score_tot);
		return rsltMap;
	}
%>