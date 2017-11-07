pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint payDuration = 10 seconds;
    address owner;
    Employee[] employees;
    uint totalSalary = 0;

    function Payroll() {
        owner = msg.sender;
    }

    function _particalPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }

    function _findEmployee(address employeeId) private returns (Employee, uint) {
        for(uint i=0; i<employees.length; i++) {
            if(employees[i].id == employeeId) {
                return (employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        employees.push(Employee(employeeId, salary * 1 ether, now));
        totalSalary += salary * 1 ether;
    }

    function removeEmployee(address employeeId) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _particalPaid(employee);
        totalSalary -= employee.salary;
        delete employees[index];
        employees[index] = employees[employees.length-1];
        employees.length -= 1;
    }

    function updateEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _particalPaid(employee);
        totalSalary -= employee.salary;
        employee.salary = salary * 1 ether;
        totalSalary += employee.salary;
        employee.lastPayday = now;
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);
        employee.lastPayday = nextPayday;
        employee.id.send(employee.salary);
    }
}

/*
10 test accounts:
    0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
    0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db
    0x583031d1113ad414f02576bd6afabfb302140225
    0xdd870fa1b7c4700f2bd7f44238821c26f7392148
    0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db
    0xca35b7d915458ef540ade6068dfe2f44e8fa733c

account:
start with 100 ethers

create contract,
    transaction cost 	768432 gas
    execution cost 	546204 gas

add fund 50 ether

add employee 0x1111
transaction cost 	104054 gas
 execution cost 	82334 gas

runway 50
 transaction cost 	22966 gas
 execution cost 	1694 gas

add employee 0x2222
transaction cost 	89895 gas
 execution cost 	68175 gas

runway 25
transaction cost 	23747 gas
 execution cost 	2475 gas

add employee 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
 transaction cost 	91888 gas
 execution cost 	69016 gas

runway 16
 transaction cost 	24528 gas
 execution cost 	3256 gas

add employee 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db
transaction cost 	25309 gas
 execution cost 	4037 gas

runway 12
transaction cost 	25309 gas
 execution cost 	4037 gas

add employee 0x583031d1113ad414f02576bd6afabfb302140225
 transaction cost 	93570 gas
 execution cost 	70698 gas

runway 10
transaction cost 	26090 gas
 execution cost 	4818 gas
*/

/*
after optimization:

add 100 ether

add employee 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, 1

runway 100
 transaction cost 	22124 gas
 execution cost 	852 gas

add employee 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db

runway 50
 transaction cost 	22124 gas
 execution cost 	852 gas

add employee 0x583031d1113ad414f02576bd6afabfb302140225

runway 33
transaction cost 	22124 gas
 execution cost 	852 gas

add employee 0xdd870fa1b7c4700f2bd7f44238821c26f7392148

runway 25
 transaction cost 	22124 gas
 execution cost 	852 gas
*/