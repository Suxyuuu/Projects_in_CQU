package cqu.shiyan.firstpro;
/*
 * 初始化功能 √
 * 添加功能 √
 * 删除功能 √
 * 查询功能 √   【可以查询员工或者部门信息】【没有完成检索功能 输入部门名可以输出所有该部门的员工】
 * 导出功能 √   【加密输出完成】 【使用base64加密 该功能可选】
 * 导入功能 √   【加密导入完成】 【导入格式需要与导出格式一致，若加密则需加密方式相同】
 *
 * */

import java.io.*;
import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;

public class Operate {

    public static void main(String[] args) throws IOException {
        Scanner sc = new Scanner(System.in);
        System.out.println("系统启功....");
        System.out.println("开始初始化.....");
        System.out.println("请输入您想要的员工(包括经理)个数：");
        int Member_num = sc.nextInt();
        System.out.println("请输入您想要的经理个数：");
        int Manager_num = sc.nextInt();

        // 以下生成部门
        ArrayList<Department> dpm_array = new ArrayList<>();      // 里面装部门
        for (int i = 0; i < Manager_num; i++) {
            Department dpm = new Department("BM" + i, "部门" + i);
            dpm_array.add(dpm);
        }


        // 以下生成员工（包括经理）
        ArrayList<Employee> employees = new ArrayList<>();      // 里面装员工
        for (int i = 0; i < Member_num; i++) {
            // 此编号方式默认员工个数不超过1000
            String E_id;
            if (i < 10) {
                E_id = "00" + i;
            } else if (i < 100) {
                E_id = "0" + i;
            } else {
                E_id = "" + i;
            }
            // 随机生成性别
            String sex;
            Random rd = new Random();
            if (rd.nextInt(1000) % 2 == 0) {
                sex = "男";
            } else {
                sex = "女";
            }
            // 随机生成入职时间
            String year = "" + (rd.nextInt(5) + 2015);
            String month = "" + (rd.nextInt(12) + 1);
            String ruzhinianyue = year + "." + month;
            // 随机生成工资
            int salary = (rd.nextInt(20) + 30) * 100;

            Employee m = new Employee(E_id, "员工" + i, sex, rd.nextInt(25) + 20, ruzhinianyue, salary);

            // 随机生成部门
            int bumen = rd.nextInt(Manager_num);
            m.setDepartment(dpm_array.get(bumen).getDname());
            employees.add(m);
        }

        // 以下生成经理【随机在员工中挑选n个作为经理，且保证部门不同】
        ArrayList<Manager> managers = new ArrayList<>();      // 里面装经理
        int j = 0;
        do {
            Random rd = new Random();
            int index = rd.nextInt(Member_num - Manager_num);
            int count = 0;
            for (Manager value : managers) {
                if (employees.get(index).getDepartment().equals(value.getDepartment())) {
                    count++;
                }
            }
            if (count == 0) {
                String Manager_id = employees.get(index).getE_id();
                String Manager_name = employees.get(index).getName();
                String Manger_sex = employees.get(index).getSex();
                int Manager_age = employees.get(index).getAge();
                String ruzhitime = employees.get(index).getRuzhitime();
                double salary = employees.get(index).getSalary();
                // 随机生成任职开始时间
                String year = "" + (rd.nextInt(5) + 2015);
                String month = "" + (rd.nextInt(12) + 1);
                String renzhistart = year + "." + month;
                // 生成随机任职时长（单位：月）
                int renzhitime = rd.nextInt(24);

                Manager manager = new Manager(Manager_id, Manager_name, Manger_sex, Manager_age, ruzhitime, salary, renzhistart, renzhitime);
                manager.setDepartment(employees.get(index).getDepartment());
                employees.remove(index);
                managers.add(manager);

                j++;
            }


        } while (j < Manager_num);

        // 将部门与经理匹配
        for (Department department : dpm_array) {
            String dname = department.getDname();
            for (Manager manager : managers) {
                if (dname.equals(manager.getDepartment())) {
                    department.setManagername(manager.getName());
                    break;
                }
            }
        }
        System.out.println("初始化成功！");
        System.out.println(" ");

        //操作提示
        System.out.println("使用说明：   [使用时去除中括号] ");
        System.out.println("    help --> 展示使用说明");
        System.out.println("    show --> 展示所有部门、经理、员工名单");
        System.out.println("    add [工号] [姓名] [性别] [入职时间] [部门] [年龄] [工资]");
        System.out.println("        --> 添加新的员工 例：add 001 员工1 男 2019.10 部门0 20 1000.0");
        System.out.println("    delete [工号]");
        System.out.println("        --> 删除已有员工 例：delete 001");
        System.out.println("    search_dept [部门编号或部门名]");
        System.out.println("        --> 查询某部门信息 例: search_dept 部门0");
        System.out.println("    search_emp [员工姓名或工号]");
        System.out.println("        --> 查询某员工信息 例: search_emp 001");
        System.out.println("    search_all [部门编号或部门名]");
        System.out.println("        --> 查询某部门内所有员工信息 例: search_all 部门0");
        System.out.println("    import_encoded [文件路径]");
        System.out.println("        --> 导入加密过的数据 例: import_encoded D:/export_encoded.txt");
        System.out.println("    import_noencode [文件路径]");
        System.out.println("        --> 导入未加密过的数据 例: import_noencode D:/export.txt");
        System.out.println("    export_encoded [文件路径]");
        System.out.println("        --> 加密导出数据 例: export_encoded D:/export_encoded.txt");
        System.out.println("    export_noencode [文件路径]");
        System.out.println("        --> 不加密导出数据 例: export_noencode D:/export.txt");
        System.out.println("    quit --> 退出系统");
        System.out.println(" ");

        // 循环执行等待操作码
        while (true) {
            System.out.print("User:\\instruction>:");
            Scanner sca = new Scanner(System.in);
            String instru = sca.nextLine();

            if (instru != null) {
                String[] divided_instru = instru.split(" ");
                if ("show".equals(divided_instru[0])) {
                    op_show(dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("add".equals(divided_instru[0])) {
                    op_add(divided_instru, dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("delete".equals(divided_instru[0])) {
                    op_delete(divided_instru, dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("search_dept".equals(divided_instru[0])) {
                    search_department(divided_instru, dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("search_emp".equals(divided_instru[0])) {
                    search_employee(divided_instru, dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("search_all".equals(divided_instru[0])) {
                    search_employee_inonedeapartment(divided_instru, dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("import_encoded".equals(divided_instru[0])) {
                    import_withcipher(divided_instru[1], dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("import_noencode".equals(divided_instru[0])) {
                    import_nocipher(divided_instru[1], dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("export_encoded".equals(divided_instru[0])) {
                    export_withcipher(divided_instru[1], dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("export_noencode".equals(divided_instru[0])) {
                    export_nocipher(divided_instru[1], dpm_array, employees, managers);
                    System.out.println(" ");
                } else if ("quit".equals(divided_instru[0])) {
                    break;
                } else if ("help".equals(divided_instru[0])) {
                    System.out.println("使用说明：   [使用时去除中括号] ");
                    System.out.println("    help --> 展示使用说明");
                    System.out.println("    show --> 展示所有部门、经理、员工名单");
                    System.out.println("    add [工号] [姓名] [性别] [入职时间] [部门] [年龄] [工资]");
                    System.out.println("        --> 添加新的员工 例：add 001 员工1 男 2019.10 部门0 20 1000.0");
                    System.out.println("    delete [工号]");
                    System.out.println("        --> 删除已有员工 例：delete 001");
                    System.out.println("    search_dept [部门编号或部门名]");
                    System.out.println("        --> 查询某部门信息 例: search_dept 部门0");
                    System.out.println("    search_emp [员工姓名或工号]");
                    System.out.println("        --> 查询某员工信息 例: search_emp 001");
                    System.out.println("    search_all [部门编号或部门名]");
                    System.out.println("        --> 查询某部门内所有员工信息 例: search_all 部门0");
                    System.out.println("    import_encoded [文件路径]");
                    System.out.println("        --> 导入加密过的数据 例: import_encoded D:/export_encoded.txt");
                    System.out.println("    import_noencode [文件路径]");
                    System.out.println("        --> 导入未加密过的数据 例: import_noencode D:/export.txt");
                    System.out.println("    export_encoded [文件路径]");
                    System.out.println("        --> 加密导出数据 例: export_encoded D:/export_encoded.txt");
                    System.out.println("    export_noencode [文件路径]");
                    System.out.println("        --> 不加密导出数据 例: export_noencode D:/export.txt");
                    System.out.println("    quit --> 退出系统");
                    System.out.println(" ");
                } else {
                    System.out.println("无法识别的指令。");
                    System.out.println(" ");
                }
            }
        }


    }


    public static void op_show(ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) {
        System.out.println("    以下是部门名单：");
        for (Department department : dpm_array) {
            System.out.println("        部门编号：" + department.getD_id() + " 部门名称：" + department.getDname() + " 部门经理："
                    + department.getManagername());
        }
        System.out.println("    以下是经理名单：");
        for (Manager manager : managers) {
            System.out.println("        " + manager.getDepartment() + ": " + manager.getE_id() + " " + manager.getName() + " " + manager.getSex()
                    + " " + manager.getAge() + " 工资：" + manager.getSalary() + " 入职时间：" + manager.getRuzhitime() + " 任职时间："
                    + manager.getRenzhistart() + " 任职时长：" + manager.getRenzhitime() + "(个月)");
        }
        System.out.println("    以下是员工名单：");
        for (Employee emp : employees) {
            System.out.println("        " + emp.getE_id() + " " + emp.getName() + " " + emp.getSex() + " " + emp.getAge() + " 工资：" + emp.getSalary()
                    + " 入职时间：" + emp.getRuzhitime() + " " + emp.getDepartment());
        }
    }

    public static void op_add(String[] information, ArrayList<Department> departments, ArrayList<Employee> employees, ArrayList<Manager> managers) {

        Employee e = new Employee(information[1], information[2], information[3], Integer.parseInt(information[6]), information[4], Double.parseDouble(information[7]));
        e.setDepartment(information[5]);
        employees.add(e);
        System.out.println("    添加成功！");

    }

    public static void op_delete(String[] number, ArrayList<Department> departments, ArrayList<Employee> employees, ArrayList<Manager> managers) {
        int flag = 0;     // 判断删除的是否是经理
        for (int i = 0; i < employees.size(); i++) {
            if (number[1].equals(employees.get(i).getE_id())) {
                employees.remove(i);
                flag += 1;
                break;
            }
        }
        if (flag == 0) {
            // flag为0 表明该员工为经理
            String name = "";
            for (int i = 0; i < managers.size(); i++) {
                if (number[1].equals(managers.get(i).getE_id())) {
                    name = managers.get(i).getName();
                    managers.remove(i);
                    break;
                }
            }
            for (Department department : departments) {
                if (name.equals(department.getManagername())) {
                    department.setManagername(null);
                }
            }
        }
        System.out.println("    删除成功！");

    }

    public static void search_department(String[] information, ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) {
        String inf = information[1];
        int flag = 0;
        for (Department department : dpm_array) {
            if (department.getD_id().equals(inf)) {
                System.out.println("    查询结果：");
                System.out.println("        部门编号：" + department.getD_id() + " 部门名称：" + department.getDname() + " 部门经理："
                        + department.getManagername());
                flag += 1;
                break;
            }
            if (department.getDname().equals(inf)) {
                System.out.println("    查询结果：");
                System.out.println("        部门编号：" + department.getD_id() + " 部门名称：" + department.getDname() + " 部门经理："
                        + department.getManagername());
                flag += 1;
                break;
            }
        }
        if (flag == 0) {
            System.out.println("    查询无结果。");
        }
    }

    public static void search_employee(String[] information, ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) {
        String inf = information[1];
        int flag = 0;
        System.out.println("    查询结果：");
        for (Employee emp : employees) {
            if (emp.getE_id().equals(inf)) {
                System.out.println("        此员工为普通员工，详细信息如下：");
                System.out.println("            " + emp.getE_id() + " " + emp.getName() + " " + emp.getSex() + " " + emp.getAge() + " 工资：" + emp.getSalary()
                        + " 入职时间：" + emp.getRuzhitime() + " " + emp.getDepartment());
                flag += 1;
                break;
            }
            if (emp.getName().equals(inf)) {
                System.out.println("        此员工为普通员工，详细信息如下：");
                System.out.println("            " + emp.getE_id() + " " + emp.getName() + " " + emp.getSex() + " " + emp.getAge() + " 工资：" + emp.getSalary()
                        + " 入职时间：" + emp.getRuzhitime() + " " + emp.getDepartment());
                flag += 1;
            }
        }
        if (flag == 0) {
            for (Manager manager : managers) {
                if (manager.getE_id().equals(inf)) {
                    System.out.println("        此员工为经理，详细信息如下：");
                    System.out.println("            " + manager.getDepartment() + ": " + manager.getE_id() + " " + manager.getName() + " " + manager.getSex()
                            + " " + manager.getAge() + " 工资：" + manager.getSalary() + " 入职时间：" + manager.getRuzhitime() + " 任职时间："
                            + manager.getRenzhistart() + " 任职时长：" + manager.getRenzhitime() + "(个月)");
                    flag += 1;
                    break;
                }
                if (manager.getName().equals(inf)) {
                    System.out.println("        此员工为经理，详细信息如下：");
                    System.out.println("            " + manager.getDepartment() + ": " + manager.getE_id() + " " + manager.getName() + " " + manager.getSex()
                            + " " + manager.getAge() + " 工资：" + manager.getSalary() + " 入职时间：" + manager.getRuzhitime() + " 任职时间："
                            + manager.getRenzhistart() + " 任职时长：" + manager.getRenzhitime() + "(个月)");
                    flag += 1;
                }
            }
        }
        if (flag == 0) {
            System.out.println("        查询无结果。");
        }

    }

    public static void search_employee_inonedeapartment(String[] information, ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) {
        String inf = information[1];
        int flag = 0;
        for (Department department : dpm_array) {
            if (department.getD_id().equals(inf)) {
                String departmentname = department.getDname();
                System.out.println("    查询结果：");
                for (Employee employee : employees) {
                    if (employee.getDepartment().equals(departmentname)) {
                        System.out.println("        " + employee.getDepartment() + " " + employee.getE_id() + " " + employee.getName() + " " + employee.getSex() + " " + employee.getAge() + " 工资：" + employee.getSalary()
                                + " 入职时间：" + employee.getRuzhitime());
                    }
                }
                flag += 1;
                break;
            }
            if (department.getDname().equals(inf)) {
                System.out.println("    查询结果：");
                for (Employee employee : employees) {
                    if (employee.getDepartment().equals(inf)) {
                        System.out.println("        " + employee.getDepartment() + " " + employee.getE_id() + " " + employee.getName() + " " + employee.getSex() + " " + employee.getAge() + " 工资：" + employee.getSalary()
                                + " 入职时间：" + employee.getRuzhitime());
                    }
                }
                flag += 1;
                break;
            }
        }
        if (flag == 0) {
            System.out.println("    查询无结果。");
        }
    }

    public static void import_withcipher(String path, ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(path));
        String line = br.readLine();
        while (line != null) {
            line = Base64Strategy.decode(line);
            if (line.substring(0, 3).equals("Emp")) {
                line = br.readLine();
                line = Base64Strategy.decode(line);
                while (!line.substring(0, 3).equals("Man")) {
                    String[] inf = line.split(" ");
                    Employee employee = new Employee(inf[0], inf[1], inf[2], Integer.parseInt(inf[3]), inf[5], Double.parseDouble(inf[4]));
                    employee.setDepartment(inf[6]);
                    employees.add(employee);
                    line = br.readLine();
                    line = Base64Strategy.decode(line);
                }
            }
            if (line.substring(0, 3).equals("Man")) {
                line = br.readLine();
                line = Base64Strategy.decode(line);
                while (!line.substring(0, 3).equals("Dep")) {
                    String[] inf = line.split(" ");
                    Manager manager = new Manager(inf[1], inf[2], inf[3], Integer.parseInt(inf[4]), inf[6], Double.parseDouble(inf[5]), inf[7], Integer.parseInt(inf[8]));
                    manager.setDepartment(inf[0]);
                    managers.add(manager);
                    line = br.readLine();
                    line = Base64Strategy.decode(line);
                }
            }
            if (line.substring(0, 3).equals("Dep")) {
                line = br.readLine();
                line = Base64Strategy.decode(line);
            }
            String[] inf = line.split(" ");
            Department department = new Department(inf[0], inf[1]);
            department.setManagername(inf[2]);
            dpm_array.add(department);

            line = br.readLine();
        }
        br.close();
        System.out.println("    导入成功！");
    }

    public static void import_nocipher(String path, ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(path));
        String line = br.readLine();
        while (line != null) {
            if (line.substring(0, 3).equals("Emp")) {
                line = br.readLine();
                while (!line.substring(0, 3).equals("Man")) {
                    String[] inf = line.split(" ");
                    Employee employee = new Employee(inf[0], inf[1], inf[2], Integer.parseInt(inf[3]), inf[5], Double.parseDouble(inf[4]));
                    employee.setDepartment(inf[6]);
                    employees.add(employee);
                    line = br.readLine();
                }
            }
            if (line.substring(0, 3).equals("Man")) {
                line = br.readLine();
                while (!line.substring(0, 3).equals("Dep")) {
                    String[] inf = line.split(" ");
                    Manager manager = new Manager(inf[1], inf[2], inf[3], Integer.parseInt(inf[4]), inf[6], Double.parseDouble(inf[5]), inf[7], Integer.parseInt(inf[8]));
                    manager.setDepartment(inf[0]);
                    managers.add(manager);
                    line = br.readLine();
                }
            }
            if (line.substring(0, 3).equals("Dep")) {
                line = br.readLine();
            }
            String[] inf = line.split(" ");
            Department department = new Department(inf[0], inf[1]);
            department.setManagername(inf[2]);
            dpm_array.add(department);

            line = br.readLine();
        }
        br.close();
        System.out.println("    导入成功！");
    }

    public static void export_nocipher(String path, ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) throws IOException {
        FileWriter fw = new FileWriter(path);
        //fw.write("Employee：(工号 姓名 性别 年龄 工资 入职时间 所在部门)\n");
        fw.write("Employee:" + "\n");
        for (Employee emp : employees) {
            fw.write(emp.getE_id() + " " + emp.getName() + " " + emp.getSex() + " " + emp.getAge() + " " + emp.getSalary()
                    + " " + emp.getRuzhitime() + " " + emp.getDepartment() + "\n");
        }
        //fw.write("Manager：(负责部门 工号 姓名 性别 年龄 工资 入职时间 任职时间 任期/月)\n");
        fw.write("Manager:" + "\n");
        for (Manager manager : managers) {
            fw.write(manager.getDepartment() + " " + manager.getE_id() + " " + manager.getName() + " " + manager.getSex()
                    + " " + manager.getAge() + " " + manager.getSalary() + " " + manager.getRuzhitime() + " "
                    + manager.getRenzhistart() + " " + manager.getRenzhitime() + "\n");
        }
        //fw.write("Department:（部门编号 部门名 部门经理）\n");
        fw.write("Department:" + "\n");
        for (Department department : dpm_array) {
            fw.write(department.getD_id() + " " + department.getDname() + " "
                    + department.getManagername());
        }
        //fw.write(dpm_array.get(0).getD_id()+" "+dpm_array.get(0).getDname()+" "+managers.get(0).getAge());
        fw.close();
        System.out.println("    导出成功！路径为：" + path);
    }

    public static void export_withcipher(String path, ArrayList<Department> dpm_array, ArrayList<Employee> employees, ArrayList<Manager> managers) throws IOException {
        FileWriter fw = new FileWriter(path);
        fw.write(Base64Strategy.encode("Employee:") + "\n");
        for (Employee emp : employees) {
            fw.write(Base64Strategy.encode(emp.getE_id() + " " + emp.getName() + " " + emp.getSex() + " " + emp.getAge() + " " + emp.getSalary()
                    + " " + emp.getRuzhitime() + " " + emp.getDepartment()) + "\n");
        }
        fw.write(Base64Strategy.encode("Manager:") + "\n");
        for (Manager manager : managers) {
            fw.write(Base64Strategy.encode(manager.getDepartment() + " " + manager.getE_id() + " " + manager.getName() + " " + manager.getSex()
                    + " " + manager.getAge() + " " + manager.getSalary() + " " + manager.getRuzhitime() + " "
                    + manager.getRenzhistart() + " " + manager.getRenzhitime()) + "\n");
        }
        fw.write(Base64Strategy.encode("Department:") + "\n");
        for (Department department : dpm_array) {
            fw.write(Base64Strategy.encode(department.getD_id() + " " + department.getDname() + " "
                    + department.getManagername()) + "\n");
        }
        fw.close();
        System.out.println("    导出成功！路径为：" + path);

    }

}
