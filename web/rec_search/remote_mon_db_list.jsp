<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	// 메뉴 접근권한 체크
	if(!Site.isPmss(out,"mon_db_list","")) return;
	
	Db db = null;
	
	try 
	{
		// DB Connection
		db = new Db();
	
		// get parameter
		String bpart_code = CommonUtil.getParameter("bpart_code");
		String mpart_code = CommonUtil.getParameter("mpart_code");
		String spart_code = CommonUtil.getParameter("spart_code");
		String s_local_no = CommonUtil.getParameter("local_no");
		String mon_order = CommonUtil.getParameter("mon_order","ch");
	
		// 파라미터 체크
		if(!CommonUtil.hasText(bpart_code)) 
		{
			//out.print(CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}
	
		Map<String, Object> argMap = new HashMap<String, Object>();
	
		argMap.put("bpart_code",bpart_code);
		argMap.put("mpart_code",mpart_code);
		argMap.put("spart_code",spart_code);
		argMap.put("local_no",s_local_no);
		argMap.put("mon_order", mon_order);
	
		// 사용자 권한에 따른 녹취이력 조회
		argMap.put("_user_id", _LOGIN_ID);
		argMap.put("_user_level", _LOGIN_LEVEL);
		argMap.put("_bpart_code",_BPART_CODE);
		argMap.put("_mpart_code",_MPART_CODE);
		argMap.put("_spart_code",_SPART_CODE);
	
		List<Map<String, Object>> list = db.selectList("mon_db.selectList", argMap);
	
		if(list.size() < 1) 
		{
			out.print(CommonUtil.getErrorMsg("NO_DATA"));
			return;
		}

		//카운트 조회
		List<Map<String, Object>> list2 = db.selectList("mon_db.selectCountList", argMap);

	%>
	<div class="grey_back1">
		<div class="colLeft">
			<div class="colLeft"><span class="ext_text"><font size="2"><b><%=list2.get(0).get("time").toString()%></b></font></span></div>
			<div class="colLeft">&nbsp;&nbsp;&nbsp;</div>
			<div class="colLeft"><span class="ext_text"><font size="2">당일 녹취 건수 : <b><%=list2.get(0).get("rec_count").toString()%>건</b></font></span></div>
			<div class="colLeft">&nbsp;&nbsp;&nbsp;</div>
			<div class="colLeft"><span class="ext_text"><font size="2">현재 녹취 중 : <b><%=list2.get(0).get("mon_count").toString()%>건</b></font></span></div>
		</div>
		<div class="colRight">
			<!-- 
			<div class="colLeft"><span class="ext_squre01 colLeft"></span><span class="ext_text">대기상태</span></div>
			<div class="colLeft"><span class="ext_squre02 colLeft"></span><span class="ext_text">녹취상태</span></div>
			<div class="colLeft"><span class="ext_squre03 colLeft"></span><span class="ext_text">녹취불량</span></div>
			 -->
			<div class="colLeft"><span class="ext_squre01_2 colLeft"></span><span class="ext_text">대기</span></div>
			<div class="colLeft"><span class="ext_squre02_1 colLeft"></span><span class="ext_text">녹취중</span></div>
<%--			<div class="colLeft"><span class="ext_squre02_2 colLeft"></span><span class="ext_text">아웃바운드</span></div>--%>
			<div class="colLeft"><span class="ext_squre01_1 colLeft"></span><span class="ext_text">대기(10분이상)</span></div>
			<div class="colLeft"><span class="ext_squre02_3 colLeft"></span><span class="ext_text">녹취중(10분이상)</span></div>
<%--			<div class="colLeft"><span class="ext_squre02_4 colLeft"></span><span class="ext_text">아웃바운드(10분이상)</span></div>--%>
			<div class="colLeft"><span class="ext_squre03 colLeft"></span><span class="ext_text">녹취불량</span></div>
		</div>
	</div>	

	<!--내선번호 영역 시작-->
	<div class="grey_back1">
	<%
		for(Map<String, Object> item : list) 
		{
			String ch_no = item.get("channel").toString();
			String ch_status = item.get("state").toString();
			String user_name = item.get("user_name").toString();
			String local_no = item.get("phone").toString();
			String system_ip = item.get("system_ip").toString();
			String backup_ip = CommonUtil.ifNull(item.get("backup_ip")+"") ;
			//String call_time = ("1".equals(ch_status)) ? item.get("call_time").toString() : "&nbsp;";
			String call_time = item.get("call_time").toString();
			//String rec_inout = item.get("rec_inout").toString();
			String rec_inout = ("1".equals(ch_status)) ? ComLib.toNN(item.get("rec_inout"), "N") : "&nbsp;";
			//String rec_inout_nm = ("1".equals(ch_status)) ? (("N".equals(rec_inout) ? "&nbsp;" : (("I".equals(rec_inout) ? "IN" : "OUT")) : ("0".equals(ch_status)) ?  "WAIT" : "&nbsp;";
			String rec_inout_nm = ("1".equals(ch_status) ? ("N".equals(rec_inout) ? "&nbsp;" : ("I".equals(rec_inout) ? "IN" : "OUT")) : ("0".equals(ch_status) ? "WAIT" : "&nbsp;"));
			
			String spart_name = item.get("spart_name").toString();
			String ani = ("1".equals(ch_status)) ? item.get("ani").toString() : "&nbsp;";
			
			Date dateTime = DateUtil.getDate(item.get("datetime").toString(), "yyyy-MM-dd HH:mm:ss");
			Date todateTime = DateUtil.getDate(DateUtil.getToday("yyyy-MM-dd HH:mm:ss"), "yyyy-MM-dd HH:mm:ss");
			int diff = DateUtil.getDateDiff(dateTime, todateTime, "M");
			
			// 상태별 색상 설정
			String status_cls = "";
			/*
				ch_status 정보
				대기 	: 0
				녹취 상태 : 1
				녹취 불량 : 0,1 이외
				
				인아웃구분(rec_inout)
				IN  : I
				OUT : O				
			*/
			/*
			if("0".equals(ch_status))		status_cls = "1"; 
			else if("1".equals(ch_status))	status_cls = "2";
			else							status_cls = "3";
			*/
			if("0".equals(ch_status))
			{
				if(diff < 10)	status_cls = "1_2";
				else			status_cls = "1_1";
			}
			else if("1".equals(ch_status))
			{
				if("I".equals(rec_inout))
				{
					if(diff < 10)	status_cls = "2_1";
					else			status_cls = "2_3";
				}
				else if("O".equals(rec_inout))
				{
					if(diff < 10)	status_cls = "2_2";
					else			status_cls = "2_4";
				}
				else
				{
					if(diff < 10)	status_cls = "2_1";
					else			status_cls = "2_3";
				}
			}	
			else							status_cls = "3";
			
			//logger.info("|"+backup_ip+"|");
			//backup_ip가 없을 경우 이상 현상 발생하여 수정 - CJM(20190102)
			//String ip = system_ip + "/" + backup_ip;
			//if("".equals(backup_ip))	ip = system_ip;
			//KT114에만 백업 IP 정보 필요하여 주석 처리 - CJM(20200103)
			String ip = system_ip;

			if (Integer.parseInt(local_no) < 30000) {
				ip = "10.144.31.18";
			} else {
				ip = "10.144.35.18";
			}
			//logger.info("ip : "+ip);
			//logger.info("spart_name : "+spart_name);
			out.print("<div class=\"ext_frame\">\n");
			
			out.print("	<div class=\"ext_number ext_bg0" + status_cls + "\" style=\"cursor: pointer;\" onclick=\"playRlisten('" + ch_status + "','" + ch_no + "','" + local_no + "','" + ip + "')\">\n");
			out.print("		<span><br>" + ch_no + "<br>"+local_no+"</span>\n");
			out.print("	</div>\n");
			
			out.print("	<div class=\"ext_name\" >\n");
			out.print("		<span class=\"colLeft ext_all_with\" title=\"" + spart_name + "\" >" + ComLib.getEllipsis(spart_name, 4) + "</span>\n");
			out.print("		<span class=\"colLeft ext_all_with ext_col_66\">" + user_name + "</span>\n");
			out.print("		<span class=\"colLeft ext_all_with ext_col_66\">" + ani + "</span>\n");
			out.print("		<span class=\"colLeft ext_with ext_col_9d\">" + rec_inout_nm + "</span>\n");
			out.print("		<span class=\"colRight ext_with ext_col_9d\">" + call_time + "</span>\n");
			
			out.print("	</div>\n");
			
			out.print("</div>\n");
			
			
			/*
			out.print("<div class=\"ext_frame\">\n");
			out.print("	<div class=\"ext_number ext_bg0" + status_cls + "\" style=\"cursor: pointer;\" onclick=\"playRlisten('" + ch_status + "','" + ch_no + "','" + local_no + "','" + ip + "')\">" + ch_no + "</div>\n");
			out.print("	<div class=\"ext_name\">\n");
			out.print("		<span>" + user_name + "</span>\n");
			out.print("		<span style=\"font-size:16px;color:#666;\">" + local_no + "</span>\n");
			out.print("		<span style=\"color:#00679d;\">" + call_time + "</span>\n");
			out.print("	</div>\n");
			out.print("</div>\n");
			*/
		}
	%>
	</div>
	<!--내선번호 영역 끝-->
	<div class="grey_back2">
		<!-- 
		<div class="colLeft"><span class="ext_squre01 colLeft"></span><span class="ext_text">대기상태</span></div>
		<div class="colLeft"><span class="ext_squre02 colLeft"></span><span class="ext_text">녹취상태</span></div>
		<div class="colLeft"><span class="ext_squre03 colLeft"></span><span class="ext_text">녹취불량</span></div>
		 -->
		<div class="colLeft"><span class="ext_squre01_2 colLeft"></span><span class="ext_text">대기</span></div>
		<div class="colLeft"><span class="ext_squre02_1 colLeft"></span><span class="ext_text">녹취중</span></div>
<%--		<div class="colLeft"><span class="ext_squre02_2 colLeft"></span><span class="ext_text">아웃바운드</span></div>--%>
		<div class="colLeft"><span class="ext_squre01_1 colLeft"></span><span class="ext_text">대기(10분이상)</span></div>
		<div class="colLeft"><span class="ext_squre02_3 colLeft"></span><span class="ext_text">녹취중(10분이상)</span></div>
<%--		<div class="colLeft"><span class="ext_squre02_4 colLeft"></span><span class="ext_text">아웃바운드(10분이상)</span></div>--%>
		<div class="colLeft"><span class="ext_squre03 colLeft"></span><span class="ext_text">녹취불량</span></div>
	</div>
<%
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db != null)	db.close();
	}
%>