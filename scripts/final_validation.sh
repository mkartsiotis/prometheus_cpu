# Final Validation script. This is just a master script that runs all the subscripts
echo "Main CPU Validation Testing"
scripts/run_asm_test.sh integrated_tests/add_sub.s 25 8
scripts/run_asm_test.sh integrated_tests/logic.s 30 12
scripts/run_asm_test.sh integrated_tests/memory.s 130 10
scripts/run_asm_test.sh integrated_tests/branch_loop.s 6 40
scripts/run_asm_test.sh integrated_tests/fibonacci.s 34 100
scripts/run_asm_test.sh integrated_tests/upper_immediate.s 4111 10
echo "Validation script completed"
