<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="javax.servlet.http.Cookie"%>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@ page import="com.cnet.crec.util.SessionListener"%>
<%@ page import="com.cnet.crec.util.RSA"%>
<%@ page import="java.security.PrivateKey"%>
<%
	// DB Connection Object
	Db db = null;

	try 
	{
		String login_id = CommonUtil.getParameter("login_id", "");
		String login_pass = CommonUtil.getParameter("login_pass");
		
		PrivateKey pKey = (PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__");

		/*
			RSA key 체크
			session 무효화 현상 발생으로 처리 - CJM(20191112)

		if(pKey == null) 
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("ERR_WRONG"),"../index.jsp","url"));
			return;
		}
		*/
		
		//로그인 아이디 대소문자 구분없이 DB에서 조회 된다. (모두 대문자로 변경)
		//login_id = RSA.decryptRsa(pKey, login_id).toUpperCase();
		login_id = RSA.decryptRsa(pKey, login_id);
		login_pass = RSA.decryptRsa(pKey, login_pass);

		String id_save = CommonUtil.getParameter("id_save", "");
		String login_ip = request.getRemoteAddr();

		//파라미터 체크
		if(!CommonUtil.hasText(login_id) || !CommonUtil.hasText(login_pass)) 
		{
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// DB Connection
		db = new Db(true);

		Map<String, Object> argMap = new HashMap<String, Object>();

		/*
			1. 아이디 존재 유무 체크
		*/
		int idUse = db.selectOne("login.selectIdCheck", login_id);
		if(idUse == 0) 
		{
			Site.writeJsonResult(out, false, "해당 아이디가 존재하지 않아 로그인 할 수 없습니다.");
			return;
		}

		/*
			2. 아이디  잠금 여부 체크 및 아이디 잠금 처리( 금일 5회 이상 로그인 실패시)
		*/
		int lockCnt = db.selectOne("login.selectLockCheck", login_id);
		if(lockCnt > 0) 
		{
			// lock_yn='1' 업데이트
			argMap.put("user_id", login_id);
			argMap.put("lock_yn", "1");
			db.update("user.updateUser", argMap);
			
			Site.writeJsonResult(out, false, "해당 아이디는 잠금 처리되어 로그인 할 수 없습니다.");
			return;
		}

		// 비밀번호 암호화
		CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());
		String enc_login_pass = sha256.Encrypt(login_pass);

		/*
			3. 로그인 결과 신규 등록 (금일)
		*/
		int rslt_cnt = db.selectOne("login.selectCountLoginResult", login_id);
		if(rslt_cnt < 1) 
		{
			db.insert("login.insertLoginResult", login_id);
		}

		argMap.put("login_id", login_id);
		argMap.put("login_name", "");
		argMap.put("login_pass", enc_login_pass);
		argMap.put("login_ip", login_ip);
		argMap.put("login_type", "I");
		argMap.put("login_result", "");
		
		/*
			4. 아이디. 비밀번호 체크 및 사용자 정보 조회
		*/
		Map<String, Object> data  = db.selectOne("login.selectLoginUser", argMap);
		
		int passCheckDay = 0;
		
		if(data == null) 
		{
			/*
				5. 로그인 결과 업데이트(실패)
			*/
			argMap.put("login_result", "0");
			db.update("login.updateLoginResult", argMap);

			/*
				6. 로그인 이력 등록(실패)
			*/
			db.insert("hist_login.insertLoginHist", argMap);

			//Site.writeJsonResult(out, false, "로그인에 실패했습니다.");
			Site.writeJsonResult(out, false, "사용자 정보를 확인할수 없어 로그인 하실 수 없습니다.");
			return;
		}
		else
		{
			//상담원 수정 기본 정보 - CJM(20190516)
			argMap.put("user_ip", data.get("user_ip"));
			argMap.put("upd_id", login_id);
			argMap.put("upd_ip", login_ip);

			/*
				7. 아이디 잠금 여부 체크(금일 이전에 잠금 처리 되었을 경우)
			*/
			lockCnt = Integer.parseInt(data.get("lock_yn").toString());
			if(lockCnt > 0) 
			{
				Site.writeJsonResult(out, false, "해당 아이디는 잠금 처리되어 로그인 하실 수 없습니다.");
				return;
			}

			/*
				8. 퇴사 여부 체크
			*/
			int resignCnt = Integer.parseInt(data.get("resign_yn").toString());
			if(resignCnt > 0) 
			{
				Site.writeJsonResult(out, false, "해당 아이디는 퇴사 처리되어 로그인 할 수 없습니다.");
				return;
			}

			/*
				9. 사용 여부 체크
			*/
			int useCnt = Integer.parseInt(data.get("use_yn").toString());
			if(useCnt != 1) 
			{
				Site.writeJsonResult(out, false, "해당 아이디는 미사용 처리되어 로그인 할 수 없습니다.");
				return;
			}
			
			/*
				10. 장기 미접속 잠금 체크
			*/
			int loginChk = Integer.parseInt(data.get("login_check_day").toString());
			if(_LOGIN_CHECK_TERM < loginChk) 
			{
				// 잠금처리 (lock_yn : 1) 
				argMap.put("user_id", login_id);
				argMap.put("lock_yn", "1");
				db.update("user.updateUser", argMap);

				Site.writeJsonResult(out, false, "장기간 로그인하지 않아 잠금 처리되었습니다.");
				return;
			}

			/*
				11. 비밀번호 변경 이력 확인(없을 경우)
			*/
			//oracle 사용자 정보 없을 경우 null 체크 - CJM(20190823)
			//String pass_upd_date = data.get("pass_upd_date").toString();
			String passUpdDate = CommonUtil.ifNull(data.get("pass_upd_date")+"");
			if(!CommonUtil.hasText(passUpdDate))
			{
				out.print("{\"code\":\"PASS\", \"msg\":\"최초 로그인하시는 경우 비밀번호 변경 후 로그인이 가능합니다.\"}");
				return;
			}

			/*
				12. 비밀번호 만료
			*/
			passCheckDay = Integer.parseInt(data.get("pass_check_day").toString());
			if(passCheckDay < 0) 
			{
				out.print("{\"code\":\"PASS\", \"msg\":\"비밀번호 사용일이 만료되었습니다.\"}");
				return;
			}
		}
		
		/*
			13. 로그인 Session  정보 생성
		*/
		//로그인 성공 전 세션 ID 정보 업데이트 - CJM(20190730)
		session.invalidate(); 
		session = request.getSession();
		session.setAttribute("__rsaPrivateKey__", pKey);
		
		//session.setAttribute("login_id", login_id.toLowerCase());
		//평가 등록시 공백이 발생하여 삭제시 로그인 아이디 정보가 불일치 현상 발생 - CJM(20181029)
		session.setAttribute("login_id", login_id.trim());
		session.setAttribute("login_name", data.get("user_name"));
		session.setAttribute("login_level", data.get("user_level"));
		session.setAttribute("login_level_name", data.get("level_name"));
		session.setAttribute("login_business_code", data.get("business_code"));
		session.setAttribute("login_bpart", data.get("bpart_code"));
		session.setAttribute("login_mpart", data.get("mpart_code"));
		session.setAttribute("login_spart", data.get("spart_code"));
		session.setAttribute("login_ip", login_ip);
		session.setAttribute("down_ip", data.get("down_ip"));
		session.setAttribute("login_datm", data.get("login_datm"));
		session.setAttribute("eval_yn", data.get("eval_yn"));
		
		//녹취 다운로드여부 세션 저장 - CJM(20181217)
		String recDownYn = "Y";
		if(!Finals.isRecDownload)	recDownYn = data.get("rec_down_yn").toString();
		else						recDownYn = "Y";
		session.setAttribute("rec_down_yn", recDownYn);

		/*
			14. 메뉴 권한 Session 생성
		*/
		argMap.put("business_code", data.get("business_code").toString());
		argMap.put("user_level", data.get("user_level").toString());
		argMap.put("user_level_cd", data.get("user_level_cd").toString());
		List<Map<String, Object>> menuList = db.selectList("menu.selectMenuPerm", argMap);
		if(menuList.size() < 1) 
		{
			Site.writeJsonResult(out, false, "접근 가능한 메뉴가 없습니다.");
			return;
		}
		
		Map<String,String> tmpMap = new LinkedHashMap();
		for(int i=0; i<menuList.size(); i++) 
		{
			tmpMap.put(menuList.get(i).get("menu_code").toString(), CommonUtil.getFilenameNoExt(menuList.get(i).get("menu_url").toString()));
		}
		session.setAttribute("menu_perm", tmpMap);

		/*
			15. 중복 로그인 제어
		*/
		SessionListener sl = new SessionListener();

		// set session data to activeUsers
		sl.setLoginSession(request, session);

		// duplicate login check ==> 중복일 경우 기존 세션 삭제
		sl.checkDuplicateLogin(request, session);

		/*
			16. 로그인 결과 업데이트(성공)
		*/
		argMap.put("login_result", "1");
		db.update("login.updateLoginResult", argMap);

		/*
			17. 로그인 이력 등록(성공)
		*/
		argMap.put("login_name", data.get("user_name").toString());
		db.insert("hist_login.insertLoginHist", argMap);

		/*
			18. 로그인 정보 업데이트(로그인 일시, IP)
		*/
		argMap.put("user_id", login_id);
		argMap.put("login_yn", "1");
		db.update("user.updateUser", argMap);

		/*
			19. 화면 디자인 정보 업데이트(css 정의)
		*/
		// template color cookie expire date 업데이트
		if(!"".equals(CommonUtil.getCookieValue("ck_template_color"))) 
		{
			Cookie cook = new Cookie("ck_template_color", CommonUtil.getCookieValue("ck_template_color"));
			cook.setPath("/");
			cook.setMaxAge(60*60*24*7);
			response.addCookie(cook);
		}
		
		/*
			20. 비밀번호 만료일 노출(만료일 임박시 15일 기준)
				로그인은 정상적으로 알림 메시지 노출 필요.
		*/
		String passExpireDate = CommonUtil.ifNull(data.get("pass_expire_date")+"");
		if(passCheckDay < 16 )
		{
			out.print("{\"code\":\"PASSCHK\",\"msg\":\"비밀번호 만료일이 [" + passExpireDate + "] 입니다.\\n비밀번호를 변경하시기 바랍니다\"}");
			return;
		}
		
		if(Finals.isDev){session.setMaxInactiveInterval(60*60*24);}//초단위(24시간)

		//Finals.setApplicationVariable();//변수 로딩
		if(login_id.equals("admin")) Finals.setApplicationVariable(true);//강제로 변수 리로드
		else						 Finals.setApplicationVariable();

		Site.writeJsonResult(out,true);
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db!=null)	db.close();
	}
%>