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


int main(int argc, char* argv[]) {
    if (argc < 4) // Checks that at least 3 arguments are given in command line
    {
        std::cerr << "Expected Usage:\n ./assemble infile1.asm infile2.asm ... infilek.asm staticmem_outfile.bin instructions_outfile.bin\n" << std::endl;
        exit(1);
    }
    //Prepare output files
    std::ofstream inst_outfile, static_outfile;
    static_outfile.open(argv[argc - 2], std::ios::binary);
    inst_outfile.open(argv[argc - 1], std::ios::binary);
    std::vector<std::string> instructions;

    /**
     * Phase 1:
     * Read all instructions, clean them of comments and whitespace DONE
     * TODO: Determine the numbers for all static memory labels
     * (measured in bytes starting at 0)
     * TODO: Determine the line numbers of all instruction line labels
     * (measured in instructions) starting at 0
    */
    // After the "Phase 1:" comment and before the for loop:
    std::unordered_map<std::string, int> static_mem_labels; // Stores the byte offset for static memory labels
    std::unordered_map<std::string, int> instruction_labels;     // Stores the instruction number for instruction labels
    std::vector<std::vector<std::string>> static_info;

   // Number of processed instructions
int instructionCounter = 0; 
// Byte offset for the static memory
int staticOffset = 0; 

// For each provided assembly file:
for (int i = 1; i < argc - 2; i++) {
    ifstream asmFile(argv[i]); 
    if (!asmFile) {
        cerr << "Error: Unable to open file: " << argv[i] << endl;
        exit(1);
    }

    string currentLine;
    while (getline(asmFile, currentLine)) {
        currentLine = clean(currentLine);
        if (currentLine.empty()) {
            continue;
        }

        // Processing static memory segment
        if (currentLine == ".data") {
            string staticLine;

            // Iterate over each line in the static memory segment
            while (getline(asmFile, staticLine)) {
                staticLine = clean(staticLine);
                if (staticLine.empty()) {
                    continue;
                }
                if (staticLine == ".text") {
                    break; // End of the static memory segment
                }
                
                vector<string> staticComponents = split(staticLine, WHITESPACE + ":");
                static_info.push_back(staticComponents);

                // Label-to-offset mapping for static memory
                static_mem_labels[staticComponents[0]] = staticOffset;
                // Assuming 4 bytes for each .word directive
                staticOffset += (staticComponents.size() - 2) * 4; 
            }
            continue;
        }

        // Ignoring other directives
        if (currentLine[0] == '.') { 
            continue;
        }

        // Processing labels within the code
        // if (currentLine.find(":") != string::npos) { 
        //     string label = currentLine.substr(0, currentLine.size() - 1);
        //     instruction_labels[label] = instructionCounter;
        //     continue;
        // }

        if (currentLine.back() == ':') {
            string label = currentLine.substr(0, currentLine.size()-1);
            instruction_labels[label] = instructionCounter;
            continue;
}


        // Store the instruction for further processing
        instructions.push_back(currentLine);
        instructionCounter++;
    }
    asmFile.close();
}
 
// Convert static memory directives to binary format
for (const vector<string>& staticEntry : static_info) {
    for (int i = 2; i < staticEntry.size(); i++) {
        // If the static memory directive references a label, retrieve the label's address
        if (instruction_labels.find(staticEntry[i]) != instruction_labels.end()) {
            int address = instruction_labels[staticEntry[i]] * 4;
            write_binary(address, static_outfile);
        } 
        // //If the static memory references a string, store the string values
        // else if(staticEntry[i] == ".asciiz"){
        // }
        else {
            // Directly write the numeric value to the binary file
            write_binary(stoi(staticEntry[i]), static_outfile);
        }
    }
}

    //InstructionCounter != Line#
    /** Phase 3
     * Process all instructions, output to instruction memory file
     * TODO: Almost all of this, it only works for adds
     */
    int line_number = 0; //Track what line each command is on
    for(std::string inst : instructions) {
        std::vector<std::string> terms = split(inst, WHITESPACE+",()");
        std::string inst_type = terms[0];
        //used built in stoi() to translate strings from the files into integer inputs
        if (inst_type == "add") {
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 32),inst_outfile);
        }
        else if (inst_type == "sll"){
            write_binary(encode_Rtype(0, 0 , registers[terms[2]], registers[terms[1]], stoi(terms[3]), 0), inst_outfile);
        }
        else if (inst_type == "srl"){
            write_binary(encode_Rtype(0, 0 , registers[terms[2]], registers[terms[1]], stoi(terms[3]), 2), inst_outfile);
        }
        else if (inst_type == "mult"){
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 24), inst_outfile);
        }
        else if (inst_type == "mflo"){
            write_binary(encode_Rtype(0, 0, 0, registers[terms[1]],0, 18), inst_outfile);
        }
        else if(inst_type == "mfhi"){
            write_binary(encode_Rtype(0, 0, 0,registers[terms[1]],0, 16), inst_outfile);
        }
        else if(inst_type == "div"){
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 0, 0, 26), inst_outfile);
        }
        else if(inst_type == "slt"){
            write_binary(encode_Rtype(0, registers[terms[2]],registers[terms[3]],registers[terms[1]],0,42), inst_outfile);
        }
        else if (inst_type == "addi"){
            int16_t immediate = static_cast<int16_t>(stoi(terms[3]));
            write_binary(encode_Itype(8, registers[terms[2]], registers[terms[1]], static_cast<uint16_t>(immediate)), inst_outfile);
        }
        // else if (inst_type == "addi"){
        //     if (stoi(terms[3]) >= 0){//check if immediate is positive or negative
        //     write_binary(encode_Itype(8, registers[terms[2]],registers[terms[1]], stoi(terms[3])), inst_outfile);
        //     }
        //     else{ //flip to compliment if negative
        //     write_binary(encode_Itype(8, registers[terms[2]],registers[terms[1]], stoi(terms[3]) + 65536), inst_outfile);
        //     }
        // }
        else if(inst_type == "sub"){
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 34), inst_outfile);
        }
        else if(inst_type == "beq"){
            int line_offset = instruction_labels[terms[3]] - line_number - 1;
            int16_t offset = static_cast<int16_t>(line_offset);
            write_binary(encode_Itype(4, registers[terms[1]], registers[terms[2]], static_cast<uint16_t>(offset)), inst_outfile);
        }
        
        else if(inst_type == "bne"){
            int line_offset = instruction_labels[terms[3]] - line_number - 1;
            int16_t offset = static_cast<int16_t>(line_offset);
            write_binary(encode_Itype(5, registers[terms[1]], registers[terms[2]], static_cast<uint16_t>(offset)), inst_outfile);
        }
        // else if(inst_type == "bne"){
        //     int line_offset = (instruction_labels[terms[3]] - line_counter);
        //     if (line_offset < 0) { //flip offset to compliment if negative
        //         write_binary(encode_Itype(5, registers[terms[1]], registers[terms[2]], line_offset + 65536 - 1), inst_outfile);
        //     }
        //     else {
        //         write_binary(encode_Itype(5, registers[terms[1]], registers[terms[2]], line_offset - 1), inst_outfile);
        //     }
        // }
        else if(inst_type =="lw"){
            int16_t immediate = static_cast<int16_t>(stoi(terms[2]));
            write_binary(encode_Itype(35, registers[terms[3]], registers[terms[1]], static_cast<uint16_t>(immediate)), inst_outfile);
        }
        else if(inst_type == "sw"){
            int16_t immediate = static_cast<int16_t>(stoi(terms[2]));
            write_binary(encode_Itype(43, registers[terms[3]], registers[terms[1]], static_cast<uint16_t>(immediate)), inst_outfile);
        }
        else if(inst_type == "j"){
            write_binary(encode_Jtype(2, instruction_labels[terms[1]]), inst_outfile);
        }
        else if(inst_type == "jal"){
            write_binary(encode_Jtype(3, instruction_labels[terms[1]]), inst_outfile);
        }
        else if(inst_type == "jr"){
            write_binary(encode_Rtype(0, registers[terms[1]], 0, 0, 0, 8), inst_outfile);
        }
        else if(inst_type == "jalr"){
             write_binary(encode_Rtype(0, registers[terms[1]], 0, 31, 0, 9), inst_outfile);
         }
        else if(inst_type == "syscall")
        {
            write_binary(encode_Rtype(0, 0, 0, 26, 0, 12), inst_outfile);
        }
        else if (inst_type == "la") {
            int static_address = static_mem_labels[terms[2]]; //load the static memory location of inserted variable 
            write_binary(encode_Itype(8, 0, registers[terms[1]], static_address), inst_outfile);
        }
        else if ((inst_type == "move") || (inst_type == "mov")) {
            int sourceRegister = registers[terms[2]];
            int destinationRegister = registers[terms[1]];
            write_binary(encode_Rtype(0, 0, sourceRegister, destinationRegister, 0, 32), inst_outfile);
        }
        // li $s0, 12 # loads integer into register
        // same as addi
        else if (inst_type == "li") {
        int destinationRegister = registers[terms[1]];
        int immediateValue = stoi(terms[2]);  // Convert the immediate value from string to integer
        write_binary(encode_Itype(8, 0, destinationRegister, immediateValue), inst_outfile);
        }
        // sge rd, rs, rt # $rd is 1 if s1 >= s2, else rd is 0
        // slt rd, rs, rt
        // xori rd, rd, 1 
        else if (inst_type == "sge") {
        // sge rd, rs, rt sets rd = 1 if rs >= rt, else rd = 0
        // Implemented using slt and xori instructions
        write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42), inst_outfile);
        write_binary(encode_Itype(14, registers[terms[1]], registers[terms[1]], 1), inst_outfile);
        // Update the line numbers for labels due to insertion of multiple instructions
        for (auto& label : instruction_labels) {
            if(label.second > line_number) {
                label.second += 1;
            }
        }
            line_number++;  // Increment line number as two instructions are added
        }
        // sgt $s0, $s1, $s2 # $s0 is 1 if s1 > s2, else s0 is 0 s1 <= s2
        else if (inst_type == "sgt") {
        // sgt rd, rs, rt sets rd = 1 if rs > rt, else rd = 0
        // Implemented using slt by swapping rs and rt
        write_binary(encode_Rtype(0, registers[terms[3]], registers[terms[2]], registers[terms[1]], 0, 42), inst_outfile);
        }
        
        // sle rd, rs, rt   # rd = 1 (rs <= rt), rd = 0 (rs > rt)
        // slt rd, rt, rs   
        // xori rd, rd, 1
        else if (inst_type == "sle") {
        // sle rd, rs, rt sets rd = 1 if rs <= rt, else rd = 0
        // Implemented using slt and xori
        // First, slt is used to set rd if rs > rt
        write_binary(encode_Rtype(0, registers[terms[3]], registers[terms[2]], registers[terms[1]], 0, 42), inst_outfile);
        // Then, xori is used to invert the result, effectively implementing <=
        write_binary(encode_Itype(14, registers[terms[1]], registers[terms[1]], 1), inst_outfile);

        // Update the line numbers for labels due to insertion of multiple instructions
        for (auto& label : instruction_labels) {
            if(label.second > line_number) {
                label.second += 1;
            }
        }
            line_number += 1;  // Increment line number as two instructions are added
        }

        else if (inst_type == "seq") {
        // seq rd, rs, rt sets rd = 1 if rs == rt, else rd = 0
        // Implemented using two slt instructions and a nor instruction
        //slt rd, rs, rt sets rd if rs < rt
        write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42), inst_outfile);
        //slt at, rt, rs sets at if rt < rs (using at as a temporary register)
        write_binary(encode_Rtype(0, registers[terms[3]], registers[terms[2]], 1, 0, 42), inst_outfile);
        // nor rd, rd, at sets rd = 1 if both rs >= rt and rt >= rs, i.e., rs == rt
        write_binary(encode_Rtype(0, registers[terms[1]], 1, registers[terms[1]], 0, 39), inst_outfile);

        // Update the line numbers for labels due to insertion of three instructions
        for (auto& label : instruction_labels) {
            if(label.second > line_number) {
                label.second += 2; // Increment by 2 for each additional instruction
            }
        }
        line_number += 2;  // Increment line number by 2 as three instructions are added
        }

        else if (inst_type == "sne") {
        // sne rd, rs, rt sets rd = 1 if rs != rt, else rd = 0
        // Implemented using two slt instructions and a xor instruction
        // First, slt rd, rs, rt sets rd if rs < rt
        write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42), inst_outfile);
        // Second, slt at, rt, rs sets at if rt < rs (using at as a temporary register)
        write_binary(encode_Rtype(0, registers[terms[3]], registers[terms[2]], 1, 0, 42), inst_outfile);
        // Finally, xor rd, rd, at sets rd = 1 if rs != rt
        write_binary(encode_Rtype(0, registers[terms[1]], 1, registers[terms[1]], 0, 38), inst_outfile);
        // Update the line numbers for labels due to insertion of three instructions
        for (auto& label : instruction_labels) {
            if(label.second > line_number) {
                label.second += 2; // Increment by 2 for each additional instruction
            }
        }
        line_number += 2;
        }
        // Handling of bge pseudoinstruction
        else if (inst_type == "bge") {
            // bge rs, rt, label
            // Update line numbers for labels before calculating the offset
            for (auto& label : instruction_labels) {
                if(label.second > line_number) {
                    label.second += 2;
                }
            }
            line_number += 2; // 2 additional instructions are added
            // Calculate offset for the branch instruction after updating line numbers
            int offset = (instruction_labels[terms[3]] - line_number - 1);
            // Implemented using slt, xori, and bne instructions
            // slt at, rs, rt sets the assembler temporary (at) register if rs < rt
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 1, 0, 42), inst_outfile);
            // xori at, at, 1 inverts the result of slt
            write_binary(encode_Itype(14, 1, 1, 1), inst_outfile);
            // bne at, $0, label
            write_binary(encode_Itype(5, 1, 0, offset), inst_outfile);
        }
        else if (inst_type == "ble") {
            // ble rs, rt, label
            // Update line numbers for labels before calculating the offset
            for (auto& label : instruction_labels) {
                if(label.second > line_number) {
                    label.second += 2;
                }
            }
            line_number += 2; // 2 additional instructions are added
            // Calculate offset for the branch instruction after updating line numbers
            int offset = (instruction_labels[terms[3]] - line_number - 1);
            // Implemented using slt, xori, and bne instructions
            // slt at, rt, rs sets the assembler temporary (at) register if rt < rs
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[1]], 1, 0, 42), inst_outfile);
            // xori at, at, 1 inverts the result of slt
            write_binary(encode_Itype(14, 1, 1, 1), inst_outfile);
            // bne at, $0, label
                write_binary(encode_Itype(5, 1, 0, offset), inst_outfile);            
        }
        else if (inst_type == "bgt") {
            // bgt rs, rt, label
            // Update line numbers for labels before calculating the offset
            for (auto& label : instruction_labels) {
                if(label.second > line_number) {
                    label.second += 1; // Only 1 additional instruction (slt) is added before the branch
                }
            }
            line_number += 1; // 1 additional instruction (slt) is added

            // Calculate offset for the branch instruction after updating line numbers
            int offset = (instruction_labels[terms[3]] - line_number - 1);

            // Implemented using slt and bne instructions
            // slt at, rt, rs sets the assembler temporary (at) register if rt < rs
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[1]], 1, 0, 42), inst_outfile);
            // bne at, $0, label
            write_binary(encode_Itype(5, 1, 0, offset), inst_outfile);
        }
            // Handling of blt pseudoinstruction
        else if (inst_type == "blt") {
            // blt rs, rt, label
            // Update line numbers for labels before calculating the offset
            for (auto& label : instruction_labels) {
                if(label.second > line_number) {
                    label.second += 1; // Only 1 additional instruction (slt) is added before the branch
                }
            }
            line_number += 1; // 1 additional instruction (slt) is added

            // Calculate offset for the branch instruction after updating line numbers
            int offset = (instruction_labels[terms[3]] - line_number - 1);

            // Implemented using slt and bne instructions
            // slt at, rs, rt sets the assembler temporary (at) register if rs < rt
            write_binary(encode_Rtype(0, registers[terms[1]], registers[terms[2]], 1, 0, 42), inst_outfile);
            // bne at, $0, label
            write_binary(encode_Itype(5, 1, 0, offset), inst_outfile);
        }
            // Logical operations
        if (inst_type == "and") {
            // Bitwise AND operation between two registers
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 36), inst_outfile);
        }
        else if (inst_type == "or") {
            // Bitwise OR operation between two registers
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 37), inst_outfile);
        }
        else if (inst_type == "nor") {
            // Bitwise NOR operation between two registers
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 39), inst_outfile);
        }
        else if (inst_type == "xor") {
            // Bitwise XOR operation between two registers
            write_binary(encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 38), inst_outfile);
        }

        // Immediate logical operations
        else if (inst_type == "andi") {
            // Bitwise AND operation between a register and an immediate value
            write_binary(encode_Itype(12, registers[terms[2]], registers[terms[1]], stoi(terms[3])), inst_outfile);
        }
        else if (inst_type == "ori") {
            // Bitwise OR operation between a register and an immediate value
            write_binary(encode_Itype(13, registers[terms[2]], registers[terms[1]], stoi(terms[3])), inst_outfile);
        }
        else if (inst_type == "xori") {
            // Bitwise XOR operation between a register and an immediate value
            write_binary(encode_Itype(14, registers[terms[2]], registers[terms[1]], stoi(terms[3])), inst_outfile);
        }

        // Load Upper Immediate
        else if (inst_type == "lui") {
            // Load an immediate value into the upper 16 bits of a register
            write_binary(encode_Itype(15, 0, registers[terms[1]], stoi(terms[3])), inst_outfile);
        }


        line_number++; //count next line
    }
}

#endif
