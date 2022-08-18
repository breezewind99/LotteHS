package com.cnet.crec.mybatis;

import java.util.HashMap;

import org.apache.commons.lang.StringUtils;
 
@SuppressWarnings("rawtypes")
public class LowerKeyHashMap extends HashMap 
{
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
     * key 에 대하여 소문자로 변환하여 super.put
     * (ListOrderedMap) 을 호출한다.
     * @param key
     *        - '_' 가 포함된 변수명
     * @param value
     *        - 명시된 key 에 대한 값 (변경 없음)
     * @return previous value associated with specified
     *         key, or null if there was no mapping for
     *         key
     */
	@SuppressWarnings("unchecked")
	@Override
    public Object put(Object key, Object value) 
    {
        return super.put(StringUtils.lowerCase((String) key), value);
    }
}
