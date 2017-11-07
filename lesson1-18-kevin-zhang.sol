pragma solidity ^0.4.14;

contract Payroll {
    uint salary = 1 ether;
    address employeeAddress;
    address employerAddress = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
    uint constant payDuration = 30 days;
    uint lastPayday = now;

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() {
        if(msg.sender != employeeAddress) {
            revert();
        }
        uint nextPayday = lastPayday + payDuration;
        if(nextPayday > now) {
            revert();
        }
        lastPayday = nextPayday;
        employeeAddress.send(salary);
    }

    function updateEmployee(address newEmployee, uint newSalary) {
        if(msg.sender != employerAddress) {
            revert();
        }
        if(newEmployee == 0x0) {
            revert();
        }
        if(newSalary == 0) {
            revert();
        }
        employeeAddress = newEmployee;
        salary = newSalary;
        lastPayday = now;
    }
}
