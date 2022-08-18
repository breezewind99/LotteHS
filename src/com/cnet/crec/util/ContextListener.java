package com.cnet.crec.util;

import java.util.HashMap;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class ContextListener implements ServletContextListener 
{
	/**
	 * contextInitialized
	 */
	public void contextInitialized(ServletContextEvent e) 
	{
		ServletContext ctx = e.getServletContext();
		
		ctx.setAttribute("activeUsers", new HashMap());
	}

	/**
	 * contextDestroyed
	 */
	public void contextDestroyed(ServletContextEvent e) 
	{
		ServletContext ctx = e.getServletContext();
		
		ctx.removeAttribute("activeUsers");
	}
}
