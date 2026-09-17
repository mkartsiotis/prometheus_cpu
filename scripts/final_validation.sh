# Final Validation script. This is just a master script that runs all the subscripts
echo -e "Main CPU Validation Testing"
echo -e "\nRunning ADD/SUB tests"
scripts/run_asm_test.sh integrated_tests/add_sub.s 25
echo -e "\nRunning LOGIC tests"
scripts/run_asm_test.sh integrated_tests/logic.s 30
echo -e "\nRunning MEMORY tests"
scripts/run_asm_test.sh integrated_tests/memory.s 130
echo -e "\nRunning BRANCH tests"
scripts/run_asm_test.sh integrated_tests/branch_loop.s 6
echo -e "\nRunning FIBONACCI tests"
scripts/run_asm_test.sh integrated_tests/fibonacci.s 34
echo -e "\nRunning UPPER IMMEDIATE tests"
scripts/run_asm_test.sh integrated_tests/upper_immediate.s 4111
echo -e "Validation script completed"
