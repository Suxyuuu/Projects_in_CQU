package cqu.shiyan.firstpro;

public class Department {
    private String D_id;
    private String dname;
    private String managername;

    public Department() {
    }

    public Department(String d_id, String dname) {
        D_id = d_id;
        this.dname = dname;
    }

    public String getD_id() {
        return D_id;
    }

    public void setD_id(String d_id) {
        D_id = d_id;
    }

    public String getDname() {
        return dname;
    }

    public void setDname(String dname) {
        this.dname = dname;
    }

    public String getManagername() {
        return managername;
    }

    public void setManagername(String managername) {
        this.managername = managername;
    }
}
