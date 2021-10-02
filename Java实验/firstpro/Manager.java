package cqu.shiyan.firstpro;

public class Manager extends Employee {
    private String renzhistart;      // 经理任职开始时间
    private int renzhitime;         // 经理任职时长

    public Manager() {
    }

    public Manager(String eid, String name, String sex, int age, String ruzhitime, double salary, String renzhistart, int renzhitime) {
        super(eid, name, sex, age, ruzhitime, salary);
        this.renzhistart = renzhistart;
        this.renzhitime = renzhitime;
    }

    public String getRenzhistart() {
        return renzhistart;
    }

    public void setRenzhistart(String renzhistart) {
        this.renzhistart = renzhistart;
    }

    public int getRenzhitime() {
        return renzhitime;
    }

    public void setRenzhitime(int renzhitime) {

        this.renzhitime = renzhitime;
    }
}
