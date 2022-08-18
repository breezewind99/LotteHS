<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"average_stat","")) return;

	try {
		Site.setExcelHeader(response, out, "부서별항목별통계-평균 점수");

		String dataStr 		= ComLib.getPSNN(request,"data");
		String itemDataStr 	= ComLib.getPSNN(request,"itemData");

		JSONParser jsonParser = new JSONParser();
		//XSS 보안강화로  특수문자 변환으로 오류 발생 - CJM(20200722)
		//JSONArray data 		= (JSONArray) jsonParser.parse(dataStr);
		JSONArray data 	= (JSONArray) jsonParser.parse(CommonUtil.toTextHTML(dataStr));
		JSONArray itemData 	= (JSONArray) jsonParser.parse(itemDataStr);
		
		//System.out.println("itemDataStr="+itemDataStr);
		int itemSize = itemData.size();

		StringBuffer sb = new StringBuffer();

		sb.append
			("<table border='1' bordercolor='#bbbbbb'>").append
				("<tr align='center'>").append
				("<td class=th>대분류</td>").append
				("<td class=th>중분류</td>").append
				//("<td class=th>소분류</td>").append

				("<td class=th>인원</td>").append
				("<td class=th>배점총점</td>");

		int colSize=0;
		for(int i=0; i<itemSize; i++) {
			JSONObject d = (JSONObject) itemData.get(i);
			if(d.get("obj_type").equals("I")){
				sb.append("<td class=th><nobr>"+d.get("item_name")+"<br>["+d.get("exam_score_max")+"<font color=gray>/</font>"+d.get("add_score_max")+"]</td>");
			}else{
				colSize++;				
			}
		}

		sb.append("</tr>");

		int sum_eval_cnt = 0;
		int sum_tot_score = 0;
		int sum_exam_score = 0;
		int sum_add_score = 0;
		int sum_eval_score = 0;
		
		float[] totExam = new float[itemSize-colSize];
		float[] totAdd = new float[itemSize-colSize];

		for(int i=0, len=data.size();i<len;i++) {
			JSONObject d = (JSONObject) data.get(i);

			// 총계 저장
			sum_eval_cnt		+= ComLib.toINN(d.get("eval_cnt"),1);
			sum_tot_score		+= ComLib.toINN(d.get("tot_score"),1);
			sum_exam_score		+= ComLib.toINN(d.get("exam_score"));
			sum_add_score		+= ComLib.toINN(d.get("add_score"));
			sum_eval_score		+= ComLib.toINN(d.get("eval_score"));

			sb.append("<tr class=l>");
			if(d.get("mpart_code").equals("")){
				sb.append("<td colspan=5></td>");
				//sb.append("<td></td><td></td><td></td><td></td><td></td>");
			}
			else{
				sb.append("<td>" + ComLib.toNN(d.get("bpart_name"),"-") + "</td>");
				sb.append("<td>" + ComLib.toNN(d.get("mpart_name"),"-") + "</td>");
				//sb.append("<td>" + ComLib.toNN(d.get("spart_name"),"-") + "</td>");
				sb.append("<td class=r>" + d.get("eval_cnt") + "</td>");
				sb.append("<td class=r>" + d.get("tot_score") + "</td>");
			}
			
			int totCnt = 0;
			for(int ii=0; ii<itemSize; ii++) {
				JSONObject dd = (JSONObject) itemData.get(ii);
				if(dd.get("obj_type").equals("I")){
					sb.append("<td class=r>&nbsp;"+d.get("item_score_"+dd.get("item_code"))+"</td>");
					totExam[totCnt] = totExam[totCnt]+Integer.parseInt(d.get("item_score_"+ dd.get("item_code")).toString().substring(0, d.get("item_score_"+dd.get("item_code")).toString().indexOf("<")).toString());
					totAdd[totCnt] = totAdd[totCnt]+Integer.parseInt(d.get("item_score_"+dd.get("item_code")).toString().substring(d.get("item_score_"+dd.get("item_code")).toString().lastIndexOf(">")+1).toString());
					totCnt++;
				}
			}
		}
		
		if(data.size()>0){
			sb.append("<tr><td class=sum colspan=2 style=text-align:left><b>총계</b></td>");
			sb.append("<td class=sum>"+ sum_eval_cnt+"</td>");
			sb.append("<td class=sum>"+ sum_tot_score+"</td>");
			
			for(int ii=0; ii<(itemSize-colSize); ii++) {
				sb.append("<td class=sum>"+ Math.round(totExam[ii]/data.size()*10)/10.0+"/"+Math.round(totAdd[ii]/data.size()*10)/10.0+"</td>");
			}
		}
		
		sb.append("</tr>");
		sb.append("</table>");
		//System.out.println(sb.toString());

		out.print(sb.toString());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {

	}
%>