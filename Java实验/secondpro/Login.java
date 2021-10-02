package cqu.shiyan.secondpro;


import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;
import java.net.Socket;


public class Login extends JFrame {

    private JLabel ipLabel = new JLabel("Server Ip:");
    private JLabel userLabel = new JLabel("User:");
    private JLabel passwordLabel = new JLabel("Password:");

    private JTextField ip_text = new JTextField(20);
    private JTextField id_text = new JTextField(20);
    private JTextField psd_text = new JTextField(20);
    private JButton login_button = new JButton("Log in");
    private JButton regist_button =new JButton("Register");

    private String id, psd,ip;
    public static boolean isconnected;
    //public static String instruction;
    public static Socket s;

    void connection(String ip){
        try {
            s = new Socket(ip, 1111);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static Writer w;

    void connection_w() {
        try {
            w = new OutputStreamWriter(s.getOutputStream());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static BufferedReader r;

    void connection_r() {
        try {
            r = new BufferedReader(new InputStreamReader(s.getInputStream()));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public Login() throws IOException {
        setTitle("MyCloud File Manager");
        setSize(600, 400);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(null);

        ipLabel.setBounds(180, 90, 80, 30);
        add(ipLabel);
        userLabel.setBounds(180, 140, 80, 30);
        add(userLabel);
        passwordLabel.setBounds(180, 190, 80, 30);
        add(passwordLabel);

        ip_text.setBounds(260, 90, 160, 30);
        add(ip_text);
        id_text.setBounds(260, 140, 160, 30);
        add(id_text);
        psd_text.setBounds(260, 190, 160, 30);
        add(psd_text);

        regist_button.setBounds(180, 250, 100, 30);
        add(regist_button);
        login_button.setBounds(310, 250, 100, 30);
        add(login_button);
        regist_button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                Register register=new Register();
                register.setVisible(true);
            }
        });
        login_button.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent event) {
                setId(id_text.getText());
                setPsd(psd_text.getText());
                setIp(ip_text.getText());
                try {
                    connection(ip);
                    connection_r();
                    connection_w();
                    w.write(id + "\n");
                    w.write(psd + "\n");
                    w.flush();
                    String hello = r.readLine();
                    if ('H' == hello.charAt(0)) {
                        JOptionPane.showMessageDialog(null, hello);
                        dispose();
                        isconnected=true;
                        after_login();

                    } else {
                        JOptionPane.showMessageDialog(null, hello);
                        isconnected=false;
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    public void after_login() throws IOException {
        if (Login.isconnected){
            String currentpath=Login.r.readLine();  //获取当前路径
            //System.out.println(currentpath);
            int filenum=Integer.parseInt(Login.r.readLine()); //获取当前目录下文件个数
            //System.out.println(filenum);
            String[] filenames = new String[filenum];
            if (filenum>0){
                for (int i = 0; i < filenum; i++) {
                    filenames[i]=Login.r.readLine();
                    //System.out.println(filenames[i]);
                }
            }
            else{
                JOptionPane.showMessageDialog(null, "该文件夹为空");
            }
            MainFrame mainframe=new MainFrame(currentpath,filenames);
            mainframe.setVisible(true);
        }
        else {
            Login.w.close();
            Login.r.close();
            Login.s.close();
        }
    }

    public boolean isIsconnected() {
        return isconnected;
    }

    public void setIsconnected(boolean isconnected) {
        this.isconnected = isconnected;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPsd() {
        return psd;
    }

    public void setPsd(String psd) {
        this.psd = psd;
    }

    public Socket getS() {
        return s;
    }

    public void setS(Socket s) {
        this.s = s;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }
}
