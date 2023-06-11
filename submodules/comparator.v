module comparator (
    input [15:0] from_ALU,
    output CC_Z,
    output CC_N
);

// instantiation template
/*
comparator comparator_inst0 (
    .from_ALU(),
    .CC_Z(),
    .CC_N()
);
*/

assign CC_Z <= ~(from_ALU[15] | from_ALU[14] | from_ALU[13] | from_ALU[12] | 
                from_ALU[11] | from_ALU[10] | from_ALU[9] | from_ALU[8] | 
                from_ALU[7] | from_ALU[6] | from_ALU[5] | from_ALU[4] | 
                from_ALU[3] | from_ALU[2] | from_ALU[1] | from_ALU[0]);

assign CC_N <= from_ALU[15];

endmodule