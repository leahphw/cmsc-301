#ifndef __PROJECT1_CPP__
#define __PROJECT1_CPP__

#include "project1.h"
#include <vector>
#include <string>
#include <map>
#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[])
{
    if (argc < 4) // Checks that at least 3 arginstpents are given in command line
    {
        std::cerr << "Expected Usage:\n ./assemble infile1.asm infile2.asm ... infilek.asm staticmem_outfile.bin instructions_outfile.bin\n"
                  << std::endl;
        exit(1);
    }
    // Prepare output files
    std::ofstream instruction_out, static_out;

    // Map for label names
    std::unordered_map<std::string, int> labels = {};
    // Map for static label names
    std::unordered_map<int, std::string> static_labels = {};
    // Vector storing all instructions
    std::vector<std::string> instructions = {};
    // Count tracker variable
    int count = 0;
    std::vector<int> static_memory = {};
    std::vector<std::string> static_lines = {};

    /**
     * Phase 1:
     * Rstead all instructions, clean them of comments and whitespace DONE
     * TODO: Determine the ninstpbers for all static memory labels
     * (measured in bytes starting at 0)
     * TODO: Determine the line ninstpbers of all instruction line labels
     * (measured in instructions) starting at 0
     */

    // Boolean trackers to add static member
    int start_static_label = -1;
    int end_static_label = 0;
    int semicolon = -1;
    // For each input file:
    for (int i = 1; i < argc - 2; i++)
    {
        std::ifstream infile(argv[i]); // Open the input file for reading
        if (!infile)
        { // If file can't be opened, need to let the user know
            std::cerr << "Error: could not open file: " << argv[i] << std::endl;
            exit(1);
        }

        std::string str;
        while (getline(infile, str))
        {                     // Read a line from the file
            str = clean(str); // Remove comments and whitespace
            start_static_label = str.find(".word");
            semicolon = str.find(":");
            if (str == "")
            { // Ignore empty lines
                continue;
            }
            else if (str == ".text" || str == ".data" || str == ".globl main" || str == ".align 2")
            {
                continue;
            }
            else if (start_static_label < str.length())
            {
                static_lines.push_back(str);
            }
            else if (semicolon < str.length())
            {
                if (end_static_label == 0)
                {
                    end_static_label = 1;
                    std::string end_static_str = "end";
                    labels[end_static_str] = count;
                }
                std::string s = str.substr(0, semicolon);
                labels[s] = count;
            }
            else
            {
                if (end_static_label == 0)
                {
                    end_static_label = 1;
                    std::string end_static_str = "end";
                    labels[end_static_str] = count;
                }
                instructions.push_back(str);
                count++;
            }
        }
    }

    /** Phase 2
     * Process all static memory, output to static memory file
     * TODO: All of this
     */

    static_out.open(argv[argc - 2], std::ios::binary);  
    int bytes_count = 0;
    for (std::string a : static_lines)
    {
        std::vector<std::string> temp = split(a, WHITESPACE);
        static_labels[bytes_count * 4] = temp[0];
        for (int k = 2; k < temp.size(); k++)
        {
            bool find = false;
            // Load a * 4
            for (auto x : labels)
            {
                if (x.first == temp[k])
                {
                    static_memory.push_back((x.second) * 4);
                    find = true;
                    break;
                }
            }
            if (!find)
            {
                static_memory.push_back(std::stoi(temp[k]));
            }
            bytes_count++;
        }
    }
    for (int a : static_memory)
    {
        int len_0 = 32 - to_string(a).length();
        int result = a;
        for (int i = len_0; i < 32; i++)
        {
            result += (0 << i);
        }
        write_binary(result, static_out);
    }

    /** Phase 3
     * Process all instructions, output to instruction memory file
     * TODO: Almost all of this, it only works for adds
     */

    instruction_out.open(argv[argc - 1], std::ios::binary);
    int curr_line = 0;

    for (std::string inst : instructions)
    {
        int space = inst.find(" ");
        std::string inst_type = inst.substr(0, space);
        std::string inst_type1 = inst.substr(space + 1);
        int space1 = inst_type1.find(" ");

        if (inst_type == "add" || inst_type == "slt" || inst_type == "sub" || inst_type == "mult" || inst_type == "div" || inst_type == "mflo" || inst_type == "mfhi" || inst_type == "jr")
        {
            write_binary(encode_R(inst.substr(space + 1), inst_type), instruction_out);
        }
        else if (inst_type == "addi" || inst_type == "sll" || inst_type == "srl")
        {
            write_binary(encode_Ri(inst.substr(space + 1), inst_type), instruction_out);
        }
        else if (inst_type == "lw" || inst_type == "sw")
        {
            write_binary(encode_lw(inst.substr(space + 1), inst_type), instruction_out);
        }
        else if (inst_type == "beq" || inst_type == "bne")
        {
            write_binary(encode_branch(inst.substr(space + 1), inst_type, labels, curr_line), instruction_out);
        }
        else if (inst_type == "j" || inst_type == "jal")
        {
            write_binary(encode_j(inst.substr(space + 1), inst_type, labels), instruction_out);
        }
        else if (inst_type == "jalr")
        {
            write_binary(encode_jalr(inst.substr(space + 1), inst_type), instruction_out);
        }
        else if (inst_type == "la")
        {
            write_binary(encode_la(inst.substr(space + 1), inst_type, static_labels), instruction_out);
        }
        else if (inst_type == "syscall")
        {
            int t = 53260;
            write_binary(t, instruction_out);
        }
        curr_line++;
    }
}

int encode_R(const std::string &inst, std::string instp)
{
    std::vector<std::string> reg_list = split(inst, WHITESPACE + ",");
    if (instp == "add")
    {
        return encode_Rtype(0, registers[reg_list[1]], registers[reg_list[2]], registers[reg_list[0]], 0, 32);
    }
    else if (instp == "sub")
    {
        return encode_Rtype(0, registers[reg_list[1]], registers[reg_list[2]], registers[reg_list[0]], 0, 34);
    }
    else if (instp == "mult")
    {
        return encode_Rtype(0, registers[reg_list[0]], registers[reg_list[1]], 0, 0, 24);
    }
    else if (instp == "div")
    {
        return encode_Rtype(0, registers[reg_list[0]], registers[reg_list[1]], 0, 0, 26);
    }
    else if (instp == "mflo")
    {
        return encode_Rtype(0, 0, 0, registers[reg_list[0]], 0, 18);
    }
    else if (instp == "mfhi")
    {
        return encode_Rtype(0, 0, 0, registers[reg_list[0]], 0, 16);
    }
    else if (instp == "slt")
    {
        return encode_Rtype(0, registers[reg_list[1]], registers[reg_list[2]], registers[reg_list[0]], 0, 42);
    }
    else if (instp == "jr")
    {
        return encode_Rtype(0, registers[reg_list[0]], 0, 0, 0, 8);
    }
    return 0;
}

int encode_Ri(const std::string &inst, std::string instp)
{
    std::vector<std::string> reg_list = split(inst, WHITESPACE + ",");
    if (instp == "addi")
    {
        int imm = stoi(reg_list[2]);
        return encode_Itype(8, registers[reg_list[0]], (imm), registers[reg_list[1]]);
    }
    else if (instp == "sll")
    {
        return encode_Stype(0, registers[reg_list[0]], stoi(reg_list[2]), registers[reg_list[1]], 0);
    }
    else if (instp == "srl")
    {
        return encode_Stype(0, registers[reg_list[0]], stoi(reg_list[2]), registers[reg_list[1]], 2);
    }
    return 0;
}

int encode_la(const std::string &inst, std::string instp, std::unordered_map<int, std::string> static_labels)
{
    std::vector<std::string> reg_list = split(inst, WHITESPACE + "," + "(");
    for (auto x : static_labels)
    {
        int a = x.second.find(":");
        std::string str = x.second.substr(0, a);
        if (str == reg_list[1])
        {
            return (8 << 26) + (0 << 21) + (registers[reg_list[0]] << 16) + (x.first);
        }
    }
    return 0;
}

int encode_lw(const std::string &inst, std::string instp)
{
    std::vector<std::string> reg_list = split(inst, WHITESPACE + "," + "(");
    if (instp == "lw")
    {
        return encode_Itype(35, registers[reg_list[0]], stoi(reg_list[1]), registers[reg_list[2].substr(0, reg_list[2].find(")"))]);
    }
    else if (instp == "sw")
    {
        return encode_Itype(43, registers[reg_list[0]], stoi(reg_list[1]), registers[reg_list[2].substr(0, reg_list[2].find(")"))]);
    }
    return 0;
}

int encode_branch(const std::string &inst, std::string instp, std::unordered_map<std::string, int> labels, int ln)
{
    std::vector<std::string> reg_list = split(inst, WHITESPACE + ",");
    int num_inst_func = labels.find(reg_list[2])->second;
    num_inst_func = num_inst_func - ln - 1;

    if (num_inst_func < 0)
    {
        num_inst_func = 65535 & num_inst_func;
    }
    if (instp == "beq")
    {
        return encode_Btype(4, registers[reg_list[0]], registers[reg_list[1]], num_inst_func);
    }
    else if (instp == "bne")
    {
        return encode_Btype(5, registers[reg_list[0]], registers[reg_list[1]], num_inst_func);
    }
    return 0;
}

int encode_j(const std::string &inst, std::string instp, std::unordered_map<std::string, int> labels)
{
    std::vector<std::string> reg_list = split(inst, WHITESPACE + ",");
    int num_inst_func = (labels.find(reg_list[0])->second);
    if (instp == "j")
    {
        return encode_Jtype(2, num_inst_func);
    }
    else if (instp == "jal")
    {
        return encode_Jtype(3, num_inst_func);
    }
    return 0;
}

int encode_jalr(const std::string &inst, std::string instp)
{
    std::vector<std::string> reg_list = split(inst, WHITESPACE + ",");
    if (reg_list.size() > 1)
    {
        return encode_others(0, registers[reg_list[0]], registers[reg_list[1]], 9);
    }
    else
    {
        return encode_others(0, registers[reg_list[0]], registers["$ra"], 9);
    }
    return 0;
}
#endif