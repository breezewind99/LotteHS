package com.cnet.crec.util;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CrossDomainFilter implements Filter 
{
	/**
	 * destroy
	 */
	@Override
	public void destroy() {}
	
	/**
	 * init
	 */
	@Override
	public void init(FilterConfig arg0) throws ServletException {}

	/**
	 * doFilter
	 */
	@Override
	public void doFilter(ServletRequest request, ServletResponse servletResponse, FilterChain chain) throws IOException, ServletException 
	{
		if (!(request instanceof HttpServletRequest)) 
		{
			throw new ServletException("This filter can "
					+ " only process HttpServletRequest requests");
		}
		HttpServletResponse response = (HttpServletResponse) servletResponse;
		response.setHeader("Access-Control-Allow-Origin", "*");
		//response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
		response.setHeader("Access-Control-Allow-Methods", "POST, GET, HEAD");
		response.setHeader("Access-Control-Max-Age", "3600");
		response.setHeader("Access-Control-Allow-Headers", "origin, x-requested-with, content-type, accept");
		chain.doFilter(request, response);
	}
}
