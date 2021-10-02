package cqu.shiyan.secondpro;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Objects;

import static java.lang.System.exit;


public class Server {

    public static DataInputStream fileReader;
    public static DataOutputStream fileOut;
    public static DataInputStream fileIn;

    public static void main(String[] args) throws IOException {

        String path = "D:\\MyCloud\\";
        String instruction = "";
        ServerSocket ss = new ServerSocket(1111);
        while (true) {
            Socket s = ss.accept();
            Writer w = new OutputStreamWriter(s.getOutputStream());
            BufferedReader r = new BufferedReader(new InputStreamReader(s.getInputStream()));
            boolean flag = check_user(w, r);
            if (flag) {
                list_directory(w, path);
                while (true) {
                    instruction = r.readLine();
                    //System.out.println(instruction);
                    if (instruction != null) {
                        String[] divided_instru = instruction.split(" ");
                        if ("ls".equals(divided_instru[0])) {
                            list_directory(w, path);
                            System.out.println(" ");
                        } else if ("cd".equals(divided_instru[0])) {
                            path = enter_directory(w, path, divided_instru[1]);
                        } else if ("mkdir".equals(divided_instru[0])) {
                            create_directory(w, path, divided_instru[1]);
                        } else if ("del".equals(divided_instru[0])) {
                            File file = new File(path + divided_instru[1]);
                            delete_directory(file);
                            //System.out.println("deleted");
                        } else if ("copy".equals(divided_instru[0])) {
                            copy_directory(path + divided_instru[1], divided_instru[2] + '\\' + divided_instru[1]);
                        } else if ("move".equals(divided_instru[0])) {
                            move_directory(path + divided_instru[1], divided_instru[2] + '\\' + divided_instru[1]);
                        } else if ("upload".equals(divided_instru[0])) {
                            upload_file(divided_instru[1], path, s, w);
                        } else if ("download".equals(divided_instru[0])) {
                            download_file(divided_instru[1], path, s, w);
                        } else if ("encode".equals(divided_instru[0])) {
                            encode_file(w, path, divided_instru[1], divided_instru[2]);
                        } else if ("decode".equals(divided_instru[0])) {
                            decode_file(w, path, divided_instru[1], divided_instru[2]);
                        } else if ("quit".equals(divided_instru[0])) {
                            exit(0);
                        } else {
                            System.out.println("can't execute");
                            w.write("can't execute\n");
                            //w.flush();
                            System.out.println(" ");
                        }
                    }
                }

            } else {
                w.write("psd error\n");
            }
            w.flush();
            w.close();
            r.close();
            s.close();
        }


    }

    public static String enter_directory(Writer w, String current_path, String newdir) throws IOException {
        if ("..".equals(newdir)) {
            String[] s = current_path.split("\\\\");
            StringBuilder newpath = new StringBuilder();
            for (int i = 0; i < s.length - 1; i++) {
                newpath.append(s[i]).append("\\");
            }
            list_directory(w, newpath.toString());
            return newpath.toString();
        } else {
            list_directory(w, current_path + newdir + "\\");
            return current_path + newdir + "\\";
        }

    }

    public static void list_directory(Writer w, String dir) throws IOException {
        w.write(dir + "\n");
        File[] flist = new File(dir).listFiles();
        if (flist != null) {
            w.write(Objects.requireNonNull(new File(dir).listFiles()).length + "\n");
            w.flush();
            for (File file : flist) {
                w.write(file.getName() + "\n");
            }
        } else {
            w.write("0" + "\n");
        }
        w.flush();
    }

    public static void create_directory(Writer w, String current_path, String filename) throws IOException {
        File file = new File(current_path + filename);
        char[] letter = filename.toCharArray();
        int flag = 0;
        //判断文件夹or文件
        for (char a : letter) {
            if (a == '.') {
                flag = 1;
                break;
            }
        }
        //创建
        if (flag == 1) {
            if (file.createNewFile()) {
                //System.out.println("created new file");
                w.write("created new file" + "\n");
                w.flush();
            }
        } else {
            if (file.mkdir()) {
                //System.out.println("created new folder");
                w.write("created new folder" + "\n");
                w.flush();
            }
        }

    }

    public static void delete_directory(File path) {
        if (path.isFile() || path.list().length == 0) {
            path.delete();
        } else for (File f : path.listFiles()) {
            delete_directory(f); // 递归删除每一个文件
        }
        path.delete(); // 删除文件夹
    }

    //复制文件夹
    public static void copy_directory(String srcpath, String dstpath) throws IOException {
        if (new File(srcpath).isFile()) {
            File sourceFile = new File(srcpath);
            // 目标文件
            File targetFile = new File(dstpath);
            copyfile(sourceFile, targetFile);
        } else {
            if (!new File(dstpath).exists()) {
                new File(dstpath).mkdir();
            }
            File[] file = (new File(srcpath)).listFiles();

            for (int i = 0; i < file.length; i++) {
                if (file[i].isFile()) {
                    // 源文件
                    File sourceFile = file[i];
                    // 目标文件
                    File targetFile = new File(dstpath + File.separator + sourceFile.getName());
                    copyfile(sourceFile, targetFile);
                }

                if (file[i].isDirectory()) {
                    // 准备复制的源文件夹
                    String dir1 = srcpath + File.separator + file[i].getName();
                    // 准备复制的目标文件夹
                    String dir2 = dstpath + File.separator + file[i].getName();
                    copy_directory(dir1, dir2);
                }
            }
        }
    }

    //复制单个文件
    public static void copyfile(File srcfile, File dstfile) throws IOException {
        FileInputStream input = new FileInputStream(srcfile);
        // 新建文件输出流并对它进行缓冲
        FileOutputStream out = new FileOutputStream(dstfile);
        BufferedOutputStream outbuff = new BufferedOutputStream(out);
        // 缓冲数组
        byte[] b = new byte[1024];
        int len = 0;
        while ((len = input.read(b)) != -1) {
            outbuff.write(b, 0, len);
        }
        //关闭文件
        outbuff.close();
        input.close();
    }

    public static void move_directory(String srcpath, String dstpath) throws IOException {
        copy_directory(srcpath, dstpath);
        File file = new File(srcpath);
        delete_directory(file);
    }

    public static void upload_file(String filename, String currentpath, Socket s, Writer w) throws IOException {
        fileIn = new DataInputStream(s.getInputStream());
        File file = new File(currentpath + filename);
        DataOutputStream fileWriter = new DataOutputStream(new FileOutputStream(file));
        int length = -1;
        byte[] buff = new byte[1024];
        long curLength = 0;
        long totleLength = fileIn.readLong();
        //System.out.println(totleLength);
        while ((length = fileIn.read(buff)) > 0) {  // 把文件写进本地
            fileWriter.write(buff, 0, length);
            fileWriter.flush();
            curLength += length;
            if (curLength == totleLength) {  // 强制结束
                break;
            }
        }
        //fileIn.close();
        fileWriter.close();
        w.write("上传成功！\n");
        w.flush();
        //fileIn.close();
    }

    public static void download_file(String filename, String currentpath, Socket s, Writer w) throws IOException {
        System.out.println(filename);
        File file = new File(currentpath + filename);
        System.out.println(currentpath + filename);
        System.out.println(file.length());
//        DataInputStream fileReader = new DataInputStream(new FileInputStream(file));
//        DataOutputStream fileOut = new DataOutputStream(Login.s.getOutputStream());
        fileReader = new DataInputStream(new FileInputStream(file));
        fileOut = new DataOutputStream(s.getOutputStream());
        fileOut.writeLong(file.length());   //发送文件长度
        //w.write(String.valueOf(file.length()));
        //w.flush();
        //System.out.println(file.length());
        fileOut.flush();

        int length = -1;
        byte[] buff = new byte[1024];
        while ((length = fileReader.read(buff)) > 0) {  // 发送内容
            fileOut.write(buff, 0, length);
            fileOut.flush();
        }
        fileReader.close();
//        fileOut.close();
    }

    public static void encode_file(Writer w, String current_path, String filename, String key) throws IOException {
//        File srcfile=new File(current_path+filename);
//        FileInputStream input = new FileInputStream(srcfile);
//
//        // 新建文件输出流并对它进行缓冲
//        String newfilename=srcfile.getName().substring(0,srcfile.getName().indexOf("."))+"_encode"
//                +srcfile.getName().substring(srcfile.getName().indexOf("."));
//        File dstfile=new File(current_path+newfilename);
//
//        FileOutputStream out = new FileOutputStream(dstfile);
//        BufferedOutputStream outbuff = new BufferedOutputStream(out);
//
//        // 缓冲数组
//        byte[] b = new byte[1024];
//        //byte[] c;
//        String s;
//        int len = 0;
//        while ((len = input.read(b)) != -1) {
//            //c=Base64.getEncoder().encode(Arrays.toString(b).replace("\r\n", "").getBytes());
//            s= DesTool.encrypt(new String(b),key);
//            assert s != null;
//            outbuff.write(s.getBytes(), 0, len);
//        }
//
//        //关闭文件
//        outbuff.close();
//        input.close();
//        out.close();
        File srcfile = new File(current_path + filename);
        String newfilename = srcfile.getName().substring(0, srcfile.getName().indexOf(".")) + "_encode"
                + srcfile.getName().substring(srcfile.getName().indexOf("."));
        BufferedReader br = new BufferedReader(new FileReader(current_path + filename));
        FileWriter fw = new FileWriter(current_path + newfilename);

        String line = br.readLine();
        String newline;
        while (line != null) {
            newline = DesTool.encrypt(line, key);
            assert newline != null;
            fw.write(newline);
            fw.flush();
            line = br.readLine();
        }

        w.write("加密成功！" + "\n");
        w.flush();
    }

    public static void decode_file(Writer w, String current_path, String filename, String key) throws IOException {
//        File srcfile=new File(current_path+filename);
//        FileInputStream input = new FileInputStream(srcfile);
//
//        // 新建文件输出流并对它进行缓冲
//        String newfilename=srcfile.getName().substring(0,srcfile.getName().indexOf("_"))
//                    +"_decode"+srcfile.getName().substring(srcfile.getName().indexOf("."));
//        File dstfile=new File(current_path+newfilename);
//
//        FileOutputStream out = new FileOutputStream(dstfile);
//        BufferedOutputStream outbuff = new BufferedOutputStream(out);
//
//        // 缓冲数组
//        byte[] b = new byte[1024];
//        //byte[] c;
//        String s;
//        int len = 0;
//        while ((len = input.read(b)) != -1) {
//            //c=Base64.getDecoder().decode(Arrays.toString(b).getBytes());
//            //s=Base64Strategy.decode(.replaceAll("\n","").replaceAll("\r",""));
//            s=DesTool.decrypt(new String(b),key);
//            assert s != null;
//            outbuff.write(s.getBytes(), 0, len);
//        }
//        System.out.println("jiemijieshu");
//        //关闭文件
//        outbuff.close();
//        input.close();
//        out.close();
        File srcfile = new File(current_path + filename);
        String newfilename = srcfile.getName().substring(0, srcfile.getName().indexOf("_"))
                + "_decode" + srcfile.getName().substring(srcfile.getName().indexOf("."));
        BufferedReader br = new BufferedReader(new FileReader(current_path + filename));
        FileWriter fw = new FileWriter(current_path + newfilename);

        String line = br.readLine();
        String newline;
        while (line != null) {
            newline = DesTool.decrypt(line, key);
            assert newline != null;
            fw.write(newline);
            fw.flush();
            line = br.readLine();
        }
        w.write("解密成功！" + "\n");
        w.flush();
    }

    public static boolean check_user(Writer w, BufferedReader r) throws IOException {
        /*Writer w = new OutputStreamWriter(s.getOutputStream());
        BufferedReader r = new BufferedReader(new InputStreamReader(s.getInputStream()));*/
        String name = r.readLine();
        String psd = r.readLine();
        BufferedReader br = new BufferedReader(new FileReader("user.txt"));
        String line = br.readLine();
        while (line != null) {
            String[] inf = line.split(" ");
            if (name.equals(inf[0]) && psd.equals(inf[1])) {
                w.write("Hello, " + name + "\n");
                w.flush();
                return true;
            }
            line = br.readLine();
        }
        return false;

    }

}
