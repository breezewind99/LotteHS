package com.cnet.crec.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;

public class ApiExamSearch 
{
  	public static String get(String apiUrl, Map<String, String> requestHeaders)
  	{
  		HttpURLConnection con = connect(apiUrl);
  		try 
  		{
  			// 요청 방식 선택 (GET, POST)
  			con.setRequestMethod("GET");
  			
  			//서버 접속시 연결 시간
  			con.setConnectTimeout(10000);	//10초
  			//READ 연결 시간
  			con.setReadTimeout(5000);		//5초
  			
  			//header
  			for(Map.Entry<String, String> header :requestHeaders.entrySet()) 
  			{
  				con.setRequestProperty(header.getKey(), header.getValue());
  			}
  			
  			//타입 설정(application/json) 형식으로 전송
  			//con.setRequestProperty("Content-Type", "application/json");

  			int responseCode = con.getResponseCode();
  			
  			if(responseCode == HttpURLConnection.HTTP_OK) 
  			{ 
  				// 정상 호출
  				return readBody(con.getInputStream());
  			}
  			else 
  			{ 
  				// 에러 발생
  				return readBody(con.getErrorStream());
  			}
  		} 
  		catch (IOException e) 
  		{
  			throw new RuntimeException("API 요청과 응답 실패", e);
  		}
  		finally 
  		{
  			con.disconnect();
  		}
  	}

  	private static HttpURLConnection connect(String apiUrl)
  	{
  		try 
  		{
  			URL url = new URL(apiUrl);
  			return (HttpURLConnection)url.openConnection();
  		}
  		catch (MalformedURLException e) 
  		{
  			throw new RuntimeException("API URL이 잘못되었습니다. : " + apiUrl, e);
  		}
  		catch (IOException ex) 
  		{
  			throw new RuntimeException("연결이 실패했습니다. : " + apiUrl, ex);
  		}
  	}

  	private static String readBody(InputStream body)
  	{
  		try 
  		{
  			InputStreamReader streamReader = new InputStreamReader(body, "UTF-8");
  			BufferedReader lineReader = new BufferedReader(streamReader);
  			StringBuilder responseBody = new StringBuilder();

			String line;
			while((line = lineReader.readLine()) != null) 
			{
				responseBody.append(line);
			}

			lineReader.close();
			streamReader.close();
			
			return responseBody.toString();
  		}
  		catch (IOException e) 
  		{
  			throw new RuntimeException("API 응답을 읽는데 실패했습니다.", e);
  		}
  	}
}