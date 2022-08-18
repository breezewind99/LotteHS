<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		// get parameter
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "rec_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		String rec_date1 = CommonUtil.getParameter("rec_date1");
		String rec_date2 = CommonUtil.getParameter("rec_date2");
		String rec_start_hour1 = CommonUtil.getParameter("rec_start_hour1");
		String rec_start_hour2 = CommonUtil.getParameter("rec_start_hour2");
		String rec_call_time1 = CommonUtil.getParameter("rec_call_time1");
		String rec_call_time2 = CommonUtil.getParameter("rec_call_time2");
		String bpart_code = CommonUtil.getParameter("bpart_code");
		String mpart_code = CommonUtil.getParameter("mpart_code");
		String spart_code = CommonUtil.getParameter("spart_code");
		String system_code = CommonUtil.getParameter("system_code");
		String local_no1 = CommonUtil.getParameter("local_no1");
		String local_no2 = CommonUtil.getParameter("local_no2");
		String rec_inout = CommonUtil.getParameter("rec_inout");
		String user_id = CommonUtil.getParameter("user_id");
		String user_name = CommonUtil.getParameter("user_name");
		String cust_id = CommonUtil.getParameter("cust_id");
		String cust_name = CommonUtil.getParameter("cust_name");
		String cust_tel = CommonUtil.getParameter("cust_tel");
		String rec_keycode = CommonUtil.getParameter("rec_keycode");
		String rec_filename = CommonUtil.getParameter("rec_filename");
		String rec_succ_code = CommonUtil.getParameter("rec_succ_code");
		String rec_abort_code = CommonUtil.getParameter("rec_abort_code");
		String rec_store_code = CommonUtil.getParameter("rec_store_code");
		String rec_mystery_code = CommonUtil.getParameter("rec_mystery_code");
		String custom_fld_01 = CommonUtil.getParameter("custom_fld_01");
		String custom_fld_02 = CommonUtil.getParameter("custom_fld_02");
		String custom_fld_03 = CommonUtil.getParameter("custom_fld_03");
		String custom_fld_04 = CommonUtil.getParameter("custom_fld_04");
		String custom_fld_05 = CommonUtil.getParameter("custom_fld_05");
		
		// tree에서 선택된 user id list
		String user_list = CommonUtil.getParameter("user_list");

		cur_page = (cur_page<1) ? 1 : cur_page;
		sort_idx = ("v_".equals(CommonUtil.leftString(sort_idx, 2)) || "n_".equals(CommonUtil.leftString(sort_idx, 2))) ? sort_idx.substring(2) : sort_idx;
		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		// user id list parsing
		if(CommonUtil.hasText(user_list)) 
		{
			String user_ids[] = user_list.split(",");
			String tmp_user_list = "";
			for(int i=0; i<user_ids.length; i++) 
			{
				tmp_user_list += ",'" + user_ids[i] + "'";
			}
			user_list = tmp_user_list.substring(1);
		}
		/*
		logger.info("☆☆☆☆☆☆");
		logger.info("rec_date1 : "+rec_date1);
		logger.info("rec_date2 : "+rec_date2);
		logger.info("☆☆☆☆☆☆");
		*/
		
		// 녹취일자 확인 (동일한 년도의 데이터만 조회 가능)
		// 동일 년도 체크 제거 요청 - CJM(20190104)
		/*
		if(!rec_date1.substring(0, 4).equals(rec_date2.substring(0, 4))) 
		{
			Site.writeJsonResult(out, false, "동일한 년도의 이력만 조회 가능합니다.");
			return;
		}

		// 요청일시와 현재 시간의 차이를 구함
		Date from_date = DateUtil.getDate(DateUtil.getDateFormatByIntVal(rec_date1.replaceAll("-", ""), "yyyy-MM-dd"), "yyyy-MM-dd");
		Date to_date = DateUtil.getDate(DateUtil.getDateFormatByIntVal(rec_date2.replaceAll("-", ""), "yyyy-MM-dd"), "yyyy-MM-dd");
		
		int diff = DateUtil.getDateDiff(from_date, to_date, "D");
		
		//logger.info("diff : "+diff);

		// 3개월 이상일 경우 체크
		if(diff > 93) 
		{
			Site.writeJsonResult(out, false, "3개월 범위 이력만 조회 가능합니다.");
			return;
		}
		*/

		// paging 변수
		int tot_cnt = 0;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;

		JSONObject json = new JSONObject();

		Map<String, Object> confMap = new HashMap<String, Object>();
		Map<String, Object> resMap  = new LinkedHashMap<String, Object>();
		Map<String, Object> argMap  = new HashMap<String, Object>();
		Map<String, Object> parMap  = new HashMap<String, Object>();

		// config (session value mapping)
		confMap.put("business_code", _BUSINESS_CODE);
		confMap.put("user_id", _LOGIN_ID);
		confMap.put("user_level", _LOGIN_LEVEL);
		confMap.put("default_used", "1");

		// config select
		List<Map<String, Object>> conf_list = db.selectList("rec_search.selectResultConfig", confMap);

		for(Map<String, Object> item : conf_list) 
		{
			// result
			// 리스트 설정에서 hidden 개념 삭제
			//if(!"hidden".equals(item.get("result_value"))) {
				resMap.put(item.get("result_value").toString(), item.get("field_value").toString());
			//}
		}
		
		// search
		//argMap.put("dateStr", CommonUtil.getRecordTableNm(rec_date1));
		argMap.put("dateStr", "");
		argMap.put("top_cnt", top_cnt);
		argMap.put("rec_date1",rec_date1);
		argMap.put("rec_date2",rec_date2);
		argMap.put("rec_start_time1",rec_start_hour1+":00:00");
		argMap.put("rec_start_time2",("24".equals(rec_start_hour2)) ? "23:59:59" : rec_start_hour2+":00:00");
		argMap.put("rec_call_time1",DateUtil.getHmsToSec(Integer.parseInt(rec_call_time1)));
		argMap.put("rec_call_time2",DateUtil.getHmsToSec(Integer.parseInt(rec_call_time2)));
		argMap.put("bpart_code", bpart_code);
		argMap.put("mpart_code", mpart_code);
		argMap.put("spart_code", spart_code);
		argMap.put("system_code", system_code);
		argMap.put("local_no1", local_no1);
		argMap.put("local_no2", local_no2);
		argMap.put("rec_inout", rec_inout);
		argMap.put("user_id", user_id);
		argMap.put("user_name", user_name);
		argMap.put("cust_id", cust_id);
		argMap.put("cust_name", cust_name);
		argMap.put("cust_tel", cust_tel);
		argMap.put("rec_keycode", rec_keycode);
		argMap.put("rec_filename", rec_filename);
		argMap.put("rec_succ_code", rec_succ_code);
		argMap.put("rec_abort_code", rec_abort_code);
		argMap.put("rec_store_code", rec_store_code);
		argMap.put("rec_mystery_code", rec_mystery_code);
		argMap.put("user_list", user_list);
		argMap.put("custom_fld_01", custom_fld_01);
		argMap.put("custom_fld_02", custom_fld_02);
		argMap.put("custom_fld_03", custom_fld_03);
		argMap.put("custom_fld_04", custom_fld_04);
		argMap.put("custom_fld_05", custom_fld_05);

		// 사용자 권한에 따른 녹취이력 조회
		argMap.put("_user_id" ,_LOGIN_ID);
		argMap.put("_user_level" ,_LOGIN_LEVEL);
		argMap.put("_bpart_code" ,_BPART_CODE);
		argMap.put("_mpart_code" ,_MPART_CODE);
		argMap.put("_spart_code" ,_SPART_CODE);

		// record count
		Map<String, Object> cntmap = db.selectOne("rec_search.selectCount", argMap);
		
		//oracle 오류 발생하여 수정 - CJM(20190521)
		tot_cnt = Integer.valueOf(cntmap.get("tot_cnt").toString()).intValue();
		//tot_cnt = ((Integer)cntmap.get("tot_cnt")).intValue();
		page_cnt = Double.valueOf(cntmap.get("page_cnt").toString()).intValue();
		//page_cnt = ((Double)cntmap.get("page_cnt")).intValue();

		/**
			페이지 맨 끝 이동 후 페이지 노출 갯수 변경시 데이터 미노출 현상 체크 - CJM(20180706)
			count가 0 일 경우 예외 처리  - CJM(20190701)
		*/
		int skip = (top_cnt*(cur_page-1));
		if((tot_cnt != 0) && (skip >= tot_cnt))
		{
			page_cnt = (int)Math.ceil(((double)tot_cnt) / top_cnt);
			cur_page = page_cnt;
		}
		
		// paging 변수
		end_cnt = (cur_page*1)*top_cnt;
		start_cnt = end_cnt-(top_cnt-1);

		// search
		argMap.put("tot_cnt", tot_cnt);
		argMap.put("sort_idx", sort_idx);
		argMap.put("sort_dir", sort_dir);
		argMap.put("start_cnt", start_cnt);
		argMap.put("end_cnt", end_cnt);

		parMap.put("s", argMap);
		parMap.put("r", resMap);

		List<Map<String, Object>> list = db.selectList("rec_search.selectList", parMap);
		int row_indx = 0;
		/*
		String custTel = "";
		String vCustTel = "";
		*/
		for(Map<String, Object> item : list) 
		{
			//전화번호 마스킹 처리 및 Tooltip - CJM(20190213)
			//롯데 보안 이슈로 수정 요청
			/*
			if(item.containsKey("v_cust_tel")) 
			{
				custTel = item.get("v_cust_tel").toString().trim();
				
				if(custTel.length() > 4)	vCustTel = custTel.substring(0,custTel.length()-4)+"****";
				else						vCustTel = custTel;
				
				//logger.info("custTel : "+custTel);
				//logger.info("vCustTel : "+vCustTel);
								 
				item.put("v_cust_tel", "<span title='"+custTel+"'>"+vCustTel+"</span>");
			}
			if(item.containsKey("n_cust_tel")) 
			{
				custTel = item.get("n_cust_tel").toString().trim();
				
				vCustTel = ComLib.getPhoneFormatHideHtml2(custTel);
								 
				item.put("n_cust_tel", vCustTel);
			}			
			*/
			
			/*
				청취시 표시 요청 - CJM(20200120)
				청취한 정보에 대한 표시 요청에 따른 수정
				
				if("1".equals(item.get("rec_stt_code")))	item.put("pq_rowcls", "red");
			*/
			
			if(item.containsKey("v_url")) 
			{
				// 듣기
				item.put("v_url", "<img src='../img/icon/ico_player.png' onclick=\"playRecFileByIdx('" + row_indx + "','rec'); f_chg_background(this);\" style='margin-left: 5px; cursor: pointer;'/>");
			}
			if(item.containsKey("v_download")) 
			{
				item.put("v_download", "<img src='../img/icon/ico_down.png' onclick=\"downloadRecFile('" + row_indx + "');\" style='margin-left: 5px; cursor: pointer;'/>");
			}
			if(item.containsKey("v_memo")) 
			{
				item.put("v_memo", "<img src='../img/icon/ico_memo.png' onclick=\"memoRecData('" + row_indx + "');\" style='margin-left: 5px; cursor: pointer;'/>");
			}
/*			
			if(item.containsKey("n_user_id")) 
			{
				item.put("n_user_id", "<span onclick=\"fvClickChk('" + row_indx + "',this);\" style='margin-left: 5px; cursor: pointer;'>"+item.get("n_user_id").toString().trim()+"</span>");
			}			
			if(item.containsKey("n_cust_tel")) 
			{
				custTel = item.get("n_cust_tel").toString().trim();
				
				vCustTel = ComLib.getPhoneFormatHideHtml2(custTel);
								 
				item.put("n_cust_tel", "<span onclick=\"fvClickChk('" + row_indx + "',this);\" style='margin-left: 5px; cursor: pointer;'>"+vCustTel+"</span>");
			}
*/
			row_indx++;
		}
		
		json.put("totalRecords", tot_cnt);
		json.put("totalPages", page_cnt);
		json.put("curPage", cur_page);
		json.put("data", list);
		out.print(json.toJSONString());
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