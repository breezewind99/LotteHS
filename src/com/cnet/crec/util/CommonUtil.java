package com.cnet.crec.util;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.cnet.crec.common.Site;

import org.apache.log4j.Logger;

public class CommonUtil {
	private static final Logger logger = Logger.getLogger(CommonUtil.class);

	private static HttpServletRequest request;
	private static final String ENC_KEY = "!@CNET#$";									// 암호화 key
	private static final String WFM_ENC_KEY = "lotte-wfms-cipher@20160622-qwer1";		// 암호화 key

	/**
	 * request set
	 * @param request
	 * @return
	 */
	public static void setReqest(HttpServletRequest argRequest) 
	{
		request = argRequest;
	}

	/**
	 * get enc_key
	 * @return
	 */
	public static String getEncKey() 
	{
		return ENC_KEY;
	}

	/**
	 * get wfm enc_key
	 * @return
	 */
	public static String getWfmEncKey() 
	{
		return WFM_ENC_KEY;
	}

	/**
	 * 문자열이 null인 경우 대체 문자열로 리턴
	 * @param str
	 * @param rep 대체 문자열
	 * @return
	 */
	public static String ifNull(String str, String rep) 
	{
		return (str == null || "null".equals(str) || "".equals(str)) ? rep : str;
	}

	/**
	 * 문자열이 null인 경우 빈 문자열로 리턴
	 * @param str
	 * @return
	 */
	public static String ifNull(String str) 
	{
		return ifNull(str,"");
	}

	/**
	 * 빈문자열인지 아닌지를 체크
	 * @param str
	 * @return
	 */
	public static boolean hasText(String str) 
	{
 		return (str == null || str.replace(" ", "").length() == 0) ? false : true;
	}

	/**
	 * 왼쪽에서부터 substring
	 * @param str
	 * @param cnt
	 * @return
	 */
	public static String leftString(String str, int cnt)
	{
		return str.substring(0, cnt);
	}

	/**
	 * 오른쪽에서 부터 substring
	 * @param str
	 * @param cnt
	 * @return
	 */
	public static String rightString(String str, int cnt)
	{
		return str.substring(str.length()-cnt, str.length());
	}

	/**
	 * 문자열 중에 한글 갯수 리턴
	 * @param str
	 * @return
	 */
	public static int getHangulCnt(String str) 
	{
		int cnt = 0;
		for(int i=0; i<str.length(); i++) 
		{
			char c = str.charAt(i);
			if((0xAC00 <= c && c <= 0xD7A3) || (0x3131 <= c && c <= 0x318E)) 
			{
				cnt++;
			}
		}
		
		return cnt;
	}
	
	
	/**
	 * 문자열 중에 특정 문자 갯수 리턴
	 * @param str
	 * @param cr
	 * @return
	 */
	public static int getCharCnt(String str, char cr) 
	{
		int cnt = 0;
		for(int i=0; i<str.length(); i++) 
		{
			if(str.charAt(i) == cr)
			{
				cnt++;
			}
		}
		return cnt;
	}

	/**
	 * 문자열을 역순으로 리턴
	 * @param str : 문자열
	 * @return
	 */
	public static String getReverseString(String str) 
	{
		String rev_str = "";

		for(int i=str.length(); i>0; i--) 
		{
			rev_str += String.valueOf(str.charAt(i-1));
		}
		
		return rev_str;
	}

	/**
	 * 연속된 문자열 여부 확인
	 * @param str : 문자열
	 * @param cipher : 체크할 연속된 문자 숫자
	 * @return
	 */
	public static boolean checkStraightString(String str, int cipher) 
	{
		str = str.toLowerCase();

		for(int i=0; i<(str.length()-cipher+1); i++) 
		{
			int cnt = 0;
			int tmp = 0;

			// 현재 문자의 achii 값과 이전 achii 값을 뺀 값이 1이면 연속되는 문자열
			for(int j=0;j<cipher;j++) 
			{
				int ac = str.substring(i+j, i+j+1).charAt(0);

				if(j > 0 && ac-tmp == 1) 
				{
					cnt++;
				}
				tmp = ac;
			}

			// 연속되는 문자열이 cipher-1만큼 있다면 비교 기준 문자에서 지정한 자릿수만큼 연속되는 문자열로 판명
			if(cnt-cipher+1==0) 
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * URL에서 마지막 디렉토리 추출
	 * @param url : 파일 경로
	 * @return
	 */
	public static String getLastUrlDir(String url) 
	{
		if(!hasText(url))	return "";

		String[] tmparr = url.split("/");
		return tmparr[tmparr.length-2];
	}

	/**
	 * 확장자가 없는 파일명 추출
	 * @param url : 파일 경로
	 * @return
	 */
	public static String getFilenameNoExt(String url) 
	{
		if(!hasText(url))	return "";

		String[] tmparr = url.split("/");
		return leftString(tmparr[tmparr.length-1],tmparr[tmparr.length-1].lastIndexOf("."));
	}

	/**
	 * 캐릭터 인코딩
	 * @param str
	 * @param fromEnc 원본 캐릭터 셋
	 * @param toEnc 변경할 캐릭터 셋
	 * @return
	 */
	public static String getEncodeString(String str, String fromEnc, String toEnc)
	{
		try 
		{
			return new String (str.getBytes(fromEnc), toEnc);
		} 
		catch(Exception e) 
		{
			return "";
		}
	}

	/**
	 * 기본 캐릭터 인코딩
	 * @param str
	 * @return
	 */
	public static String getEncodeString(String str)
	{
		return getEncodeString(str, "8859_1", "UTF-8");
	}

	/**
	 * HTML -> Text
	 * @param str
	 * @return
	 */
	public static String toHTMLText(String str) 
	{
		return str.replace(";", "&#59;")
					.replace("'", "&apos;")
					.replace("\"", "&quot;")
					.replace("<", "&lt;")
					.replace(">", "&gt;")
					.replace("(", "&#40;")
					.replace(")", "&#41;")
					.replace("/", "&#47;");
	}

	/**
	 * Text -> HTML
	 * @param str
	 * @return
	 */
	public static String toTextHTML(String str) 
	{
		return str.replace("&#59;", ";")
					.replace("&apos;", "'")
					.replace("&quot;", "\"")
					.replace("&lt;", "<")
					.replace("&gt;", ">")
					.replace("&#40;", "(")
					.replace("&#41;", ")")
					.replace("&#47;", "/");
	}

	/**
	 * Text -> JSON
	 * @param str
	 * @return
	 */
	public static String toTextJSON(String str) 
	{
		return str.replace("&quot;", "\"")
					.replace("&lt&#59;", "&lt;")	// grid parameter
					.replace("&gt&#59;", "&gt;");	// grid parameter
	}

	/**
	 * Base64 Text -> HTML Entity
	 * @param str
	 * @return
	 */
	public static String toBase64TextHTML(String str) {
		return str.replace("&", "%26")
					.replace("+", "%2B");
	}

	/**
	 * Base64 HTML Entity -> Text
	 * @param str
	 * @return
	 */
	public static String toBase64HTMLText(String str) {
		return str.replace("%26", "&")
					.replace("%2B", "+");
	}

	/**
	 * 파라미터 가공
	 * @param str
	 * @return
	 */
	public static String getParameter(String argName) {
		return ifNull(request.getParameter(argName),"");
		//return toHTMLText(ifNull(request.getParameter(argName),""));
	}

	/**
	 * 파라미터 가공
	 * @param str, rep
	 * @return
	 */
	public static String getParameter(String argName, String rep) {
		return ifNull(request.getParameter(argName),rep);
		//return toHTMLText(ifNull(request.getParameter(argName),rep));
	}

	/**
	 * 파라미터 가공
	 * @param str
	 * @return
	 */
	public static int getParameterInt(String argName) {
		return Integer.parseInt(getParameter(argName, "0"));
	}

	/**
	 * 파라미터 가공
	 * @param str, rep
	 * @return
	 */
	public static int getParameterInt(String argName, String rep) {
		return Integer.parseInt(getParameter(argName, rep));
	}

	/**
	 * 숫자 ,로 구분
	 * @param number
	 * @return
	 */
	public static String getNumberFormat(int number){
		NumberFormat numFormat = NumberFormat.getNumberInstance();
		return numFormat.format(number);
	}

	/**
	 * 지정된 숫자를 숫자포맷 리턴 숫자포맷 (자리수 맞추기 위함) ex) 00000, 123 --> 00123
	 * @param str(지정숫자는 문자 형식으로 보낸다)
	 * @param format
	 * @return
	 */
	public static String getFormatString(String str, String format){
		double number = Double.valueOf(str);
		// 포맷 설정
		DecimalFormat df = new DecimalFormat(format) ;
		return df.format(number);
	}

	/**
	 * Random 숫자를 생성하여 리턴한다.
	 * @param format 숫자포맷 (자리수 맞추기 위함) ex) 00000
	 * @return
	 */
	public static String getRandomNumber(String format) {
		double seed = Math.pow(10, format.length());

		// random 숫자 발생
		double n = (seed * Math.random()) + 1;

		// 반올림하면서 자릿수가 늘어나는것을 막기 위해 - 1.5처리.
		n = n - 1.5;

		// 포맷 설정
		DecimalFormat df = new DecimalFormat(format) ;

		// 결과 리턴
		return df.format(n);
	}

	/**
	 * 문자열 마스킹
	 * @param str : 대상 문자열
	 * @param type : 문자열 구분 (ani=전화번호, ssn=주민번호)
	 * @return
	 */
	public static String getMaskString(String str, String type) {
		if("ani".equals(type)) {
			str = str.substring(0, str.length()-4) + "****";
		} else if("ssn".equals(type)) {
			str = str.substring(0, str.length()-6) + "******";
		}
		return str;
	}

	/**
	 * 쿠키값 가져오기
	 * @param ck_name : 쿠키 명
	 * @return
	 */
	public static String getCookieValue(String ck_name) {
		String ck_value = "";
		Cookie[] cook = request.getCookies();

		if(cook!=null){
			for(int i = 0; i < cook.length; i++){
				if(cook[i].getName().equals(ck_name)){
					ck_value = cook[i].getValue();
					break;
				}
			}
		}

		return ck_value;
	}
	
	
	/**
	 * 에러 메시지 조회 - 시트
	 * @param err_code
	 * @param msg
	 * @return
	 */
	public static String getErrorMsg(String err_code, String msg)
	{
		String err_msg = "";

		//현재 선택 언어 - CJM(20190207)
		String nowLanguage = getCookieValue("ck_template_lang");
		
		if("en_us".equals(nowLanguage))
		{
			switch(err_code) 
			{
				case "NO_SHET":		err_msg = "The sheet does not exist. [" + msg + "]";		break;
				default: 				err_msg="ERR : "+err_code;								break;
			}
		}
		else
		{
			switch(err_code) 
			{
				case "NO_SHET":		err_msg = "해당 시트가 존재하지 않습니다. [" + msg + "]";		break;
				default: 				err_msg="ERR : "+err_code;								break;
			}
		}
		
		return err_msg;
	}
	
	/**
	 * 에러 메시지 조회 - 채널
	 * @param err_code
	 * @param cnt1
	 * @param cnt2
	 * @return
	 */
	public static String getErrorMsg(String err_code, int cnt1, int cnt2) 
	{
		String err_msg = "";

		//현재 선택 언어 - CJM(20190207)
		String nowLanguage = getCookieValue("ck_template_lang");
		/*
		System.out.println("☆☆☆");
		System.out.println("nowLanguage : "+nowLanguage);
		System.out.println("☆☆☆");
		*/
		
		if("en_us".equals(nowLanguage))
		{
			switch(err_code) 
			{
				case "ERR_UP_CNT":		err_msg = "[" + cnt1 + "] of the " + cnt2 + "revisions failed.";	break;
				default: 				err_msg="ERR : "+err_code;											break;
			}
		}
		else
		{
			switch(err_code) 
			{
				case "ERR_UP_CNT":		err_msg = "업데이트 대상 [" + cnt1 + "]건 중 [" + cnt2 + "]건이 실패하였습니다.";	break;
				default: 				err_msg="ERR : "+err_code;													break;
			}
		}
		
		return err_msg;
	}

	/**
	 * 경고, 에러 메시지 조회
	 * @param err_code : 경고, 에러코드
	 * @return
	 */
	public static String getErrorMsg(String err_code) 
	{
		String err_msg = "";
		
		//현재 선택 언어 - CJM(20190207)
		String nowLanguage = getCookieValue("ck_template_lang");
		/*
		System.out.println("☆☆☆");
		System.out.println("nowLanguage : "+nowLanguage);
		System.out.println("☆☆☆");
		*/
		if("en_us".equals(nowLanguage))
		{
			switch(err_code) 
			{
				case "NO_PARAM": 		err_msg="There are no required parameters."; break;
				case "NO_LOGIN": 		err_msg="Please use after login."; break;
				case "NO_DATA": 		err_msg="The data does not exist."; break;
				case "NO_SEARCH_DATA": 	err_msg="No data matched your query criteria."; break;
				case "ERR_WRONG": 		err_msg="The wrong approach."; break;
				case "ERR_PERM": 		err_msg="You do not have permission."; break;
				case "DUP_PHONE_NUM_IP":err_msg="Duplicate extension number and IP address."; break;
				case "DUP_PHONE_NUM": 	err_msg="There are duplicate extensions."; break;
				case "DUP_PHONE_IP": 	err_msg="There is a duplicate IP."; break;
				case "EP_TIME": 		err_msg="The request time has expired."; break;
				case "ERR_FIE": 		err_msg="Failed to get recording file path."; break;
				case "NO_FIE": 			err_msg="Recording file does not exist."; break;
				case "ERR_MS": 			err_msg="Media server encountered an error."; break;
				case "ERR_REG": 		err_msg="Registration failed."; break;
				case "ERR_MOFY": 		err_msg="Modification failed."; break;
				case "ERR_DEL": 		err_msg="Delete failed."; break;
				case "ERR_SER": 		err_msg="Search failed."; break;
				case "SME_ID": 			err_msg="The same agent ID exists."; break;
				case "ERR_UNLK": 		err_msg="Unlocking failed."; break;
				case "SME_GRP": 		err_msg="The same group exists."; break;
				case "SUB_NOT_DEL": 	err_msg="Subdata exists and can not be deleted."; break;
				case "LID_NOT_ITID": 	err_msg="Login ID does not match input ID."; break;
				case "SME_PASS": 		err_msg="This is the same password as the current password."; break;
				case "NO_USR": 			err_msg="No matching users."; break;
				case "PASS_3T": 		err_msg="Your password has already been used more than 3 times."; break;
				case "PASS_USD": 		err_msg="This is the password you just used."; break;
				case "NO_CATE": 		err_msg="There is no category data."; break;
				case "EV_SHET_REG":		err_msg="Please make sure that the sheets registered in the event."; break;
				case "EV_SHET_DEL":		err_msg="You can not delete the sheets registered for the event."; break;
				case "SHET_EV":			err_msg="There is an event that uses that sheet."; break;
				case "NO_MOFY":			err_msg="Can not be modified."; break;
				case "ERR_EV_CLS":		err_msg="There is an event that failed to close."; break;
				case "EVL_APP_CLS":		err_msg="If any of the assessments under appeal are available, you will not be able to close them."; break;
				case "ERR_EV_MOFY":		err_msg="There is an event that failed to modify."; break;
				case "NOT_EVL":			err_msg="Not an evaluator."; break;
				case "NO_EV":			err_msg="No events in progress."; break;
				case "ERR_EV":			err_msg="Event data lookup failed."; break;
				case "LRG_ODR_BG":		err_msg="There is a larger rating for the current rating than the rating for the highest rating."; break;
				case "LRG_ODR_EX":		err_msg="There is currently an evaluation order equal to the evaluation maximum order."; break;
				case "CHK_EV":			err_msg="Check the rating in Event Management!"; break;
				case "ERR_REC_SER":		err_msg="Recording data lookup failed."; break;
				case "ERR_DTD_REG":		err_msg="Detailed registration failed."; break;
				case "ERR_MOFY_EVL":	err_msg="Evaluation score modification failed."; break;
				case "ARY_EVL_ODR":		err_msg="It is already Evaluation order!"; break;
				case "CHK":				err_msg="Please check."; break;
				case "ANR_EVL_PRS":		err_msg="Another evaluation is in progress."; break;
				case "TRY_AGN":			err_msg="Please try again later."; break;
				case "ARY_REG":			err_msg="It is already registered."; break;
				case "ERR": 			err_msg="An error has occurred."; break;
				case "PRO_OV": 			err_msg="The same process exists."; break;
				case "EV_ASS_INFO": 	err_msg="Assessment information exists for the event."; break;
				case "EV_EVL_INFO": 	err_msg="Events with evaluation information cannot be deleted."; break;
				case "DEL_FIE": 		err_msg="The recording file has been deleted."; break;
				default: 				err_msg="ERR : "+err_code; break;
			}
		}
		else 
		{
			switch(err_code) 
			{
				case "NO_PARAM": 		err_msg="필수 파라미터가 없습니다."; break;
				case "NO_LOGIN": 		err_msg="로그인 후 이용해 주십시요."; break;
				case "NO_DATA": 		err_msg="데이터가 존재하지 않습니다."; break;
				case "NO_SEARCH_DATA": 	err_msg="조회 조건과 일치하는 데이터가 없습니다."; break;
				case "ERR_WRONG": 		err_msg="잘못된 접근입니다."; break;
				case "ERR_PERM": 		err_msg="권한이 없습니다."; break;
				case "DUP_PHONE_NUM_IP":err_msg="내선번호와 아이피가 중복됩니다."; break;
				case "DUP_PHONE_NUM": 	err_msg="중복된 내선번호가 있습니다."; break;
				case "DUP_PHONE_IP": 	err_msg="중복된 아이피가 있습니다."; break;
				case "EP_TIME": 		err_msg="요청가능 시간이 만료되었습니다."; break;
				case "ERR_FIE": 		err_msg="녹취파일 경로를 가져 오는데 실패했습니다."; break;
				case "NO_FIE": 			err_msg="녹취파일이 존재하지 않습니다."; break;
				case "ERR_MS": 			err_msg="미디어 서버에 오류가 발생하였습니다."; break;
				case "ERR_REG": 		err_msg="등록에 실패했습니다."; break;
				case "ERR_MOFY": 		err_msg="수정에 실패했습니다."; break;
				case "ERR_DEL": 		err_msg="삭제에 실패했습니다."; break;
				case "ERR_SER": 		err_msg="조회에 실패했습니다."; break;
				case "SME_ID": 			err_msg="동일한 상담원 ID가 존재합니다."; break;
				case "ERR_UNLK": 		err_msg="잠금해제에 실패했습니다."; break;
				case "SME_GRP": 		err_msg="동일한 그룹이 존재합니다."; break;
				case "SUB_NOT_DEL": 	err_msg="하위 데이터가 존재하여 삭제 하실 수 없습니다."; break;
				case "LID_NOT_ITID": 	err_msg="로그인 아이디와 입력된 아이디가 일치하지 않습니다."; break;
				case "SME_PASS": 		err_msg="현재 비밀번호와 동일한 비밀번호 입니다."; break;
				case "NO_USR": 			err_msg="해당하는 사용자가 없습니다."; break;
				case "PASS_3T": 		err_msg="이미 3회 이상 사용한 비밀번호 입니다."; break;
				case "PASS_USD": 		err_msg="바로 직전에 사용한 비밀번호 입니다."; break;
				case "NO_CATE": 		err_msg="카테고리 데이터가 없습니다."; break;
				case "EV_SHET_REG":		err_msg="이벤트에 등록된 시트가 아닌지 확인 하세요."; break;
				case "EV_SHET_DEL":		err_msg="이벤트에 등록된 시트는 삭제 하실 수 없습니다."; break;
				case "SHET_EV":			err_msg="해당 시트를 사용하는 이벤트가 있습니다."; break;
				case "NO_MOFY":			err_msg="수정하실 수 없습니다."; break;
				case "ERR_EV_CLS":		err_msg="마감에 실패한 이벤트가 있습니다."; break;
				case "EVL_APP_CLS":		err_msg="이의 신청 중인 평가가 하나라도 있으면 마감 하실 수 없습니다."; break;
				case "ERR_EV_MOFY":		err_msg="수정에 실패한 이벤트가 있습니다."; break;
				case "NOT_EVL":			err_msg="평가자가 아닙니다."; break;
				case "NO_EV":			err_msg="진행 중인 이벤트가 없습니다."; break;
				case "ERR_EV":			err_msg="이벤트 데이터 조회에 실패했습니다."; break;
				case "LRG_ODR_BG":		err_msg="평가 최대 차수보다 현재 평가된 평가 차수가 더 큰 것이 있습니다."; break;
				case "LRG_ODR_EX":		err_msg="평가 최대 차수와 현재 동일한 평가 차수가 존재합니다."; break;
				case "CHK_EV":			err_msg="이벤트 관리에서 평가차수를  확인 하세요!"; break;
				case "ERR_REC_SER":		err_msg="녹취 데이터 조회에 실패했습니다."; break;
				case "ERR_DTD_REG":		err_msg="상세 등록에 실패했습니다."; break;
				case "ERR_MOFY_EVL":	err_msg="평가 점수 수정에 실패했습니다."; break;
				case "ARY_EVL_ODR":		err_msg="이미 평가 한 차수 입니다!"; break;
				case "CHK":				err_msg="확인 하세요."; break;
				case "ANR_EVL_PRS":		err_msg="다른 평가가 진행중입니다."; break;
				case "TRY_AGN":			err_msg="잠시후 다시 진행하시기 바랍니다."; break;
				case "ARY_REG":			err_msg="이미 등록 된 상태 입니다."; break;
				case "ERR": 			err_msg="오류가 발생하였습니다."; break;
				case "PRO_OV": 			err_msg="동일한 프로세스가 존재합니다."; break;
				case "EV_ASS_INFO": 	err_msg="해당 이벤트에 평가 정보가 존재합니다."; break;
				case "EV_EVL_INFO": 	err_msg="평가 정보가 존재하는 이벤트는 삭제 하실 수 없습니다."; break;
				case "DEL_FIE": 		err_msg="해당 녹취 파일은 삭제되었습니다."; break;
				default: 				err_msg="ERR : "+err_code; break;
			}
		}
		return err_msg;
	}

	/**
	 * javascript 소스 리턴
	 * @param msg : 메시지
	 * @param url : 리턴 url
	 * @param type : 리턴 타입
	 * @return
	 */
	public static String getPopupMsg(String msg, String url, String type) {
		StringBuffer sb = new StringBuffer();

		if("json".equals(type)) {
			sb.append(Site.getJsonResult(false, msg));
		} else {
			sb.append("<script>");
			switch(type) 
			{
				case "back": sb.append("alert('"+msg+"');"); sb.append("history.back();"); break;
				case "url": sb.append("alert('"+msg+"');"); sb.append("top.location.replace('"+url+"');"); break;
				case "close": sb.append("alert('"+msg+"');"); sb.append("self.close();"); break;
				default: sb.append("alert('"+msg+"');"); break;
			}
			sb.append("</script>");
		}
		return sb.toString();
	}

	//alert 창으로 안 띄우고 바디에 직접 메시지 뿌리기
	public static String getDocumentMsg(String msg, String url, String type) {
		StringBuffer sb = new StringBuffer();

		if("json".equals(type)) {
			sb.append(Site.getJsonResult(false, msg));
		} else {
			sb.append("<div class='ibox-content contentRadius3' style=margin:10px;padding:15px;text-align:center>"+ msg+"</div>");
		}
		return sb.toString();
	}

	/**
	 * 로그인, 메뉴 접근권한 세션 체크
	 * @param menu : 메뉴 확장자 없는 파일명
	 * @return
	 */
	public static String checkLogin(String menu, String type) {
		HttpSession session = null;

		try {
			session = request.getSession();

			// return type default
			type = ("".equals(type)) ? "url" : type;

			// 로그인 세션 체크
			if(!hasText((String) session.getAttribute("login_id")) || !hasText((String) session.getAttribute("login_level"))) 
			{
				return getPopupMsg(getErrorMsg("NO_LOGIN"),"../index.jsp",type);
			}
			// 로그인 아이피 체크
			if(!hasText((String) session.getAttribute("login_ip")) || !request.getRemoteAddr().equals((String) session.getAttribute("login_ip"))) 
			{
				return getPopupMsg(getErrorMsg("ERR_WRONG"),"../index.jsp",type);
			}
			// 메뉴권한 체크
			if(hasText(menu)) {
				boolean flag = false;
				if(session.getAttribute("menu_perm")!=null) {
					@SuppressWarnings("unchecked")
					HashMap<String,String> map = (HashMap<String,String>) session.getAttribute("menu_perm");
					if(map.containsValue(menu)) {
						flag = true;
					}
				}
				if(!flag) {
					return getPopupMsg(getErrorMsg("ERR_PERM"),"../index.jsp",type);
				}
			}
		} catch(Exception e){
			return getPopupMsg(getErrorMsg("ERR_OCCURED"),"../index.jsp",type);
		}

		return "";
	}

	/**
	 * password validator
	 * @param pwd : 비밀번호
	 * @param id : 아이디
	 * @param type : 리턴 구분
	 * @return
	 */
	public static String checkPasswd(String pwd, String id, String type) 
	{
		//현재 선택 언어 - CJM(20190207)
		String nowLanguage = getCookieValue("ck_template_lang");
		/*
		System.out.println("☆☆☆");
		System.out.println("nowLanguage : "+nowLanguage);
		System.out.println("☆☆☆");
		*/
		String plsPassMsg = "";		//비밀번호 10~30 자리 입력 메시지
		String ntPassIdMsg = "";	//비밀번호에 ID 사용불가 메시지
		String cmtnTwAprc = "";		//2가지 이상 조합 입력  메시지
		String spfcNtUsd = "";		//특정 특수문자 사용불가 메시지
		String passNtTreSm = "";	//동일 문자/숫자 3회 사용불가  메시지
		String passNtTtCsly = "";	//연속 문자/숫자 3회 사용불가  메시지
		String passNtTcsveOdr = "";	//역순 연속 문자/숫자 3회 사용불가  메시지
		
		if("en_us".equals(nowLanguage))
		{
			plsPassMsg = "Please enter your password with the 10-digit to 30 digits or less with no spaces.";
			ntPassIdMsg = "You can not use the password ID.";
			cmtnTwAprc = "Enter a combination of two or more alphanumeric characters or special characters.";
			spfcNtUsd = "Specific special characters can not be used.";
			passNtTreSm = "The password can not be used more than three times the same character/number.";
			passNtTtCsly = "Passwords can not be used more than 3 times consecutively.";
			passNtTcsveOdr = "Passwords can not be used more than 3 consecutive letters / numbers in reverse order.";
		}
		else
		{
			plsPassMsg = "비밀번호를 공백없이 10자리 이상 30자리 이하로 입력해 주십시오.";
			ntPassIdMsg = "비밀번호에 아이디를 사용할 수 없습니다.";
			cmtnTwAprc = "비밀번호를 영문/숫자/특수문자 중 2가지 이상을 조합하여 입력해 주십시오.";
			spfcNtUsd = "특정 특수문자는 사용하실 수 없습니다.";
			passNtTreSm = "비밀번호는 동일 문자/숫자를 3회 이상 사용하실 수 없습니다.";
			passNtTtCsly = "비밀번호는 연속된 문자/숫자를 3회 이상 사용하실 수 없습니다.";
			passNtTcsveOdr = "비밀번호는 역순으로 연속된 문자/숫자를 3회 이상 사용하실 수 없습니다.";
		}
		
		// 공백 체크
		Pattern sc_p = Pattern.compile("[\\s]");
		Matcher sc_m = sc_p.matcher(pwd);

		if(pwd.length()<10 || pwd.length()>30 || sc_m.find()) 
		{
			return getPopupMsg(plsPassMsg, "", type);
		}
		if(pwd.indexOf(id)>-1) 
		{
			return getPopupMsg(ntPassIdMsg, "", type);
		}

		// 영문/숫자/특수문자 중 2가지 이상 조합
		int cb_cnt = 0;
		Pattern en_p = Pattern.compile("[a-zA-Z]");
		Matcher en_m = en_p.matcher(pwd);
		Pattern num_p = Pattern.compile("[0-9]");
		Matcher num_m = num_p.matcher(pwd);
		// {}[]/?.,;:|)*~`!^-_+<>@#$%&\=(
		//Pattern sp_p = Pattern.compile("[\\{\\}\\[\\]\\/?.,;:|\\)*~`!^\\-_+<>@\\#$%&\\\\\\=\\(]");
		Pattern sp_p = Pattern.compile("[\\{\\}\\[\\]\\/?.,|\\)*~`!^\\-_+@\\#$&\\\\\\(]");
		Matcher sp_m = sp_p.matcher(pwd);

		if(en_m.find()) cb_cnt++;
		if(num_m.find()) cb_cnt++;
		if(sp_m.find()) cb_cnt++;

		if(cb_cnt<2) 
		{
			return getPopupMsg(cmtnTwAprc, "", type);
		}

		// 특정특수문자 사용금지
		Pattern no_sp_p = Pattern.compile("[\"';:<>%\\=]");
		Matcher no_sp_m = no_sp_p.matcher(pwd);

		if(no_sp_m.find()) 
		{
			return getPopupMsg(spfcNtUsd+" [ \" % ' : ; < = > ]", "", type);
		}

		// 동일문자 3회 이상 사용 금지
		Pattern eq_p = Pattern.compile("(\\w)\\1{2}");
		Matcher eq_m = eq_p.matcher(pwd);

		if(eq_m.find()) 
		{
			return getPopupMsg(passNtTreSm, "", type);
		}

		// 연속된 문자/숫자 사용금지
		if(checkStraightString(pwd, 3)) {
			return getPopupMsg(passNtTtCsly, "", type);
		}
		if(checkStraightString(getReverseString(pwd), 3)) {
			return getPopupMsg(passNtTcsveOdr, "", type);
		}

		return "";
	}

	/**
	 * tbl_record 테이블 명 리턴
	 * @param rec_date : 녹취일자
	 * @return
	 */
	public static String getRecordTableNm(String rec_date) {

		int yser = Integer.parseInt(rec_date.substring(0, 4));

		if ( yser >= 2016){
			return "";
		} else {
			return "_before";
		}


		//return ("2016".equals(rec_date.substring(0, 4))) ? "" : "_before";
	}
	
	/**
	 * EXE 실행
	 */
	public static void getRunTimeExec() 
	{
		Runtime rt = Runtime.getRuntime();
		Process p;
		String directory = null;
		//directory = "C://Windows//SysWOW64//notepad.exe";
		directory = "D:\\www\\Setup\\CRecMon.exe";
		try 
		{
			//Runtime.getRuntime().exec("d:\\www\\Setup\\CRecMon.exe");
			//Runtime.getRuntime().exec("http://192.168.0.21/Setup/ezRen107.exe");
			//logger.info("getRunTimeExec START~~");
			//Runtime.getRuntime().exec("D:\\www\\Setup\\CRecMon.exe");
			//Runtime.getRuntime().exec("c:\\Windows\\SysWOW64\\notepad.exe");
			
			/*
	        String fileName = "c:\\Windows\\SysWOW64\\notepad.exe";
	        String[] commands = {"cmd", "/c", "start", "\"DummyTitle\"",fileName};
	        Process p = Runtime.getRuntime().exec(commands);
	        p.waitFor();
	        */
			p = rt.exec(directory);
			//p.waitFor();
			
			int exitValue = p.waitFor();
			
			//logger.info("exitValue : "+exitValue);
			
			//logger.info("p : "+p.getErrorStream());
	       //logger.info("getRunTimeExec END~~");
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
	}
	
	/**
	 * IP 정보
	 * @param request
	 * @return
	 */
	public static String getClientIP(HttpServletRequest request) 
	{
		String ip = request.getHeader("X-Forwarded-For");
		logger.info("> X-FORWARDED-FOR : " + ip);

		if(ip == null) 
		{
	    	ip = request.getHeader("Proxy-Client-IP");
	    	logger.info("> Proxy-Client-IP : " + ip);
		}
		if(ip == null) 
		{
			ip = request.getHeader("WL-Proxy-Client-IP");
			logger.info(">  WL-Proxy-Client-IP : " + ip);
		}
		if(ip == null) 
		{
			ip = request.getHeader("HTTP_CLIENT_IP");
			logger.info("> HTTP_CLIENT_IP : " + ip);
		}
		if(ip == null) 
		{
			ip = request.getHeader("HTTP_X_FORWARDED_FOR");
			logger.info("> HTTP_X_FORWARDED_FOR : " + ip);
		}
		if(ip == null) 
	    {
			ip = request.getRemoteAddr();
			logger.info("> getRemoteAddr : "+ip);
	    }
		logger.info("> Result : IP Address : "+ip);

		return ip;
	}
}
