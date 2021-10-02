package cqu.shiyan.secondpro;

import javafx.stage.DirectoryChooser;
import javafx.stage.Stage;

import javax.sound.midi.SoundbankResource;
import java.io.*;
import java.util.Scanner;

public class test {
    public static void main(String[] args) throws IOException {
//        Scanner sc=new Scanner(System.in);
//        String id=sc.nextLine();
//        String psd=sc.nextLine();
//        System.out.println(id);
//        System.out.println(psd);
//        System.out.println("cd "+"..");
        File srcfile=new File("C:\\Users\\Suxyuuu\\Desktop\\input_encode.txt");
        System.out.println(srcfile.getName().substring(-1));
        System.out.println(srcfile.getName());
        System.out.println(srcfile.getName().indexOf("."));
        System.out.println(srcfile.getName().indexOf("_"));
        System.out.println(srcfile.getName().substring(srcfile.getName().indexOf(".")));
        System.out.println(srcfile.getName().substring(0,srcfile.getName().indexOf("."))+"_encode"+srcfile.getName().substring(srcfile.getName().indexOf(".")));
        System.out.println(srcfile.getName().substring(0,srcfile.getName().indexOf("_"))+"_decode"+srcfile.getName().substring(srcfile.getName().indexOf(".")));
//        System.out.println(srcfile.getPath());
//        System.out.println(srcfile.getAbsolutePath());
//        System.out.println(srcfile.getAbsoluteFile());
//        System.out.println(srcfile.getParent());

    }
}
