#ifndef __PROJECT1_H__
#define __PROJECT1_H__

#include <math.h>
#include <string>
#include <vector>
#include <unordered_map>
#include <iostream>
#include <sstream>
#include <map>
#include <fstream>

const std::string WHITESPACE = " \n\r\t\f\v";

// Remove all whitespace from the left of the string
std::string ltrim(const std::string &s)
{
    size_t start = s.find_first_not_of(WHITESPACE);
    return (start == std::string::npos) ? "" : s.substr(start);
}

// Remove all whitespace from the right of the string
std::string rtrim(const std::string &s)
{
    size_t end = s.find_last_not_of(WHITESPACE);
    return (end == std::string::npos) ? "" : s.substr(0, end + 1);
}

std::vector<std::string> split(const std::string &s, const std::string &split_on)
{
    std::vector<std::string> split_terms;
    int cur_pos = 0;
    while (cur_pos >= 0)
    {
        int new_pos = s.find_first_not_of(split_on, cur_pos);
        cur_pos = s.find_first_of(split_on, new_pos);
        split_terms.push_back(s.substr(new_pos, cur_pos - new_pos));
    }
    return split_terms;
}

// Remove all comments and leading/trailing whitespace
std::string clean(const std::string &s)
{
    return rtrim(ltrim(s.substr(0, s.find('#'))));
}

void write_binary(int value, std::ofstream &outfile)
{
    // std::cout << std::hex << value << std::endl; //Useful for debugging
    outfile.write((char *)&value, sizeof(int));
}

// Helper functions for family encoding

void encode_instruction(const std::string &instruction);

int encode_R(const std::string &instruction, std::string instp);

int encode_Ri(const std::string &instructions, std::string instp);

int encode_la(const std::string &inst, std::string instp, std::unordered_map<int, std::string> static_labels);

int encode_lw(const std::string &inst, std::string instp);

int encode_branch(const std::string &inst, std::string instp, std::unordered_map<std::string, int> labels, int cur);

int encode_j(const std::string &inst, std::string instp, std::unordered_map<std::string, int> labels);

int encode_jalr(const std::string &inst, std::string instp);

// R-type
int encode_Rtype(int opcode, int rs, int rt, int rd, int shftamt, int funccode)
{
    return (opcode << 26) + (rs << 21) + (rt << 16) + (rd << 11) + (shftamt << 6) + funccode;
}

// I-type
int encode_Itype(int opcode, int rt, int imm, int rs)
{
    if (imm < 0)
    {
        int j = 65536;
        imm = j + imm;
    }
    return (opcode << 26) + (rs << 21) + (rt << 16) + (imm);
}

// S-type refers to the shift operations
int encode_Stype(int opcode, int rt, int imm, int rs, int funccode)
{
    return (opcode << 26) + (rs << 16) + (rt << 11) + (imm << 6) + funccode;
}

// Load instructions
int encode_Ltype(int opcode, int rt, int rs, int off)
{
    return (opcode << 26) + (rs << 16) + (rt << 11) + off;
}

// B-type refers to branches
int encode_Btype(int opcode, int rt, int rs, int off)
{
    return (opcode << 26) + (rt << 21) + (rs << 16) + off;
}

// J-type for jumps
int encode_Jtype(int opcode, int off)
{
    return (opcode << 26) + off;
}

// Only for jalr
int encode_others(int opcode, int rs, int rd, int funccode)
{
    return (opcode << 26) + (rs << 21) + (0 << 16) + (rd << 11) + (0 << 6) + funccode;
}

static std::unordered_map<std::string, int> registers{
    {"$r0", 0}, {"$0", 0}, {"zero", 0}, {"$at", 1}, {"$1", 1}, {"$v0", 2}, {"$2", 2}, {"$v1", 3}, {"$3", 3}, {"$a0", 4}, {"$4", 4}, {"$a1", 5}, {"$5", 5}, {"$a2", 6}, {"$6", 6}, {"$a3", 7}, {"$7", 7}, {"$t0", 8}, {"$8", 8}, {"$t1", 9}, {"$9", 9}, {"$t2", 10}, {"$10", 10}, {"$t3", 11}, {"$11", 11}, {"$t4", 12}, {"$12", 12}, {"$t5", 13}, {"$13", 13}, {"$t6", 14}, {"$14", 14}, {"$t7", 15}, {"$15", 15}, {"$s0", 16}, {"$16", 16}, {"$s1", 17}, {"$17", 17}, {"$s2", 18}, {"$18", 18}, {"$s3", 19}, {"$19", 19}, {"$s4", 20}, {"$20", 20}, {"$s5", 21}, {"$21", 21}, {"$s6", 22}, {"$22", 22}, {"$s7", 23}, {"$23", 23}, {"$t8", 24}, {"$24", 24}, {"$t9", 25}, {"$25", 25}, {"$k0", 26}, {"$26", 26}, {"$k1", 27}, {"$27", 27}, {"$gp", 28}, {"$28", 28}, {"$sp", 29}, {"$29", 29}, {"$s8", 30}, {"$30", 30}, {"$ra", 31}, {"$31", 31}};

#endif