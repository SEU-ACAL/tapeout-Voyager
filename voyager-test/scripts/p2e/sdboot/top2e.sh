make 
cd build 
python3 ../../sdboot/../../../../scripts/p2e/toolchain/elf2hex.py sdboot.elf sdboot.hex --remap-to-zero
# sshpass -p '2gPXiEDY' rsync -avz --progress -e 'ssh -p 52123' sdboot.hex  wangzhenyuan@103.221.143.59:/home/wangzhenyuan/project/Tapeout_verification
sshpass -p '2gPXiEDY' rsync -avz --progress -e 'ssh -p 52123' sdboot.hex  wangzhenyuan@103.221.143.59:/home/wangzhenyuan/project12

