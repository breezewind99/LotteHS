package com.cnet.crec.common;

import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Mask {

    public Mask(){}

    // 전화번호 마스킹
    public static String getMaskedPhoneNum(String phoneNum) {
        String regex = "(\\d{2,3})(\\d{3,4})(\\d{4})$";
        //String regex = "(\\d{2,3})-?(\\d{3,4})-?(\\d{4})$";		//휴대폰번호 '-' 포함
        Matcher matcher = Pattern.compile(regex).matcher(phoneNum);
        if (matcher.find()) {
            String replaceTarget = matcher.group(2);
            char[] c = new char[replaceTarget.length()];
            Arrays.fill(c, '*');

            return phoneNum.replace(replaceTarget, String.valueOf(c));
        }
        regex = "(\\d{1,4})(\\d{4})$";
        matcher = Pattern.compile(regex).matcher(phoneNum);
        if (matcher.find()) {
            String replaceTarget = matcher.group(1);
            char[] c = new char[replaceTarget.length()];
            Arrays.fill(c, '*');

            return phoneNum.replace(replaceTarget, String.valueOf(c));
        }
        return phoneNum;
    }

    // 이름 중간 마스킹
    public static String getMaskedName(String name) {
        String maskedName = "";     // 마스킹 이름
        String firstName = "";      // 성
        String middleName = "";     // 이름 중간
        String lastName = "";       //이름 끝
        int lastNameStartPoint;     // 이름 시작 포인터

        if(!name.equals("") || name != null){
            if(name.length() > 1){
                firstName = name.substring(0, 1);
                lastNameStartPoint = name.indexOf(firstName);

                if(name.trim().length() > 2){
                    middleName = name.substring(lastNameStartPoint + 1, name.trim().length()-1);
                    lastName = name.substring(lastNameStartPoint + (name.trim().length() - 1), name.trim().length());
                }else{
                    middleName = name.substring(lastNameStartPoint + 1, name.trim().length());
                }

                String makers = "";
                for(int i = 0; i < middleName.length(); i++){
                    makers += "*";
                }

                lastName = middleName.replace(middleName, makers) + lastName;
                maskedName = firstName + lastName;
            }else{
                maskedName = name;
            }
        }

        return maskedName;
    }

}
