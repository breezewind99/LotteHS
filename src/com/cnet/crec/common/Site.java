package com.cnet.crec.common;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspWriter;

import org.apache.ibatis.session.SqlSession;

import com.cnet.crec.util.CommonUtil;
import com.cnet.crec.util.DateUtil;

/**
 * 현재사이트에서만 사용되는 공통모듈
 * @author Administrator
 *
 */
public class Site 
{
	
	/**
	 * 현재 권한코드별 볼 수 있는 조직 Depth 리턴
	 * @param userLevel
	 * @return
	 */
	public static int getDepthByUserLevel(Object userLevel) 
	{
		return 	(userLevel.equals("0")) ? 9 : //시스템 관리자
				(userLevel.equals("A")) ? 3 : //관리자	: 대분류 전체
				(userLevel.equals("B")) ? 2 : //센터장 	: 중분류 전체
				(userLevel.equals("C")) ? 1 : //팀장 	: 소분류 전체
				(userLevel.equals("D")) ? 0 : //조장		: 소분류 하나 : 자신이 속한 소분류만
				-1;							  //상담원	: 소분류 하나 : 자신이 속한 소분류만
	}

	/**
	 * 평가자 여부
	 * @param request
	 * @return
	 */
	public static boolean isEvaluator(HttpServletRequest request) {
		return ComLib.getSessionValue(request, "eval_yn").equals("y");
	}

	/**
	 * S : 이벤트 콤보박스
	 * @param event_status
	 * @return
	 * @throws Exception
	 */
	public static String getEventComboHtml(String event_status) throws Exception 
	{
		return getEventComboSelHtml(event_status, "", null);
	}
	
	/**
	 * getEventComboHtml
	 * @param event_status
	 * @param addValName
	 * @return
	 * @throws Exception
	 */
	public static String getEventComboHtml(String event_status, String addValName) throws Exception 
	{
		return getEventComboSelHtml(event_status, addValName, null);
	}
	
	/**
	 * getEventComboSelHtml
	 * @param event_status
	 * @param selValue
	 * @return
	 * @throws Exception
	 */
	public static String getEventComboSelHtml(String event_status, String selValue) throws Exception 
	{
		return getEventComboSelHtml(event_status, "", selValue);
	}
	
	/**
	 * 이벤트 콤보박스
	 * @param event_status
	 * @param addValName
	 * @param selValue
	 * @return
	 * @throws Exception
	 */
	public static String getEventComboSelHtml(String event_status, String addValName, String selValue) throws Exception 
	{
		Db db = null;
		String htmResult = "";
		try 
		{
			db = new Db(true);
			Map<String, String> argMap = new HashMap<String, String>();
			argMap.put("event_status", event_status);
			if(event_status.equals("2"))
			{
				//진행중인 경우 이벤트 유효기간 까지 비교
				//argMap.put("event_date", DateUtil.getToday("yyyyMMdd")); 마감 제거 - CJM(20180509)
			}
			List<Map<String, Object>> list = db.selectList("event.selectCodeList", argMap);
			String optVal = "";
			for(Map<String, Object> item : list) 
			{
				optVal = (addValName.equals("")) ? item.get("event_code").toString() : item.get("event_code") + "/" + ComLib.toNN(item.get(addValName));
				htmResult += "<option value='"+optVal+"' "+((item.get("event_code").equals(selValue)) ? "selected" : "")+">"+item.get("event_name")+"</option>";
			}

		} 
		catch(Exception e) 
		{
			htmResult = e.toString();
			System.out.println(htmResult);
		} 
		finally 
		{
			if(db != null) db.close();
		}
		return htmResult;
	}

	/**
	 * 평가자 콤보박스
	 * @param sess
	 * @param isAll
	 * @return
	 * @throws Exception
	 */
	public static String getEvaluatorComboHtml(HttpSession sess, boolean isAll) throws Exception 
	{
		Db db = null;
		String htmResult = "";
		try 
		{
			db = new Db(true);
			Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("business_code", sess.getAttribute("login_business_code"));
			argMap.put("_user_id", sess.getAttribute("login_id"));
			argMap.put("_login_level", sess.getAttribute("login_level"));
			argMap.put("_bpart_code", sess.getAttribute("login_bpart"));
			argMap.put("_mpart_code", sess.getAttribute("login_mpart"));
			argMap.put("_spart_code", sess.getAttribute("login_spart"));
			if(!isAll)	argMap.put("user_only", "Y");
			
			List<Map<String, Object>> list = db.selectList("user.selectEvalListCombo", argMap);
	
			if(list != null) 
			{
				for(Map<String, Object> item : list) 
				{
					htmResult += "<option value='"+item.get("user_id")+"'>"+item.get("user_name")+"</option>";
				}
			}
		} 
		catch(Exception e) 
		{
			htmResult = e.toString();
			System.out.println(htmResult);
		} 
		finally 
		{
			if(db != null) db.close();
		}
		
		return htmResult;
	}

	/**
	 * 내 조직도 콤보박스 (맨처음 호출됨)
	 * @param sess
	 * @param part_depth
	 * @return
	 * @throws Exception
	 */
	public static String getMyPartCodeComboHtml(HttpSession sess, int part_depth) throws Exception
	{
		//현재 선택 언어 - CJM(20190207)
		String nowLanguage = CommonUtil.getCookieValue("ck_template_lang");
		/*
		System.out.println("☆☆☆");
		System.out.println("getMyPartCodeComboHtml nowLanguage : "+nowLanguage);
		System.out.println("☆☆☆");
		*/
		String bPart = "대분류";
		String mPart = "중분류";
		String sPart = "소분류";
		
		if("en_us".equals(nowLanguage))
		{
			bPart = "Big part";
			mPart = "Middle part";
			sPart = "Small part";
		}
		else
		{
			bPart = "대분류";
			mPart = "중분류";
			sPart = "소분류";
		}
		
		int depthByUserLevel = getDepthByUserLevel(sess.getAttribute("login_level"));
		
		if(part_depth == 2 && depthByUserLevel >= 3) 
		{
			return "<option value=''>"+mPart+"</option>";
		}
		else if(part_depth == 3 && depthByUserLevel >= 2) 
		{
			return "<option value=''>"+sPart+"</option>";
		}
		
		/*
		System.out.println("bPart : "+bPart);
		System.out.println("mPart : "+mPart);
		System.out.println("sPart : "+sPart);
		*/
		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("_user_level", sess.getAttribute("login_level"));
		argMap.put("business_code", sess.getAttribute("login_business_code"));
		argMap.put("bpart_code", sess.getAttribute("login_bpart"));
		argMap.put("mpart_code", sess.getAttribute("login_mpart"));
		argMap.put("spart_code", sess.getAttribute("login_spart"));
		argMap.put("part_depth", part_depth);
		argMap.put("use_yn", "1");
		argMap.put("firstStr", ((part_depth == 1) ? bPart : (part_depth==2) ? mPart : sPart));
		return getPartCodeComboHtml(argMap,"user_group.selectPartCode");
	}

	/**
	 * 내 조직도 콤보박스 (맨처음 호출됨)
	 * @param sess
	 * @param part_depth
	 * @return
	 * @throws Exception
	 */
	public static String getWorkCodeComboHtml(HttpSession sess, int part_depth) throws Exception
	{
		//현재 선택 언어 - CJM(20190207)
		String nowLanguage = CommonUtil.getCookieValue("ck_template_lang");
		/*
		System.out.println("☆☆☆");
		System.out.println("getMyPartCodeComboHtml nowLanguage : "+nowLanguage);
		System.out.println("☆☆☆");
		*/
		String bPart = "대분류";
		String mPart = "중분류";
		String sPart = "소분류";

		if("en_us".equals(nowLanguage))
		{
			bPart = "Big part";
			mPart = "Middle part";
			sPart = "Small part";
		}
		else
		{
			bPart = "대분류";
			mPart = "중분류";
			sPart = "소분류";
		}

		Map<String, Object> argMap = new HashMap<String, Object>();
		argMap.put("_user_level", sess.getAttribute("login_level"));
		argMap.put("business_code", sess.getAttribute("login_business_code"));
		argMap.put("bpart_code", sess.getAttribute("login_bpart"));
		argMap.put("mpart_code", sess.getAttribute("login_mpart"));
		argMap.put("spart_code", sess.getAttribute("login_spart"));
		argMap.put("part_depth", part_depth);
		argMap.put("use_yn", "1");
		argMap.put("firstStr", ((part_depth == 1) ? bPart : (part_depth==2) ? mPart : sPart));
		return getPartCodeComboHtml(argMap,"work_group.selectPartCode");
	}
	
	/**
	 * 조직도 콤보박스
	 * @param m
	 * @return
	 * @throws Exception
	 */
	public static String getPartCodeComboHtml(Map<String, Object> m, String queryId) throws Exception
	{
		Db db = null;
		String htmResult = "";
		try 
		{
			db = new Db(true);
			List<Map<String, Object>> list = db.selectList(queryId, m);

			if(list != null) 
			{
				String selected = "";
				for(Map<String, Object> item : list) 
				{
					selected = (item.get("part_code").equals(m.get("selVal"))) ? "selected" : "";
					htmResult += "<option value='"+item.get("part_code")+"' "+selected+">"+item.get("part_name")+"</option>";
				}
			}
			if(list.size() > 1 && m.get("firstStr") != null) 
			{
				String selected = (ComLib.toNN(m.get("selVal")).equals("")) ? "selected" : "";
				htmResult = "<option value='' "+selected+">"+m.get("firstStr")+"</option>"+htmResult;
			}
		} 
		catch(Exception e) 
		{
			htmResult = e.toString();
			System.out.println(htmResult);
		} 
		finally 
		{
			if(db != null)	db.close();
		}
		
		return htmResult;
	}

	/**
	 * 시트 목록 조회
	 */
	public static String getSheetComboHtml(Map<String, Object> m) throws Exception
	{
		Db db = null;
		String htmResult = "";
		try 
		{
			db = new Db(true);
			List<Map<String, Object>> list = db.selectList("sheet.selectCodeList", m);

			if(list != null) 
			{
				String selected = "";
				for(Map<String, Object> item : list) 
				{
					selected = (item.get("sheet_code").equals(m.get("selVal"))) ? "selected" : "";
					htmResult += "<option value='"+item.get("sheet_code")+"' "+selected+">"+item.get("sheet_name")+"</option>";
				}
			}
			if(list.size()>1 && m.get("firstStr") != null) 
			{
				String selected = (ComLib.toNN(m.get("selVal")).equals("")) ? "selected" : "";
				htmResult = "<option value='' "+selected+">"+m.get("firstStr")+"</option>"+htmResult;
			}
		} 
		catch(Exception e) 
		{
			htmResult = e.toString();
			System.out.println(htmResult);
		} 
		finally 
		{
			if(db != null)	db.close();
		}
		
		return htmResult;
	}
	
	/**
	 * 시트 목록 조회
	 * @param m
	 * @return
	 * @throws Exception
	 */
	public static String getYearComboHtml(Map<String, Object> m) throws Exception
	{
		Db db = null;
		String htmResult = "";
		try 
		{
			db = new Db(true);
			List<Map<String, Object>> list = db.selectList("code.selectYearList", m);

			if(list != null) 
			{
				String selected = "";
				for(Map<String, Object> item : list) 
				{
					selected = (item.get("selected").equals("s")) ? "selected" : "";
					htmResult += "<option value='"+item.get("year_code")+"' "+selected+">"+item.get("year_name")+"</option>";
				}
			}
			if(list.size() > 1 && m.get("firstStr") != null) 
			{
				String selected = (ComLib.toNN(m.get("selVal")).equals("")) ? "selected" : "";
				htmResult = "<option value='' "+selected+">"+m.get("firstStr")+"</option>"+htmResult;
			}
		} 
		catch(Exception e) 
		{
			htmResult = e.toString();
			System.out.println(htmResult);
		} 
		finally 
		{
			if(db != null)	db.close();
		}
		return htmResult;
	}

	/**
	 * 성공 실패 Json 메시지
	 * @param out
	 * @param isSuccess
	 * @throws Exception
	 */
	public static void writeJsonResult(JspWriter out, boolean isSuccess) throws Exception 
	{
		out.println(getJsonResult(isSuccess,""));
	}
	
	/**
	 * writeJsonResult
	 * @param out
	 * @param e
	 * @throws Exception
	 */
	public static void writeJsonResult(JspWriter out, Exception e) throws Exception 
	{
		String errMsg = ComLib.cvtToAjaxAlertValue(e.getMessage());
		out.println(getJsonResult(false,errMsg));
	}
	
	/**
	 * writeJsonResult
	 * @param out
	 * @param isSuccess
	 * @param msg
	 * @throws Exception
	 */
	public static void writeJsonResult(JspWriter out, boolean isSuccess, Object msg) throws Exception 
	{
		out.println(getJsonResult(isSuccess,msg));
	}
	
	/**
	 * getJsonResult
	 * @param isSuccess
	 * @param msg
	 * @return
	 */
	public static String getJsonResult(boolean isSuccess, Object msg) 
	{
		String code = (isSuccess) ? "OK" : "ERR";
		return "{\"code\":\""+code+"\", \"msg\":\""+ComLib.toNN(msg)+"\"}";
	}
	
	/**
	 * dbClose
	 * @param args
	 * @throws Exception
	 */
	public static void dbClose(Object ... args) throws Exception
	{
		for(Object arg : args)
		{
			if(arg == null){}
			else if(arg instanceof SqlSession)
			{
				SqlSession ssn = (SqlSession) arg;
				ssn.commit();
				ssn.close();
			}
			else if(arg instanceof Connection)
			{
				Connection con = (Connection) arg;
				con.setAutoCommit(true);
				con.commit();
				con.close();
			}
			else if(arg instanceof PreparedStatement)	
			{
				((PreparedStatement)arg).close();
			}
			else if(arg instanceof CallableStatement)	
			{
				((CallableStatement)arg).close();
			}
			else if(arg instanceof ResultSet)
			{
				((ResultSet)arg).close();
			}
		}
	}
	
	/**
	 * 권한체크
	 * @param out
	 * @param menuName
	 * @return
	 * @throws Exception
	 */
	public static boolean isPmss(JspWriter out, String menuName) throws Exception
	{
		return isPmss(out, menuName, "");
	}
	
	/**
	 * isPmss
	 * @param out
	 * @param menuName
	 * @param type
	 * @return
	 * @throws Exception
	 */
	public static boolean isPmss(JspWriter out, String menuName, String type) throws Exception
	{
		String _check_login = CommonUtil.checkLogin(menuName,type);
		if(CommonUtil.hasText(_check_login)) 
		{
			out.print(_check_login);
			return false;
		}
		return true;
	}
	
	/**
	 * 엑셀 헤더
	 * @param response
	 * @param out
	 * @param fileName
	 * @throws Exception
	 */
	public static void setExcelHeader(HttpServletResponse response, JspWriter out, String fileName) throws Exception
	{
		response.reset();
		response.setHeader("Content-type","application/vnd.ms-excel; charset=euc_kr");
		response.setHeader("Content-Description","Generated By CNetTechnology");
		response.setHeader("Content-Disposition","attachment; filename = " + java.net.URLEncoder.encode(fileName+"_"+DateUtil.getToday("yyyy-MM-dd")+""+".xls", "UTF-8"));
		out.println(
			"<meta http-equiv='Content-Type' content='application/vnd.ms-excel;charset=euc-kr'>"+
			"<style>"+
				"body, td, th, div {font-size:12px}"+
				".th {background-color:#DCE4E9;font-weight:lighter}"+
				".subSum {background-color:#EEEEEE;text-align:right}"+
				".sum {background-color:#DDDDDD;text-align:right}"+
				".l {text-align:left}"+
				".r {text-align:right}"+
				".c {text-align:center}"+
			"</style>"
		);
	}
	
	/**
	 * 상담원 콤보박스 - CJM(20180430)
	 * @param sess
	 * @param isAll
	 * @return
	 * @throws Exception
	 */
	public static String getCounselorComboHtml(HttpSession sess, boolean isAll) throws Exception 
	{
		Db db = null;
		String htmResult = "";
		try {
			db = new Db(true);
			Map<String, Object> argMap = new HashMap<String, Object>();
			argMap.put("eval_user_id", sess.getAttribute("login_id"));

			List<Map<String, Object>> list = db.selectList("event.selectCounselorList", argMap);
	
			if(list != null) 
			{
				for(Map<String, Object> item : list) 
				{
					htmResult += "<option value='"+item.get("user_id")+"'>"+item.get("user_id")+"<font color=gray> > </font>"+item.get("user_name")+"</option>";
				}
			}
		} 
		catch(Exception e) 
		{
			htmResult = e.toString();
			System.out.println(htmResult);
		} 
		finally 
		{
			if(db != null)	db.close();
		}
		
		return htmResult;
	}
	
	/**
	 * 공통코드 콤보 박스 조회
	 * @param type j : json, h1 : html 1 형식
	 * @param code
	 * @return
	 * @throws Exception
	 */
	public static String getCommComboHtml(String type, Map<String, Object> map) throws Exception 
	{
		Db db = null;
		String htmResult = "";
		try 
		{
			//현재 선택 언어 - CJM(20190326)
			String nowLanguage = CommonUtil.getCookieValue("ck_template_lang");
			/*
			System.out.println("☆☆☆");
			System.out.println("getCommComboHtml nowLanguage : "+nowLanguage);
			System.out.println("☆☆☆");
			*/
			db = new Db(true);
			Map<String, Object> argMap = new HashMap<String, Object>();
			
			/* 
			 * system 	: 시스템 
			 * code 	: 공통 코드
			 * business : 업무 코드
			 * genesys	: CTI 정보 
			 * nesry	: 필수유무(Y-D, N)
			 * j		: jQuery
			 * h1		: HTML
			 * */
			
			List<Map<String, Object>> list = null;
			
			String codeVal = "comm_code";
			String codeNm = "code_name";
			String codeNmEn = "code_name_en";
			
			if("system".equals(map.get("tb_nm").toString())) 
			{
				argMap.put("system_rec", map.get("system_rec"));

				codeVal = "system_code";
				codeNm = "system_name";
				codeNmEn = "system_name_en";
				
				list = db.selectList("system.selectCodeList", argMap);
			}
			else if("code".equals(map.get("tb_nm").toString())) 
			{
				argMap.put("_parent_code", map.get("_parent_code"));
				
				codeVal = "comm_code";
				codeNm = "code_name";
				codeNmEn = "code_name_en";
				
				list = db.selectList("code.selectCodeList", argMap);
			}
			else if("business".equals(map.get("tb_nm").toString())) 
			{
				//argMap.put("_parent_code", map.get("_parent_code"));
				
				codeVal = "business_code";
				codeNm = "business_name";
				codeNmEn = "business_name_en";
				
				list = db.selectList("business.selectList", argMap);
			}
			else if("genesys".equals(map.get("tb_nm").toString())) 
			{
				argMap.put("system_code", map.get("system_code"));
				
				codeVal = "number";
				codeNm = "tenant_num";
				codeNmEn = "tenant_num";
				
				list = db.selectList("cti.selectCtiCdList", argMap);
			}
	
			if(list != null) 
			{
				if("N".equals(map.get("nesry")) && "j".equals(type))		htmResult += ",{'':''}";
				
				for(Map<String, Object> item : list) 
				{
					if("j".equals(type))
					{
						htmResult += ",{'" + item.get(""+codeVal+"") + "':'" + (("en_us".equals(nowLanguage)) ? item.get(""+codeNmEn+"").toString() : item.get(""+codeNm+"").toString()) + "'}";
					}
					else if("h1".equals(type))
					{
						htmResult += "<option value='"+item.get(""+codeVal+"")+"'>"+ (("en_us".equals(nowLanguage)) ? item.get(""+codeNmEn+"") : item.get(""+codeNm+""))+"</option>";
					}
					else
					{
						htmResult += "<option value='"+item.get(""+codeVal+"")+"'>"+item.get(""+codeVal+"")+"<font color=gray> > </font>"+ (("en_us".equals(nowLanguage)) ? item.get(""+codeNmEn+"") : item.get(""+codeNm+""))+"</option>";
					}
				}
				
				if("j".equals(type))	htmResult = htmResult.substring(1);
			}
		} 
		catch(Exception e) 
		{
			htmResult = e.toString();
			System.out.println(htmResult);
		} 
		finally 
		{
			if(db != null)	db.close();
		}
		
		return htmResult;
	}	
	
}
