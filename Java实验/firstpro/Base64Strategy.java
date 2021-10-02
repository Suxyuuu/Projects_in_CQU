package cqu.shiyan.firstpro;
/*
* 用base64来加密
* */

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Base64;

public class Base64Strategy {
    public static String encode(String src) {
        byte[] encodeBytes = Base64.getEncoder().encode(src.getBytes());
        return new String(encodeBytes);
    }

    public static String decode(String src) {
        byte[] decodeBytes = Base64.getDecoder().decode(src.getBytes());
        return new String(decodeBytes);
    }

    public static void main(String[] args) throws IOException {
        FileWriter fw = new FileWriter("D:/export_test_decode.txt");
        fw.write(encode("Employee：(工号 姓名 性别 年龄 工资 入职时间 所在部门)")+"\n");
        fw.write(encode("Employee：(工号 姓名 性别 年龄 工资 入职时间 所在部门)")+"\n");
        fw.close();
        BufferedReader br = new BufferedReader (new FileReader("D:/export_test_decode.txt"));
        String line=br.readLine();
        while(line != null){
            System.out.println(decode(line));
            line = br.readLine();
        }
        br.close();

    }

}
