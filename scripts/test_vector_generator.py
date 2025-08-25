from bitstring import BitArray
import random

#Functions used in multiple vector generation functions-----------------------------------------------------
"""
Description: Convert Verilog indexes into corrosponding python indexes.
Parameters:
    start_index: The first index in a Verilog signal access
    end_index: The second index in a Verilog signal access
Returns:
    new_start: Corrosponding Python index for first Verilog index
    new_end: Corrosponding Python indexe for second Verilog index
"""
def get_verilog_index(start_index=31, end_index=0):
    new_start = 31-start_index

    #is non-inclusive, so must take one off
    new_end = 32-end_index

    return new_start, new_end

"""
Description: Generate extension for an immediate
Parameters:
    num_ext_bits: Number of bits to extend
    MSB: MSB of the given immediate
    immediate: The immediate itself
Returns:
    An sign extended immediate
"""
def generate_extension(num_ext_bits, MSB, immediate):
    ext =  BitArray(int=-1*MSB, length=num_ext_bits)
    return ext + immediate


"""
Description: Writes a list of vectors to a given file
Parameters:
    full_vector: The list that's to be written to a line of the file
    file: The file that's being written to
Returns: 
    N/A
"""
def write_vec_to_file(full_vector, file):
    for i in range(len(full_vector)):
        file.write(full_vector[i])
        #Don't want space at end
        if (i != len(full_vector) - 1):
            file.write(" ")
    file.write("\n")

"""
Description: Performs an arithemtic right shift
Parameters: 
    num: BitArray number to be shifted
    shift_amt: An unsigned shift amount
Returns:
    shifted_num: The shifted BitArray
"""
def arithmetic_right_shift(num, shift_amt):
    msb = num[0]

    shifted_num = num >> shift_amt

    for i in range(shift_amt):
        shifted_num[i] = msb
    
    return shifted_num

"""
Description: Generates lower and upper bounds for a given testcase
Parameters:
    test_case: The type of range to be calculated
returns:
    lower_range: The lower bound
    upper_range: The upper bound
"""
def generate_int_range(test_case):
    if (test_case == "Random"):
        lower_range = -2**31
        upper_range = 2**31-1
    elif (test_case == "High"):
        lower_range = 2**31
        upper_range = 2**32-1
    elif (test_case == "Negative"):
        lower_range = -2**31
        upper_range = -2**10
    elif (test_case == "Zeros"):
        lower_range = 0
        upper_range = 1
    
    return lower_range, upper_range

#Vector generation functions--------------------------------------------------------------------------------

"""
Description: Generates test vectors for the extension.v module
Parameters:
    vecter_per_op: Number of vectors to produce per opcode
    file: The file to be writing test vectors to
returns: 
    N/A
"""
def extension_vector_gen(vector_per_op, file):
    immSrc = []

    #Create array of valid opCodes
    for i in range(5):
        immSrc.append(BitArray(uint=i, length=3))


    for opCode in immSrc:
        for j in range(vector_per_op):

            full_vector = []

            #Generate Random instrution field
            initial_num = random.randint(-2**24, 2**24-1)
            instr = BitArray(int = initial_num, length = 25)
            full_vector.append(instr.bin)

            #append opCode
            full_vector.append(opCode.bin)

            #I-type instructions
            if (opCode.bin == "000"):
                    
                #Determine intial immediate ([31:20], sign extended)
                start, end = get_verilog_index(31, 20)
                immediate = instr[start:end]

                #Generate extension bits
                expected_result = generate_extension(20, instr[0], immediate)

                #append expected result to test vector
                full_vector.append(expected_result.bin)
                
            #S-type Instructions
            elif (opCode.bin == "001"):

                #Determine initial immediate ([31:25], [11:7])
                start, end = get_verilog_index(31,25)
                immediate = instr[start:end]
                start, end = get_verilog_index(11,7)
                immediate += instr[start:end]

                #Generate extension bits
                expected_result = generate_extension(20, instr[0], immediate)

                #Append to vector
                full_vector.append(expected_result.bin)
                
            #B-type Instructions
            elif (opCode.bin == "010"):

                #Determine initial Immediate ([7], [30:25], [11:8], 0)
                start, end = get_verilog_index(7)
                immediate = BitArray(uint=instr[start], length=1)
                    
                start, end = get_verilog_index(30, 25)
                immediate += instr[start:end]

                start, end = get_verilog_index(11, 8)
                immediate += instr[start:end] + BitArray(uint=0, length=1)

                #Generate expected result
                expected_result = generate_extension(20, instr[0], immediate)
                    
                #Appendd expected result
                full_vector.append(expected_result.bin)
                
            #J-type Instructions
            elif (opCode.bin == "011"):
                    
                #Determine immediate ([19:12], [20], [30:21], 0)
                start, end = get_verilog_index(19, 12)
                immediate = instr[start:end]

                start, end = get_verilog_index(20)
                immediate += BitArray(uint=instr[start], length=1)

                start, end = get_verilog_index(30, 21)
                immediate += instr[start:end] + BitArray(uint=0, length=1)

                #Generate expected result
                expected_result = generate_extension(12, instr[0], immediate)

                #Append expected result
                full_vector.append(expected_result.bin)
                
            #U-type Instructions
            elif(opCode.bin == "100"):
                    
                #Determine immediate ([31:12])
                start, end = get_verilog_index(31, 12)
                immediate = instr[start:end]

                #Special case, add on 12 zeros to end of vector
                ext =  BitArray(int=0, length=12)

                expected_result = immediate + ext

                full_vector.append(expected_result.bin)

            #Write all to file
            write_vec_to_file(full_vector, file)

"""
Description: Generates test vectors for the reduce.v module
Parameters:
    vecter_per_op: Number of vectors to produce per opcode
    file: The file to be writing test vectors to
returns: 
    N/A
"""
def reduce_vector_gen(vector_per_op, file):
    
    #generate control valid control signal
    widthSrc = []

    #Generate all possible inputs for opCode
    for i in range(8):
        widthSrc.append(BitArray(uint=i, length=3))

    for opCode in widthSrc:
        for j in range(vector_per_op):

            full_vector = []

            #Generate Random instrution field
            initial_num = random.randint(-2**31, 2**31-1)
            base_result = BitArray(int = initial_num, length = 32)
            full_vector.append(base_result.bin)

            #append opCode
            full_vector.append(opCode.bin)

            if (opCode.bin == "000"):
                    
                expected_result = base_result
                
            #8-bit signed extension
            elif (opCode.bin == "001"):

                start, end = get_verilog_index(7,0)
                immediate = base_result[start:end]

                expected_result = generate_extension(24, base_result[start], immediate)
                
            elif (opCode.bin == "101"):
                start, end = get_verilog_index(7,0)
                immediate = base_result[start:end]

                expected_result = generate_extension(24, 0, immediate)
                
            elif (opCode.bin == "010"):
                start, end = get_verilog_index(15,0)
                immediate = base_result[start:end]

                expected_result = generate_extension(16, base_result[start], immediate)
                
            elif (opCode.bin == "110"):
                start, end = get_verilog_index(15,0)
                immediate = base_result[start:end]

                expected_result = generate_extension(16, 0, immediate)
                
            else:
                #Don't need to check unused control signals
                continue
            

            full_vector.append(expected_result.bin)

            write_vec_to_file(full_vector, file)

"""
Description: Generates test vectors for the ALU.v module
Parameters:
    vecter_per_op: Number of vectors to produce per opcode
    file: The file to be writing test vectors to
    test_case: what range of randomized inputs are to be generated
returns: 
    N/A
"""
def ALU_vector_gen(vector_per_op, file, test_case="Random"):
    
    #Initialize valid control signals
    ALU_control = []

    #go 9 down to 0, as add and sub are highest opCode
    #Need to set overflow and carry flags (propogate through other test cases)
    for i in range(9, -1, -1):
        ALU_control.append(BitArray(uint=i, length=4))
    
    shift_codes = ["0000", "0001", "0111"]

    #Determine range of test inputs
    lower_range, upper_range = generate_int_range(test_case)

    for opCode in ALU_control:
        for i in range(vector_per_op):
            
            #Create empty vector
            full_vector = []
            full_vector.append(opCode.bin)

            
            #shift amount always less than or equal to 31
            if (opCode.bin in shift_codes):
                initial_num_b = random.randint(0, 31)
                b = BitArray(uint = initial_num_b, length = 32)
            else:
                initial_num_b = random.randint(lower_range, upper_range)
                
            initial_num_a = random.randint(lower_range, upper_range)

            if (test_case == "High"):
                a = BitArray(uint = initial_num_a, length = 32)
                b = BitArray(uint = initial_num_b, length = 32)
            else:
                a = BitArray(int = initial_num_a, length = 32)
                b = BitArray(int = initial_num_b, length = 32)


            full_vector.append(a.bin)
            full_vector.append(b.bin)


            #shift right logical
            if (opCode.bin == "0000"):
                expected_result  = a >> b.uint

                #Set carry and overflow to default
                carry = "0"
                overflow = "0"

            
            #shift right arithmetic
            elif (opCode.bin == "0001"):
                expected_result = arithmetic_right_shift(a, b.uint)

                #Set carry and overflow to default
                carry = "0"
                overflow = "0"


            #AND
            elif (opCode.bin == "0010"):
                expected_result = a & b

                #Set carry and overflow to default
                carry = "0"
                overflow = "0"

            #OR
            elif (opCode.bin == "0011"):
                expected_result = a | b
        
                #Set carry and overflow to default
                carry = "0"
                overflow = "0"

            #XOR
            elif (opCode.bin == "0100"):
                expected_result = a ^ b
           
                #Set carry and overflow to default
                carry = "0"
                overflow = "0"
            
            #SLT
            elif (opCode.bin == "0101"):
                if (a.int < b.int):
                    expected_result = BitArray(int=1, length=32)
                else:
                    expected_result = BitArray(int=0, length=32)
            
                #Set carry and overflow to default
                carry = "0"
                overflow = "0"
            
            #SLTU
            elif (opCode.bin == "0110"):
                if (a.uint < b.uint):
                    expected_result = BitArray(int=1, length=32)
                else:
                    expected_result = BitArray(int=0, length=32)   

                #Set carry and overflow to default
                carry = "0"
                overflow = "0"  

            #Shit left logical
            elif (opCode.bin == "0111"):
                expected_result = a << b.uint 

                #Set carry and overflow to default
                carry = "0"
                overflow = "0"
            
            #Addition
            elif (opCode.bin == "1000"):
                sum_ab = a.int + b.int
                usum_ab = a.uint + b.uint

                expected_result = BitArray(int=sum_ab, length=33)

                #Unique flag calculation
                if (sum_ab > 2**31 - 1 or sum_ab < -2**31):
                    overflow = "1"
                else:
                    overflow = "0"
                
                if (usum_ab > 2**32 - 1):
                    carry = "1"
                else:
                    carry = "0"
                
                expected_result = expected_result[1:]

            #Subtraction
            else:
                dif_ab = a.int - b.int

                expected_result = BitArray(int=dif_ab, length=33)

                #Unique flag calculation
                if (dif_ab > 2**31 - 1 or dif_ab < -2**31):
                    overflow = "1"
                else:
                    overflow = "0"
                
                if (a.uint >= b.uint):
                    carry = "1"
                else:
                    carry = "0"
                
                expected_result = expected_result[1:]

            #N and Z flag calculation
            if (expected_result.int == 0):
                zero = "1"
            else:
                zero = "0"
            
            if (expected_result[0] == True):
                negative = "1"
            else:
                negative = "0"
            
            #Append expected outputs to vector
            full_vector.append(expected_result.bin)
            full_vector.append(negative)
            full_vector.append(zero)
            full_vector.append(carry)
            full_vector.append(overflow)

            #Write vector to file
            write_vec_to_file(full_vector, file)


def main():
    
    filename = "ALU_test_vectors.txt"
    vector_per_op = 200

    with open(filename, "w") as file:
        if (filename == "ALU_test_vectors.txt"):
            ALU_vector_gen(vector_per_op, file, "Random")
        
        if (filename == "ext_unit_test_vectors.txt"):
            extension_vector_gen(vector_per_op, file)
        
        if (filename == "reduce_test_vectors.txt"):
            reduce_vector_gen(vector_per_op, file)
    
    file.close()


if __name__ == "__main__":
    main()