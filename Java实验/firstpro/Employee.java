package cqu.shiyan.firstpro;

public class Employee {
    private String E_id;     // 雇员工号
    private String name;    // 雇员姓名
    private String sex;     //雇员性别
    private int age;        //雇员年龄
    private String ruzhitime;   //雇员入职时间
    private double salary;     //雇员工资
    private String department;  //所处部门

    public Employee() {
    }

    // 构造时不加入部门，构造后通过调用方法设定部门
    public Employee(String eid, String name, String sex, int age, String ruzhitime, double salary) {
        this.E_id = eid;
        this.name = name;
        this.sex = sex;
        this.age = age;
        this.ruzhitime = ruzhitime;
        this.salary = salary;
    }

    public String getE_id() {
        return E_id;
    }

    public void setE_id(String e_id) {
        this.E_id = e_id;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        if ("男".equals(sex)|| "女".equals(sex)){
            this.sex = sex;
        }
        else {
            System.out.println("您输入的性别有误，请重新输入");
        }

    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getRuzhitime() {
        return ruzhitime;
    }

    public void setRuzhitime(String ruzhitime) {
        this.ruzhitime = ruzhitime;
    }

    public double getSalary() {
        return salary;
    }

    public void setSalary(double salary) {
        this.salary = salary;
    }
}
