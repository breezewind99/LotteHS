<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	/* 소프트폰 Interface */

	try
	{
		// get parameter
		String rec_datm = CommonUtil.getParameter("rec_datm");
		String local_no = CommonUtil.getParameter("local_no");
		String rec_keycode = CommonUtil.getParameter("rec_keycode");
		String store_code = CommonUtil.getParameter("store_code");
		String mystery_code = CommonUtil.getParameter("mystery_code");
		String customer_code = CommonUtil.getParameter("customer_code");

		if(!CommonUtil.hasText(rec_datm)
				|| !CommonUtil.hasText(local_no)
				|| !CommonUtil.hasText(rec_keycode))
		{
			out.print("ERR_PARAM");
			return;
		}

		logger.info("rec_datm : " + rec_datm);
		logger.info("local_no : " + local_no);
		logger.info("rec_keycode : " + rec_keycode);
		logger.info("store_code : " + store_code);
		logger.info("mystery_code : " + mystery_code);
		logger.info("customer_code : " + customer_code);


		out.print("OK");
		//Site.writeJsonResult(out,true);

	}
	catch(Exception e)
	{
		logger.error(e.getMessage());
		out.print(e.getMessage());
	}
	finally
	{

	}
%>	