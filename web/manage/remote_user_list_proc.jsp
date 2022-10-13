<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%@ page import="com.cnet.CnetCrypto.CNCrypto"%>
<%
	if(!Site.isPmss(out,"user_mgmt","json")) return;

	Db db = null;

	try 
	{
		// DB Connection (transaction)
		db = new Db();

		// get parameter
		String step = CommonUtil.getParameter("step");

		String client_ip = request.getRemoteAddr();
		
		//녹취 구분 추가 - CJM(20190626)
		//IP : I TDM : T
		String recDiv = "I"; 
		if(!Finals.isChannel)	recDiv = "T";
		else					recDiv = "I";
		
		//logger.info("recDiv : "+recDiv);

		Map<String, Object> argMap = new HashMap<String, Object>();

		if("insert".equals(step)) 
		{
			// get parameter
			String part_code = CommonUtil.getParameter("part_code");
			String user_id = CommonUtil.getParameter("user_id", "");
			String user_pass = CommonUtil.getParameter("user_pass");
			String user_name = CommonUtil.getParameter("user_name", "");
			String local_no = CommonUtil.getParameter("local_no", "");
			String system_code = CommonUtil.getParameter("system_code", "");
			String user_level = CommonUtil.getParameter("user_level", "E");
			//String pass_chg_term = CommonUtil.getParameter("pass_chg_term", "90");
			String pass_chg_term = CommonUtil.getParameter("pass_chg_term", "0");
			String user_ip = CommonUtil.getParameter("user_ip", "");
			String eval_yn = CommonUtil.getParameter("eval_yn", "");	//평가자여부
			
			//녹취 다운로드여부 - CJM(20181217)
			String rec_down_yn = CommonUtil.getParameter("rec_down_yn", "");
			
			//채널번호 정보 제거 - CJM(20181112)
			String channel_no = CommonUtil.getParameter("channel_no", "");

			// 파라미터 체크
			if(!CommonUtil.hasText(part_code) || !CommonUtil.hasText(user_id) || !CommonUtil.hasText(user_pass) || !CommonUtil.hasText(user_name) || !CommonUtil.hasText(local_no)) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 비밀번호 유효성 체크
			String _check_passwd = CommonUtil.checkPasswd(user_pass, user_id, "json");
			if(CommonUtil.hasText(_check_passwd)) 
			{
				out.print(_check_passwd);
				return;
			}

			String business_code = CommonUtil.leftString(part_code, 2);
			//String bpart_code = part_code.substring(2, 7);
			//String mpart_code = part_code.substring(7, 12);
			//String spart_code = part_code.substring(12, 17);
			String bpart_code = part_code.substring(2, 2+(_PART_CODE_SIZE*1));
			String mpart_code = part_code.substring(2+(_PART_CODE_SIZE*1), 2+(_PART_CODE_SIZE*2));
			String spart_code = part_code.substring(2+(_PART_CODE_SIZE*2), 2+(_PART_CODE_SIZE*3));

			// 비밀번호 암호화
			CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());
			String enc_user_pass = sha256.Encrypt(user_pass);

			argMap.put("user_id",user_id);
			argMap.put("user_pass",enc_user_pass);
			argMap.put("user_name",user_name);
			argMap.put("business_code",business_code);
			argMap.put("bpart_code",bpart_code);
			argMap.put("mpart_code",mpart_code);
			argMap.put("spart_code",spart_code);
			argMap.put("user_level",user_level);
			argMap.put("local_no",local_no);
			argMap.put("system_code",system_code);
			argMap.put("pass_chg_term",pass_chg_term);
			argMap.put("user_ip",user_ip);
			argMap.put("regi_ip",client_ip);
			argMap.put("regi_id",_LOGIN_ID);
			argMap.put("eval_yn",eval_yn);//평가자여부
			
			//녹취 다운로드여부 - CJM(20181217)
			argMap.put("rec_down_yn", rec_down_yn);
			
			argMap.put("channel_no",channel_no);
			argMap.put("rec_div", recDiv);
			
			//아이디 중복 체크 - CJM(20181112)
			int userIdChk = db.selectOne("user.userIdChk", argMap);
			
			if(userIdChk > 0)
			{
				Site.writeJsonResult(out, false, "동일한 상담원 ID가 존재합니다.");
				return;
			}

			int ins_cnt = db.insert("user.insertUser", argMap);
			if(ins_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "등록에 실패했습니다.");
				return;
			}

			/**
				TDM 일 경우 crec_user_info 등록 기능 필요 - CJM(20190628)
				IP는 필요 없음
			
			if(!"9999".equals(local_no))
			{
				ins_cnt = db.insert("user.insertCrecUser", argMap);
				if(ins_cnt < 1) 
				{
					Site.writeJsonResult(out, false, "등록에 실패했습니다.");
					return;
				}
			}
			*/
			
			// 등록 이력 저장
			argMap.clear();
			argMap.put("user_id", user_id);
			argMap.put("user_name", user_name);
			argMap.put("change_type", "I");
			argMap.put("change_id", _LOGIN_ID);
			argMap.put("change_name", _LOGIN_NAME);
			argMap.put("change_ip", client_ip);
			argMap.put("origin_level", user_level);
			argMap.put("change_level", "");

			db.insert("hist_user_change.insertUserChangeHist", argMap);
		} 
		else if("update".equals(step)) 
		{
			// get parameter
			String data_list = CommonUtil.getParameter("data_list");

			// 파라미터 체크
			if(!CommonUtil.hasText(data_list)) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// &quot; -> " 로 replace
			data_list = "{\"data_list\":" + CommonUtil.toTextJSON(data_list) + "}";

			// 비밀번호 암호화
			CNCrypto sha256 = new CNCrypto("HASH",CommonUtil.getEncKey());

			JSONParser jsonParser = new JSONParser();

			JSONObject jsonObj = (JSONObject) jsonParser.parse(data_list);

			JSONArray jsonArr = (JSONArray) jsonObj.get("data_list");
			Iterator<Object> iterator = jsonArr.iterator();

			int upd_cnt = 0;
			while (iterator.hasNext()) 
			{
				JSONObject jsonItem = (JSONObject) iterator.next();

				argMap.clear();
				argMap.put("user_id",jsonItem.get("user_id"));
				if(!"".equals(CommonUtil.ifNull(jsonItem.get("user_pass")+""))) 
				{
					// 비밀번호 유효성 체크
					String _check_passwd = CommonUtil.checkPasswd(jsonItem.get("user_pass").toString(), jsonItem.get("user_id").toString(), "json");
					if(CommonUtil.hasText(_check_passwd)) 
					{
						continue;
					}

					argMap.put("user_pass",sha256.Encrypt(jsonItem.get("user_pass").toString()));
				}
				argMap.put("user_name",jsonItem.get("user_name"));
				argMap.put("user_level",jsonItem.get("user_level"));
				argMap.put("local_no",jsonItem.get("local_no"));
				argMap.put("system_code",jsonItem.get("system_code"));
				
				//argMap.put("pass_chg_term",jsonItem.get("pass_chg_term").toString());
				//argMap.put("pass_chg_term","0");
				
				logger.info("pass_chg_term : "+jsonItem.get("pass_chg_term").toString());
				
				//비밀번호 사용 기간 정보 체크 - CJM(20201112)
				if(!CommonUtil.hasText(jsonItem.get("pass_chg_term").toString()))	argMap.put("pass_chg_term", 0);
				else																argMap.put("pass_chg_term", Integer.parseInt(jsonItem.get("pass_chg_term").toString()));
				
				//패스워드 수정 일자 체크 - CJM(20201112)
				logger.info("user_pass : "+jsonItem.get("user_pass").toString());
				logger.info("pass_upd_date : "+jsonItem.get("pass_upd_date").toString());
				logger.info("pass ck : "+!CommonUtil.hasText(jsonItem.get("user_pass").toString()));
				
				if(!CommonUtil.hasText(jsonItem.get("user_pass").toString()) && CommonUtil.hasText(jsonItem.get("pass_upd_date").toString()))	
				{
					logger.info("패스워드 수정 일자 체크");
					argMap.put("pass_upd_date",jsonItem.get("pass_upd_date").toString());
				}
				
				argMap.put("user_ip",jsonItem.get("user_ip"));
				argMap.put("resign_yn",jsonItem.get("resign_yn"));
				argMap.put("use_yn",jsonItem.get("use_yn"));
				argMap.put("upd_ip",client_ip);
				argMap.put("upd_id",_LOGIN_ID);
				argMap.put("eval_yn",jsonItem.get("eval_yn"));//평가자여부
				
				//녹취 다운로드여부 - CJM(20181217)
				argMap.put("rec_down_yn", jsonItem.get("rec_down_yn"));
				
				//녹취 구분 정보 추가 - CJM(20190626)
				argMap.put("channel_no", jsonItem.get("channel_no"));
				argMap.put("rec_div", recDiv);
				
				//pass_upd_date				

				int tmp_upd_cnt = db.update("user.updateUser", argMap);
				upd_cnt += tmp_upd_cnt;
				
				/**
					TDM 일 경우 crec_user_info 수정 기능 필요 - CJM(20190628)
					IP는 필요 없음
				
				if(!"9999".equals(jsonItem.get("local_no")))
				{
					tmp_upd_cnt = db.update("user.updateCrecUser", argMap);
				}
				*/

				if(tmp_upd_cnt > 0) 
				{
					// 수정 이력 저장
					argMap.clear();
					argMap.put("user_id", jsonItem.get("user_id"));
					argMap.put("user_name", jsonItem.get("user_name"));
					argMap.put("change_type", "U");
					argMap.put("change_id", _LOGIN_ID);
					argMap.put("change_name", _LOGIN_NAME);
					argMap.put("change_ip", client_ip);
					
					// 등급변경
					if(!jsonItem.get("origin_level").equals(jsonItem.get("user_level"))) 
					{
						argMap.put("origin_level", jsonItem.get("origin_level"));
						argMap.put("change_level", jsonItem.get("user_level"));
					} 
					else 
					{
						argMap.put("origin_level", "");
						argMap.put("change_level", "");
					}

					db.insert("hist_user_change.insertUserChangeHist", argMap);

					// 비밀번호 변경이력 저장
					//if(!"".equals(jsonItem.get("user_pass"))) 
					if(!"".equals(CommonUtil.ifNull(jsonItem.get("user_pass")+"")))
						
					{
						argMap.clear();
						argMap.put("change_pass", sha256.Encrypt(jsonItem.get("user_pass").toString()));
						argMap.put("user_id", jsonItem.get("user_id"));
						argMap.put("user_name", jsonItem.get("user_name"));
						argMap.put("change_id", _LOGIN_ID);
						argMap.put("change_name", _LOGIN_NAME);
						argMap.put("change_ip", client_ip);

						db.insert("hist_pass_change.insertPassChangeHist", argMap);
					}
				}
			}

			if(upd_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
				return;
			}
		} 
		else if("delete".equals(step)) 
		{
			// get parameter
			String user_id = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(user_id)) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 사용자 정보 조회
			Map<String, Object> data = db.selectOne("user.selectItem", user_id);
			if(data == null) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_DATA"));
				return;
			}
			
			// login result reset - CJM(20200103)
			int del_cnt = db.delete("user.unlockLoginResult", user_id);

			del_cnt = db.delete("user.deleteUser", user_id);
			if(del_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
				return;
			}
			
			/**
				TDM 일 경우 crec_user_info 삭제 기능 필요 - CJM(20190628)
				IP는 필요 없음
			
			if(!"9999".equals(data.get("local_no")))
			{
				del_cnt = db.delete("user.deleteCrecUser", user_id);
				if(del_cnt < 1) 
				{
					Site.writeJsonResult(out, false, "삭제에 실패했습니다.");
					return;
				}
			}
			*/

			// 삭제 이력 저장
			argMap.put("user_id", user_id);
			argMap.put("user_name", data.get("user_name").toString());
			argMap.put("change_type", "D");
			argMap.put("change_id", _LOGIN_ID);
			argMap.put("change_name", _LOGIN_NAME);
			argMap.put("change_ip", client_ip);
			argMap.put("origin_level", data.get("user_level").toString());
			argMap.put("change_level", "");

			db.insert("hist_user_change.insertUserChangeHist", argMap);
		} 
		else if("unlock".equals(step)) 
		{
			// get parameter
			String user_id = CommonUtil.getParameter("row_id");

			// 파라미터 체크
			if(!CommonUtil.hasText(user_id)) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
				return;
			}

			// 사용자 정보 조회
			Map<String, Object> data = db.selectOne("user.selectItem", user_id);
			if(data == null) 
			{
				Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_DATA"));
				return;
			}

			// login result reset
			db.delete("user.unlockLoginResult", user_id);

			argMap.put("user_id",user_id);
			argMap.put("lock_yn","0");
			argMap.put("upd_ip",client_ip);
			argMap.put("upd_id",_LOGIN_ID);
			argMap.put("rec_div", recDiv);

			int upd_cnt = db.update("user.updateUser", argMap);
			if(upd_cnt < 1) 
			{
				Site.writeJsonResult(out, false, "잠금해제에 실패했습니다.");
				return;
			}

			// 수정 이력 저장
			argMap.clear();
			argMap.put("user_id", user_id);
			argMap.put("user_name", data.get("user_name").toString());
			argMap.put("change_type", "L");
			argMap.put("change_id", _LOGIN_ID);
			argMap.put("change_name", _LOGIN_NAME);
			argMap.put("change_ip", client_ip);
			argMap.put("origin_level", "");
			argMap.put("change_level", "");

			db.insert("hist_user_change.insertUserChangeHist", argMap);
		}
		else if("partUp".equals(step))
		{
			// get parameter
			String part_code = CommonUtil.getParameter("part_code");
			String user_id = CommonUtil.getParameter("user_id", "");
			String user_name = CommonUtil.getParameter("user_name", "");
			String local_no = CommonUtil.getParameter("local_no", "");
			String system_code = CommonUtil.getParameter("system_code", "");
			String user_level = CommonUtil.getParameter("user_level", "E");
			String pass_chg_term = CommonUtil.getParameter("pass_chg_term", "0");
			String user_ip = CommonUtil.getParameter("user_ip", "");
			
			String bpart_code = CommonUtil.getParameter("bpart_code", "");
			String mpart_code = CommonUtil.getParameter("mpart_code", "");
			String spart_code = CommonUtil.getParameter("spart_code", "");
			String origin_level = CommonUtil.getParameter("origin_level", "");
			String eval_yn = CommonUtil.getParameter("eval_yn", "");
			
			//녹취 다운로드여부 - CJM(20181217)
			String rec_down_yn = CommonUtil.getParameter("rec_down_yn", "");
			
			//채널번호 정보 제거 - CJM(20181112)
			String channel_no = CommonUtil.getParameter("channel_no", "");
			
			//패스워드 수정 일자 - CJM(20201202)
			String pass_upd_date = CommonUtil.getParameter("pass_upd_date", "");
			
			// 파라미터 체크
			if(!CommonUtil.hasText(bpart_code) || !CommonUtil.hasText(mpart_code) || !CommonUtil.hasText(spart_code) 
				||!CommonUtil.hasText(user_id) || !CommonUtil.hasText(user_name) || !CommonUtil.hasText(local_no)) 
			{
				out.print("{\"code\":\"ERR\", \"msg\":\"" + CommonUtil.getErrorMsg("NO_PARAM") + "\"}");
				return;
			}

			argMap.put("user_id",user_id);
			argMap.put("user_name",user_name);
			argMap.put("bpart_code",bpart_code);
			argMap.put("mpart_code",mpart_code);
			argMap.put("spart_code",spart_code);
			argMap.put("user_level",user_level);
			argMap.put("local_no",local_no);
			argMap.put("system_code",system_code);
			argMap.put("pass_chg_term",pass_chg_term);
			argMap.put("eval_yn",eval_yn);
			argMap.put("user_ip",user_ip);
			argMap.put("upd_ip",client_ip);
			argMap.put("upd_id",_LOGIN_ID);
			
			//녹취 다운로드여부 - CJM(20181217)
			argMap.put("rec_down_yn", rec_down_yn);
			
			argMap.put("channel_no",channel_no);
			argMap.put("rec_div", recDiv);
			
			argMap.put("pass_upd_date", pass_upd_date);
			
			logger.info("pass_chg_term : "+pass_chg_term);
			logger.info("pass_upd_date : "+pass_upd_date);
			
			int partUpCnt = db.update("user.updateUser", argMap);

			/**
				TDM 일 경우 crec_user_info 수정 기능 필요 - CJM(20190628)
				IP는 필요 없음
			
			if(!"9999".equals(local_no))
			{
				partUpCnt = db.update("user.updateCrecUser", argMap);
			}
			*/
			
			if(partUpCnt < 1) 
			{
				out.print("{\"code\":\"ERR\", \"msg\":\"수정에 실패했습니다.\"}");
				return;
			}

			// 수정 이력 저장
			argMap.clear();
			argMap.put("user_id", user_id);
			argMap.put("user_name", user_name);
			argMap.put("change_type", "U");
			argMap.put("change_id", _LOGIN_ID);
			argMap.put("change_name", _LOGIN_NAME);
			argMap.put("change_ip", client_ip);
			argMap.put("origin_level", user_level);
			argMap.put("change_level", "");
				
			// 권한변경이 있을 경우 이전권한과 변경권한 등록
			if(!origin_level.equals(user_level)) 
			{
				argMap.put("origin_level", origin_level);
				argMap.put("change_level", user_level);
			} 
			else 
			{
				argMap.put("origin_level", "");
				argMap.put("user_level", "");
			}
			
			db.insert("hist_user_change.insertUserChangeHist", argMap);
		} 
		else 
		{
			Site.writeJsonResult(out, false, CommonUtil.getErrorMsg("NO_PARAM"));
			return;
		}

		// commit
		db.commit();

		out.print("{\"code\":\"OK\", \"tree\": {\"refresh\":\"false\"}, \"msg\":\"\"}");
	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		if(db != null)	db.close();
	}
%>