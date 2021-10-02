package cqu.shiyan.secondpro;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class Register extends JFrame {
    private JLabel ipLabel = new JLabel("Name:");
    private JLabel userLabel = new JLabel("Password:");
    private JTextField ip_text = new JTextField(20);
    private JTextField id_text = new JTextField(20);
    private JButton login_button = new JButton("Register");

    private String id,ip;

    public Register(){
        setTitle("REGISTER");
        setSize(600, 400);
        setLocationRelativeTo(null);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(null);

        ipLabel.setBounds(180, 90, 80, 30);
        add(ipLabel);
        userLabel.setBounds(180, 140, 80, 30);
        add(userLabel);
        ip_text.setBounds(260, 90, 160, 30);
        add(ip_text);
        id_text.setBounds(260, 140, 160, 30);
        add(id_text);
        login_button.setBounds(250, 250, 100, 30);
        add(login_button);

        login_button.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                if (id_text.getText()!=null && ip_text.getText()!=null){
                    setId(id_text.getText());
                    setIp(ip_text.getText());
                    File user =new File("user.txt");
                    try {
                        FileWriter fw=new FileWriter("user.txt",true);
                        fw.write(ip+" "+id+"\n");
                        fw.flush();
                        fw.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    JOptionPane.showMessageDialog(null, "Register successful!");
                    dispose();
                } else{
                    JOptionPane.showMessageDialog(null, "用户名和密码不得为空!");
                }

            }
        });

    }

    public static void main(String[] args) {
        Register r=new Register();
        r.setVisible(true);
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }
}
