'''
Author: ZhiyuanZhao
Description: 
Date: 2021-03-20 15:18:31
LastEditTime: 2021-03-30 13:11:41
'''
new = []
change_seq = []
num_a = 0
content_a = []
len_ram = 16384
fin = []
with open(r"output\firmware.verilog",'r') as rd_file:
    content = rd_file.read()
    content = content.split()
    for data in content:
        if(len(data) == 2):
            new.append(data)
        else:
            content_a.append(eval('0x'+ data[1:9])/4)
            fin.append([])
    print(content_a)
    content_a.append(99999999)
    if len(new) % 4 == 0:
        print("right")
    else:
        print("error")
    for i in range(len(new)):
        if (i + 1) % 4 == 0:
            change_seq.append(new[i]+new[i-1]+new[i-2]+new[i-3])
    #print(change_seq)
    #print(len(change_seq))
    with open(r"output\instr0.verilog", 'w') as wr_file:
        for i in range(len(content)):
            if(len(content[i]) > 2):
                num_a = num_a + 1
                wr_file.write(content[i])
                wr_file.write('\n')
            elif(i - num_a + 1) % 4 == 0:
                fin[num_a-1].append(change_seq[(i - num_a + 1) // 4 - 1])
                wr_file.write(change_seq[(i - num_a + 1) // 4 - 1])
                wr_file.write('\n')
    with open(r"output\instr.verilog", 'w') as wr_file:
        wr_file.write("@00000000\n")
        for i in range(len_ram):
            for j in range(len(content_a)-1):
                if(i >= content_a[j] and i < content_a[j+1]):
                    if(i-content_a[j] >= len(fin[j])):
                        wr_file.write("00000000\n")
                    else:
                        wr_file.write(fin[j][int(i-content_a[j])] + '\n')
    # for i in range(len(content)):
    #     if (len(content[i]) > 2):
    #         num_a = num_a + 1
    #     elif (i - num_a + 1) % 4 == 0:
    #         fin[num_a - 1].append(change_seq[(i - num_a + 1) // 4 - 1])
    num_a = 0
    with open(r"output\instr.coe", 'w') as wr_file:
        wr_file.write("memory_initialization_radix=16; \n")
        wr_file.write("memory_initialization_vector= \n")
        for i in range(len_ram):
            for j in range(len(content_a)-1):
                if(i >= content_a[j] and i < content_a[j+1]):
                    if(i-content_a[j] >= len(fin[j])):
                        wr_file.write("00000000\n")
                    else:
                        wr_file.write(fin[j][int(i-content_a[j])] + '\n')

