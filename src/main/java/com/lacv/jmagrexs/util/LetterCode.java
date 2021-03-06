/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.lacv.jmagrexs.util;

/**
 *
 * @author e11001a
 */
public class LetterCode {

    char[] alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();
    int N = 14;
    long[] p26, acc;

    public LetterCode() {
        p26 = new long[N];
        acc = new long[N];
        p26[0] = 1;
        for (int i = 1; i < N; i++) {
            p26[i] = 26 * p26[i - 1];
        }
        acc[0] = 0;
        for (int i = 1; i < N; i++) {
            acc[i] = acc[i - 1] + p26[i];
        }
    }

    public String toString(long n) {
        long num= n + 1;
        int digits = 0;
        if(num>acc[N-1]){
            digits= 14;
        }else{
            for (int i = 1; i < N; i++) {
                if (num <= acc[i]) {
                    digits = i;
                    break;
                }
            }
        }
        long to_add = num - acc[digits - 1] - 1;
        String result = "";

        for (int i = digits - 1; i >= 0; i--) {
            int digit = (int)(to_add / p26[i]);
            to_add = to_add % p26[i];
            result += alpha[digit];
        }
        return result;
    }

    public long toLong(String n) {
        long result = 0;
        String rvn= new StringBuilder(n).reverse().toString();

        for (int i = 0; i <rvn.length(); i++) {
            result += (rvn.charAt(i) - 'A') * p26[i];
        }
        return result + acc[rvn.length() - 1];
    }
    
    public static void main(String args[]){
        
        LetterCode lc= new LetterCode();
        
        //System.out.println(">>\n"+(long)Math.pow(26, 15));
        System.out.println(lc.toString((long)Math.pow(2, 63)-2));
        
        System.out.println(lc.toString((long)(1L<<63)-2));
        //System.out.println(lc.toLong("JGZHJR"));
        
        for(int i=0; i< 10000; i++){
            System.out.println(i +" :: "+ lc.toString(i));
        }
        
    }

}
