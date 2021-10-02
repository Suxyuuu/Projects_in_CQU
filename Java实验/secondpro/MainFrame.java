/*
 *   新建文件夹/文件 √
 *   返回上一级     √
 *   打开          √
 *   删除          √
 *   复制          √
 *   移动          √
 *   退出          √
 *
 *   加密解密      √
 *   上传          √
 *   下载          √
 *   加入ip        √
 * */

package cqu.shiyan.secondpro;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.*;
import java.net.Socket;
import java.util.ArrayList;

import static java.lang.System.exit;
import static javax.swing.JFileChooser.DIRECTORIES_ONLY;

public class MainFrame extends JFrame {
    public MainFrame() throws HeadlessException {
    }

    public ArrayList<JButton> jbuttons = new ArrayList<>();
    private JPopupMenu popup;
    public String out_click_where;
    private DataInputStream fileReader;
    private DataOutputStream fileOut;
    private DataInputStream fileIn;


    public MainFrame(String path, String[] filenames) {
        //int filenum = filenames.size();
        setTitle(path);
        setSize(600, 400);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        FlowLayout fl = new FlowLayout();
        GridLayout gl = new GridLayout(10, 2);
        setLayout(gl);
        for (String filename : filenames) {
            JButton button = new JButton(filename);
            button.setSize(120, 160);
            //button.setLayout(gl);
            add(button);
            jbuttons.add(button);
        }

        //构建右键菜单
//        JPanel root=new JPanel();
//        this.setContentPane(root);
//        root.setLayout(new BorderLayout());

        JPopupMenu popup_create = new JPopupMenu();
        popup_create.add(createMenuItem("create", "新建文件夹/文件"));
        popup_create.add(createMenuItem("back", "返回上一级"));
        popup_create.addSeparator();
        popup_create.add(createMenuItem("upload", "上传文件"));
        popup_create.addSeparator();
        popup_create.add(createMenuItem("quit", "退出"));
        this.addMouseListener(new MouseAdapter() {

            @Override
            public void mouseClicked(MouseEvent e) {
                super.mouseClicked(e);
                if (e.getButton() == MouseEvent.BUTTON3) {
                    popup_create.show(e.getComponent(), e.getX(), e.getY());
                }
            }

        });
        //右键菜单
        popup = new JPopupMenu();
        popup.add(createMenuItem("enter", "打开"));
        popup.add(createMenuItem("delete", "删除"));
        popup.add(createMenuItem("copy", "复制"));
        popup.add(createMenuItem("move", "移动(剪切)"));
        popup.addSeparator();
        // todo
        popup.add(createMenuItem("encode", "加密"));
        popup.add(createMenuItem("decode", "解密"));
        popup.addSeparator();
        popup.add(createMenuItem("download", "下载到本地"));

        for (JButton jbutton : jbuttons) {
            jbutton.addMouseListener(new MouseAdapter() {
                String click_where = jbutton.getText();

                @Override
                public void mouseClicked(MouseEvent e) {
                    super.mouseClicked(e);
                    if (e.getButton() == MouseEvent.BUTTON3) {
                        popup.show(e.getComponent(), e.getX(), e.getY());
                        //click_where=e.getComponent().toString();
                        //System.out.println(click_where);
                        out_click_where = click_where;
                    }
                }
            });
        }

    }

    protected JMenuItem createMenuItem(String action, String text) {
        JMenuItem item = new JMenuItem(text);
        item.setActionCommand(action);
        item.addActionListener(actionListener);
        return item;
    }

    private ActionListener actionListener = new ActionListener() {
        public void actionPerformed(ActionEvent e) {

            String action = e.getActionCommand();
            if ("enter".equals(action)) {
                try {
                    listen_enter(out_click_where, Login.w, Login.r);
                } catch (IOException ex) {
                    ex.printStackTrace();
                }

            } else if ("create".equals(action)) {
                //JOptionPane.showMessageDialog(null, action);
                String filename = JOptionPane.showInputDialog(null,
                        "请输入要新建的文件夹名或文件名(若创建的是文件，请加上后缀)：\n", "新建文件夹/文件",
                        JOptionPane.PLAIN_MESSAGE, null, null, null).toString();
                //System.out.println(filename);
                try {
                    listen_create(filename, Login.w, Login.r);
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                JButton button = new JButton(filename);
                button.setSize(120, 160);
                //button.setLayout(gl);
                add(button);
                jbuttons.add(button);
                button.addMouseListener(new MouseAdapter() {
                    String click_where = button.getText();

                    @Override
                    public void mouseClicked(MouseEvent e) {
                        super.mouseClicked(e);
                        if (e.getButton() == MouseEvent.BUTTON3) {
                            popup.show(e.getComponent(), e.getX(), e.getY());
                            //click_where=e.getComponent().toString();
                            //System.out.println(click_where);
                            out_click_where = click_where;
                        }
                    }
                });

            } else if ("back".equals(action)) {
                try {
                    listen_enter("..", Login.w, Login.r);
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            } else if ("delete".equals(action)) {
                try {
                    listen_delete(out_click_where, Login.w, Login.r);
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                for (JButton jbutton : jbuttons) {
                    if (out_click_where.equals(jbutton.getText())) {
                        remove(jbutton);
                        jbuttons.remove(jbutton);
                        break;
                    }
                }
            } else if ("copy".equals(action)) {
                String dstpath = JOptionPane.showInputDialog(null,
                        "请输入目的路径：\n", "复制文件夹/文件",
                        JOptionPane.PLAIN_MESSAGE, null, null, null).toString();
                try {
                    listen_copy(out_click_where, dstpath, Login.w, Login.r);
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            } else if ("move".equals(action)) {
                String dstpath = JOptionPane.showInputDialog(null,
                        "请输入目的路径：\n", "移动文件夹/文件",
                        JOptionPane.PLAIN_MESSAGE, null, null, null).toString();
                try {
                    listen_move(out_click_where, dstpath, Login.w, Login.r);
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                for (JButton jbutton : jbuttons) {
                    if (out_click_where.equals(jbutton.getText())) {
                        remove(jbutton);
                        jbuttons.remove(jbutton);
                        break;
                    }
                }
            } else if ("upload".equals(action)) {
                try {
                    String newfilename = listen_upload(Login.w, Login.r);
                    if ("未选择文件".equals(newfilename)) {
                        JOptionPane.showMessageDialog(null, "您取消了上传");
                    } else {
                        JButton button = new JButton(newfilename);
                        button.setSize(120, 160);
                        //button.setLayout(gl);
                        add(button);
                        jbuttons.add(button);
                        button.addMouseListener(new MouseAdapter() {
                            String click_where = button.getText();

                            @Override
                            public void mouseClicked(MouseEvent e) {
                                super.mouseClicked(e);
                                if (e.getButton() == MouseEvent.BUTTON3) {
                                    popup.show(e.getComponent(), e.getX(), e.getY());
                                    //click_where=e.getComponent().toString();
                                    //System.out.println(click_where);
                                    out_click_where = click_where;
                                }
                            }
                        });
                    }
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            } else if ("download".equals(action)) {

                try {
                    listen_download(out_click_where, Login.w, Login.s, Login.r);
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            } else if ("encode".equals(action)) {
                try {
                    listen_encode(out_click_where, Login.w, Login.r);
                    //out_click_where.indexOf(".");
                    //out_click_where.substring(out_click_where.indexOf("."));
                    JButton button = new JButton(out_click_where.substring(0, out_click_where.indexOf(".")) + "_encode"
                            + out_click_where.substring(out_click_where.indexOf(".")));
                    button.setSize(120, 160);
                    //button.setLayout(gl);
                    add(button);
                    jbuttons.add(button);
                    button.addMouseListener(new MouseAdapter() {
                        String click_where = button.getText();

                        @Override
                        public void mouseClicked(MouseEvent e) {
                            super.mouseClicked(e);
                            if (e.getButton() == MouseEvent.BUTTON3) {
                                popup.show(e.getComponent(), e.getX(), e.getY());
                                //click_where=e.getComponent().toString();
                                //System.out.println(click_where);
                                out_click_where = click_where;
                            }
                        }
                    });
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            } else if ("decode".equals(action)) {
                try {
                    listen_decode(out_click_where, Login.w, Login.r);
                    JButton button = new JButton(out_click_where.substring(0, out_click_where.indexOf("_")) + "_decode"
                            + out_click_where.substring(out_click_where.indexOf(".")));
                    button.setSize(120, 160);
                    //button.setLayout(gl);
                    add(button);
                    jbuttons.add(button);
                    button.addMouseListener(new MouseAdapter() {
                        String click_where = button.getText();

                        @Override
                        public void mouseClicked(MouseEvent e) {
                            super.mouseClicked(e);
                            if (e.getButton() == MouseEvent.BUTTON3) {
                                popup.show(e.getComponent(), e.getX(), e.getY());
                                //click_where=e.getComponent().toString();
                                //System.out.println(click_where);
                                out_click_where = click_where;
                            }
                        }
                    });
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            } else if ("quit".equals(action)) {
                try {
                    Login.w.write("quit"+"\n");
                    Login.w.flush();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                try {
                    Login.w.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                try {
                    Login.r.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                try {
                    Login.s.close();
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
                Login.isconnected=false;
                exit(0);
            } else {
                JOptionPane.showMessageDialog(null, "意外的状况");
            }
            setVisible(false);
            setVisible(true);
        }
    };

    public void listen_enter(String filename, Writer w, BufferedReader r) throws IOException {
        if (!"..".equals(filename) && filename.contains(".") && filename.substring(filename.indexOf(".")).length()<=5) {
            JOptionPane.showMessageDialog(null, "普通用户无法直接查看文件，请下载后查看。");
        } else {
            w.write("cd " + filename + "\n");
            w.flush();
            String currentpath = Login.r.readLine();  //获取当前路径
            int filenum = Integer.parseInt(Login.r.readLine()); //获取当前目录下文件个数
            String[] filenames = new String[filenum];
            if (filenum > 0) {
                for (int i = 0; i < filenum; i++) {
                    filenames[i] = Login.r.readLine();
                    //System.out.println(filenames[i]);
                }
            } else {
                JOptionPane.showMessageDialog(null, "该文件夹为空");
            }
            setTitle(currentpath);
            for (JButton jbutton : jbuttons) {
                remove(jbutton);
            }
            jbuttons.clear();
            for (String file : filenames) {
                JButton button = new JButton(file);
                button.setSize(120, 160);
                //button.setLayout(gl);
                add(button);
                jbuttons.add(button);
            }
            for (JButton jbutton : jbuttons) {
                jbutton.addMouseListener(new MouseAdapter() {
                    String click_where = jbutton.getText();

                    @Override
                    public void mouseClicked(MouseEvent e) {
                        super.mouseClicked(e);
                        if (e.getButton() == MouseEvent.BUTTON3) {
                            popup.show(e.getComponent(), e.getX(), e.getY());
                            //click_where=e.getComponent().toString();
                            //System.out.println(click_where);
                            out_click_where = click_where;
                        }
                    }
                });
            }
        }

    }

    public void listen_create(String filename, Writer w, BufferedReader r) throws IOException {
        //System.out.println(Login.s.isClosed());
        w.write("mkdir " + filename + "\n");
        w.flush();
        //System.out.println("mkdir "+filename);
        String note = r.readLine();
        JOptionPane.showMessageDialog(null, note);
    }

    public void listen_delete(String filename, Writer w, BufferedReader r) throws IOException {
        w.write("del " + filename + "\n");
        w.flush();
        //System.out.println("mkdir "+filename);

    }

    public void listen_copy(String filename, String dstpath, Writer w, BufferedReader r) throws IOException {
        w.write("copy " + filename + " " + dstpath + "\n");
        w.flush();
    }

    public void listen_move(String filename, String dstpath, Writer w, BufferedReader r) throws IOException {
        w.write("move " + filename + " " + dstpath + "\n");
        w.flush();
    }

    public String listen_upload(Writer w, BufferedReader r) throws IOException {
        JFileChooser fileChooser = new JFileChooser();
        // 设置默认显示的文件夹
        fileChooser.setCurrentDirectory(new File("C:\\"));
        int result = fileChooser.showOpenDialog(this);  // 对话框将会尽量显示在靠近 parent 的中心
        // 点击确定
        if (result == JFileChooser.APPROVE_OPTION) {
            // 获取路径
            File file = fileChooser.getSelectedFile();
            //String path = file.getAbsolutePath();
            String filename = file.getName();
            w.write("upload " + filename + "\n");
            w.flush();

//            DataInputStream fileReader = new DataInputStream(new FileInputStream(file));
//            DataOutputStream fileOut = new DataOutputStream(Login.s.getOutputStream());
            fileReader = new DataInputStream(new FileInputStream(file));
            fileOut = new DataOutputStream(Login.s.getOutputStream());
            fileOut.writeLong(file.length());   //发送文件长度
            fileOut.flush();
            int length = -1;
            byte[] buff = new byte[1024];
            while ((length = fileReader.read(buff)) > 0) {  // 发送内容
                fileOut.write(buff, 0, length);
                fileOut.flush();
            }
            fileReader.close();
            //fileOut.close();
            String msg = r.readLine();
            JOptionPane.showMessageDialog(null, msg);
            //fileReader.close();
            //fileOut.close();
            fileOut.flush();
            return filename;
        }
        return "未选择文件";
    }

    public void listen_download(String filename, Writer w, Socket s, BufferedReader r) throws IOException {
        JFileChooser fileChooser = new JFileChooser();
        // 设置默认显示的文件夹
        fileChooser.setCurrentDirectory(new File("C:\\"));
        fileChooser.setFileSelectionMode(DIRECTORIES_ONLY);     //选择文件夹
        int result = fileChooser.showOpenDialog(this);  // 对话框将会尽量显示在靠近 parent 的中心
        // 点击确定
        if (result == JFileChooser.APPROVE_OPTION) {
            // 获取路径
            File filechoosed = fileChooser.getSelectedFile();
            //String path = file.getAbsolutePath();
            String path = filechoosed.getPath();
            System.out.println("path: " + path);
            w.write("download " + filename + "\n");
            w.flush();

//            DataInputStream fileIn = new DataInputStream(s.getInputStream());  // 输入流
            fileIn = new DataInputStream(s.getInputStream());
            File file = new File(path + "\\" + filename);
            DataOutputStream fileWriter = new DataOutputStream(new FileOutputStream(file));
            //fileWriter = new DataOutputStream(new FileOutputStream(file));

            int length = -1;
            byte[] buff = new byte[1024];
            long curLength = 0;
            //fileIn.reset();
            //int total=fileIn.readInt();
            //System.out.println(total);
            long totleLength = fileIn.readLong();
            System.out.println(totleLength);
            while ((length = fileIn.read(buff)) > 0) {  // 把文件写进本地
                fileWriter.write(buff, 0, length);
                fileWriter.flush();
                curLength += length;
                if (curLength == totleLength) {  // 强制结束
                    break;
                }
            }
            //fileIn.close();
            //String msg = r.readLine();
            JOptionPane.showMessageDialog(null, "下载完成！");
            fileWriter.close();
        }
    }

    public void listen_encode(String filename, Writer w, BufferedReader r) throws IOException {
        String key = JOptionPane.showInputDialog(null,
                "请输入密钥：\n", "加密文件",
                JOptionPane.PLAIN_MESSAGE, null, null, null).toString();
        w.write("encode " + filename+" "+key + "\n");
        w.flush();
        String msg = r.readLine();
        JOptionPane.showMessageDialog(null, msg);
    }

    public void listen_decode(String filename, Writer w, BufferedReader r) throws IOException {
        String key = JOptionPane.showInputDialog(null,
                "请输入密钥：\n", "解密文件",
                JOptionPane.PLAIN_MESSAGE, null, null, null).toString();
        w.write("decode " + filename+" "+key + "\n");
        w.flush();
        String msg = r.readLine();
        JOptionPane.showMessageDialog(null, msg);
    }

}
