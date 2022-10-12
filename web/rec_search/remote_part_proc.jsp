<%@page import="com.cnet.CnetCrypto.CNCrypto"%>
<%@page import="java.net.DatagramPacket"%>
<%@page import="java.net.InetAddress"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.DatagramSocket"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"rec_search", "close")) return;
	
	DatagramSocket ds = null;
	Db db = null;
	
	try 
	{
		db = new Db(true);
		
		// get parameter
		String info = CommonUtil.getParameter("info");
		String cust_id = CommonUtil.getParameter("cust_id");
		String rec_keycode = CommonUtil.getParameter("rec_keycode");
		String custom_fld_02 = CommonUtil.getParameter("custom_fld_02");
		String custom_fld_03 = CommonUtil.getParameter("custom_fld_03");
		String custom_fld_04 = CommonUtil.getParameter("custom_fld_04");
		
		//r:고객정보수정 p:고객정보수정/부분녹취 - CJM(20181119)
		String step = CommonUtil.getParameter("step", "p");
		
		// 파라미터 체크
		//if(!CommonUtil.hasText(info) || !CommonUtil.hasText(rec_filename) || !CommonUtil.hasText(pa_stime) || !CommonUtil.hasText(pa_etime)) 
		if(!CommonUtil.hasText(info))
		{
			out.print(CommonUtil.getPopupMsg(CommonUtil.getErrorMsg("NO_PARAM"),"","close"));
			return;
		}
		
		// 파리미터 복호화
		//CNCrypto aes = new CNCrypto("AES",CommonUtil.getEncKey());
		//info = aes.Decrypt(info);

		String tmp_arr[] = info.split("\\|");
		String rec_datm = tmp_arr[1];
		String local_no = tmp_arr[2];
		String rec_filename = tmp_arr[3];
		
		
		/*
		System.out.println("☆☆");
		
		System.out.println("rec_datm : "+rec_datm);
		System.out.println("local_no : "+local_no);
		System.out.println("rec_filename : "+ rec_filename);
		
		System.out.println("cust_id : "+cust_id);
		System.out.println("rec_keycode : "+rec_keycode);
		System.out.println("custom_fld_02 : "+custom_fld_02);
		System.out.println("custom_fld_03 : "+custom_fld_03);
		System.out.println("custom_fld_04 : "+custom_fld_04);		
		*/
		Map<String, Object> argMap = new HashMap<String, Object>();
		
		argMap.put("rec_datm", DateUtil.getDateFormatByIntVal(rec_datm, "yyyy-MM-dd HH:mm:ss"));
		argMap.put("local_no", local_no);
		argMap.put("rec_filename", rec_filename);
		
		argMap.put("cust_id", cust_id);
		argMap.put("rec_keycode", rec_keycode);
		argMap.put("custom_fld_02", custom_fld_02);
		argMap.put("custom_fld_03", custom_fld_03);
		argMap.put("custom_fld_04", custom_fld_04);

		//누락 정보 수정		
		int upd_cnt = db.update("rec_search.updateOmission", argMap);
		if(upd_cnt < 1) 
		{
			Site.writeJsonResult(out, false, "업데이트에 실패했습니다.");
			return;
		}
		//고객정보수정/부분녹취 일 경우만 UDP 통신 - CJM(20181119)
		if(step.equals("p"))
		{
			String pa_stime  = tmp_arr[4];
			String pa_etime  = tmp_arr[5];
			
			String getrDate = rec_datm.substring(0, 8);
			String getrTime = rec_datm.substring(8, 10);
			
			//System.out.println("getrDate : "+getrDate);
			//System.out.println("getrTime : "+getrTime);
			
			String[] sTime = pa_stime.split(":");
			int getrStime = (Integer.parseInt(sTime[0])*3600)+(Integer.parseInt(sTime[1])*60)+(Integer.parseInt(sTime[2]));
			
			String[] eTime = pa_etime.split(":");
			int getrEtime = (Integer.parseInt(eTime[0])*3600)+(Integer.parseInt(eTime[1])*60)+(Integer.parseInt(eTime[2]));
			
			int getInterval = getrEtime - getrStime;
			String systemIp = "192.168.0.24";
			//int port = 20005;
			int port = 9090;
			/*
			System.out.println("getrStime : "+getrStime);
			System.out.println("getrEtime : "+getrEtime);
			System.out.println("getInterval : "+getInterval);
			System.out.println("systemIp : "+systemIp);
			*/
			// UDP 통신 수신 전문
			ds = new DatagramSocket();
			
	        // send data 설정
			InetAddress address = InetAddress.getByName(systemIp);
			String header = "PART#"+getrDate+"#"+getrTime+"#"+getrStime+"#"+getInterval+"#"+rec_filename+"##";
			
			//System.out.println("address : "+address);
			//System.out.println("header : "+header);
	
			//String header = "NON";		
			byte[] buf = header.getBytes();
			
			// send
			DatagramPacket packet = new DatagramPacket(buf, buf.length, address, port);
			ds.send(packet);
		}

		//System.out.println("☆☆");
		
		Site.writeJsonResult(out,true);

	} catch(NullPointerException e) {
		logger.error(e.getMessage());
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally
	{
		//socket close
		if(ds!=null) ds.close();
		if(db!=null) db.close();
	}
%>	