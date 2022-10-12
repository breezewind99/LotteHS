<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ include file="/common/function.jsp" %>
<%
	if(!Site.isPmss(out,"user_mgmt","json")) return;

	Db db = null;

	try 
	{
		db = new Db(true);

		// get parameter
		String part_code = CommonUtil.getParameter("part_code");
		String user_id = CommonUtil.getParameter("user_id", "");
		String user_name = CommonUtil.getParameter("user_name", "");
		String local_no = CommonUtil.getParameter("local_no", "");
		int cur_page = CommonUtil.getParameterInt("cur_page", "1");
		int top_cnt = CommonUtil.getParameterInt("top_cnt", "20");
		String sort_idx = CommonUtil.getParameter("sort_idx", "regi_datm");
		String sort_dir = CommonUtil.getParameter("sort_dir", "down");

		cur_page = (cur_page < 1) ? 1 : cur_page;

		sort_idx = OrderBy(sort_idx,"user_id,user_pass,user_name,local_no,system_code,user_level,eval_yn,rec_down_yn,pass_chg_term,pass_expire_date,pass_upd_date,user_ip,resign_yn,use_yn,regi_datm");
		sort_dir = ("down".equals(sort_dir)) ? "desc" : "asc";

		//paging 변수
		int tot_cnt = 0;
		int page_cnt = 0;
		int start_cnt = 0;
		int end_cnt = 0;

		// part_code
		String business_code = "";
		String bpart_code = "";
		String mpart_code = "";
		String spart_code = "";

		if(CommonUtil.hasText(part_code)) 
		{

//			business_code = CommonUtil.leftString(part_code, 2);
//			//bpart_code = part_code.substring(2, 7);
//			//mpart_code = part_code.substring(7, 12);
//			//spart_code = part_code.substring(12, 17);
//			bpart_code = part_code.substring(2, 2+(_PART_CODE_SIZE*1));
//			mpart_code = part_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2));
//			spart_code = part_code.substring(2+(_PART_CODE_SIZE*2), 2+(_PART_CODE_SIZE*3));

			String[] temp = part_code.split("_");
			business_code = temp[0];
			bpart_code = temp[1];
			mpart_code = temp[2];
			spart_code = temp[3];
		}

		JSONObject json = new JSONObject();

		Map<String, Object> argMap = new HashMap<String, Object>();

		argMap.put("top_cnt", top_cnt);
		argMap.put("business_code", business_code);
		argMap.put("bpart_code", bpart_code);
		argMap.put("mpart_code", mpart_code);
		argMap.put("spart_code", spart_code);
		argMap.put("user_id", user_id);
		argMap.put("user_name", user_name);
		argMap.put("local_no", local_no);

		// count
		Map<String, Object> cntmap  = db.selectOne("user.selectCount", argMap);

		//oracle 오류 발생하여 수정 - CJM(20190521)
		tot_cnt = Integer.valueOf(cntmap.get("tot_cnt").toString()).intValue();
		//tot_cnt = Integer.parseInt(cntmap.get("tot_cnt").toString());
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

		List<Map<String, Object>> list = db.selectList("user.selectList", argMap);

		json.put("totalRecords", tot_cnt);
		json.put("totalPages", page_cnt);
		json.put("curPage", cur_page);
		json.put("data", list);
		out.print(json.toJSONString());
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db != null)	db.close();
	}
%>