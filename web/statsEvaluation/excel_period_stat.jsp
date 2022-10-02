<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"period_stat","")) return;

	Db db = null;

	try {
		Site.setExcelHeader(response, out, "월별통계-평가점수");

		db = new Db(true);

		// get parameter
		String sort_idx = "user_id";//CommonUtil.getParameter("sort_idx", "user_id");
		String sort_dir = CommonUtil.getParameter("sort_dir", "up");
		String eval_date1 = CommonUtil.getParameter("eval_date1");
		String eval_date2 = CommonUtil.getParameter("eval_date2");
		//String event_code = CommonUtil.getParameter("event_code");
		String sheet_code = CommonUtil.getParameter("sheet_code");
		String bpart_code = CommonUtil.getParameter("bpart_code");
		String mpart_code = CommonUtil.getParameter("mpart_code");
		String spart_code = CommonUtil.getParameter("spart_code");
		String user_name = CommonUtil.getParameter("user_name");
		String eval_user_name = CommonUtil.getParameter("eval_user_name");
		String year_code = CommonUtil.getParameter("year_code");
		int eval_order_max = 12;

		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		StringBuffer sb = new StringBuffer();

		sb.append("<table border='1' bordercolor='#bbbbbb'>");
		sb.append("<tr align='center'>");
		sb.append("<td class=th>대분류</td>");
		sb.append("<td class=th>중분류</td>");
		sb.append("<td class=th>소분류</td>");

		sb.append("<td class=th>상담원 ID</td>");
		sb.append("<td class=th>상담원 명</td>");

		for(int i=1; i <= eval_order_max; i++){
			sb.append("<td class=th>"+i+"월(총점)</td>");
			sb.append("<td class=th>"+i+"월(평균)</td>");
		}

		sb.append("<td class=th>총점</td>");
		sb.append("<td class=th>평균</td>");
		sb.append("</tr>");

		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("eval_date1",eval_date1.replace("-", ""));
		argMap.put("eval_date2",eval_date2.replace("-", ""));
		//argMap.put("event_code",event_code);
		argMap.put("sheet_code",sheet_code);
		argMap.put("bpart_code",bpart_code);
		argMap.put("mpart_code",mpart_code);
		argMap.put("spart_code",spart_code);
		argMap.put("user_name",user_name);
		argMap.put("eval_user_name",eval_user_name);
		argMap.put("year_code",year_code);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		//argMap.put("eval_order_max", eval_order_max);

		List<Map<String, Object>> list = db.selectList("stat_period.selectListMonth", argMap);
		int sum_tot_eval_cnt = 0;
		int sum_tot_eval_score = 0;
		double sum_tot_eval_average = 0;
		
		int sum_tot[] = ComLib.makeIntArray(eval_order_max,0);
		int cnt_tot[] = ComLib.makeIntArray(eval_order_max,0);

		for(Map<String, Object> item : list) {
			// 총계 저장
			for(int i=1; i <= eval_order_max; i++) {
				sum_tot[i-1] += ComLib.toINN(item.get("sum"+i));
				cnt_tot[i-1] += ComLib.toINN(item.get("cnt"+i));
			}

			sb.append("<tr align=right>");
			sb.append("<td align=left>" + item.get("bpart_name") + "</td>");
			sb.append("<td align=left>" + item.get("mpart_name") + "</td>");
			sb.append("<td align=left>" + item.get("spart_name") + "</td>");

			sb.append("<td>" + item.get("user_id") + "</td>");
			sb.append("<td>" + item.get("user_name") + "</td>");
			
			int sub_sum = 0;
			double sub_avg = 0;
			for(int i=1; i <= eval_order_max; i++) {
				sub_sum += ComLib.toINN(item.get("sum"+i));
				sub_avg += Double.parseDouble(ComLib.calcRound(ComLib.toINN(item.get("sum"+i)), item.get("cnt"+i), 2).toString());

				sb.append("<td>" + ((item.get("sum"+i).toString().equals("0")) ? "-" : item.get("sum"+i)) + "</td>");
				sb.append("<td>" + ((item.get("cnt"+i).toString().equals("0")) ? "-" : ComLib.calcRound(item.get("sum"+i), item.get("cnt"+i), 2)) + "</td>");
			}
			
			if(sub_sum>0){
				sum_tot_eval_cnt++;
			}
			sum_tot_eval_score += sub_sum;
			sum_tot_eval_average += sub_avg;

			sb.append("<td>" + sub_sum + "</td>");
			sb.append("<td>" + sub_avg + "</td>");
			sb.append("</tr>");
		}

		if(list.size()>0) {
			sb.append("<tr>");
			sb.append("<td class=sum colspan=5 style=text-align:center><b>총계</b></td>");
			for(int i=0; i < eval_order_max; i++) {
				sb.append("<td class=sum>" + ((sum_tot[i]==0) ? "-" : sum_tot[i]) + "</td>");
				sb.append("<td class=sum>" + ((cnt_tot[i]==0) ? "-" : ComLib.round((double)sum_tot[i]/cnt_tot[i],2)) + "</td>");
			}
			
			sb.append("<td class=sum>" + sum_tot_eval_score + "</td>");
			sb.append("<td class=sum>" + ((sum_tot_eval_cnt>0) ? ComLib.round((double)sum_tot_eval_average/sum_tot_eval_cnt,2) : 0) + "</td>");
			sb.append("</tr>");
		}

		sb.append("</table>");
		out.print(sb.toString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>