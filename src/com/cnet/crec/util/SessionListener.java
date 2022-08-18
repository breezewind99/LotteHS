package com.cnet.crec.util;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.apache.log4j.Logger;

public class SessionListener implements HttpSessionListener 
{
	private static final Logger logger = Logger.getLogger(SessionListener.class); 
	
	/**
	 * init
	 * @param config
	 */
	public void init(ServletConfig config) {}
	
	/**
	 * Adds sessions to the context scoped HashMap when they begin.
	 */
	@Override
	public void sessionCreated(HttpSessionEvent e)
	{
		HttpSession session = e.getSession();
		ServletContext ctx = session.getServletContext();
		Map activeUsers = (Map) ctx.getAttribute("activeUsers");
						
		activeUsers.put(session.getId(), session);
		//logger.debug("create session_id : " +  session.getId());
	}

	/**
	 * Removes sessions from the context scoped HashMap when they expire
	 * or are invalidated.
	 */
	@Override
	public void sessionDestroyed(HttpSessionEvent e)
	{
		HttpSession session = e.getSession();
		ServletContext ctx = e.getSession().getServletContext();
		Map activeUsers = (Map) ctx.getAttribute("activeUsers");

		activeUsers.remove(session.getId());
		//logger.debug("remove session_id : " + session.getId());
	}
	
	/**
	 * login session put.
	 */	
	public void setLoginSession(HttpServletRequest request, HttpSession session) 
	{
		if (request.getServletContext().getAttribute("activeUsers") == null) {
			request.getServletContext().setAttribute("activeUsers",new HashMap());
		}
		Map activeUsers = (Map) request.getServletContext().getAttribute("activeUsers");				
		
		activeUsers.put(session.getId(), session);
		//logger.debug("active session size : " + activeUsers.size());
	}
	
	/**
	 * check duplicate login
	 */		
	public boolean checkDuplicateLogin(HttpServletRequest request, HttpSession session) 
	{
		boolean flag = false;
		Map activeUsers = (Map) request.getServletContext().getAttribute("activeUsers");
		
		Iterator<String> keys = activeUsers.keySet().iterator();
		while(keys.hasNext())
		{
			String key = keys.next();
			// 기존 로그인한 사용자 세션
			HttpSession sess = null;

			/*
			 *  중복 로그인 체크시 로그인 이상 현상 발생
			 *  getAttribute 오류 발생으로 판단되어 try 위치 확장 - CJM(20200219)
			 */
			try 
			{
				sess = (HttpSession) activeUsers.get(key);

				// 현재 사용자와 login_id가 동일하지만 세션 아이디가 다른 경우 기존 세션 삭제
				if(sess!=null && sess.getAttribute("login_id") != null) 
				{
					
					logger.debug("sess login_id : " + sess.getAttribute("login_id"));
					logger.debug("session login_id : " + session.getAttribute("login_id"));
					logger.debug("sess key : " + key);
					logger.debug("session getId : " + session.getId());
					
					//동일 아이디 세션 제거 부분 - CJM(20181221)
					if(sess.getAttribute("login_id").equals(session.getAttribute("login_id")) && !key.equals(session.getId())) 
					{
						sess.invalidate();
						logger.debug("logout session id : " + key);
						flag = true;
						break;
					}
				}
			} 
			catch(Exception e) 
			{
				logger.info("error session id : " + key);
				continue;
			}
		}
		
		return flag;
	}
}