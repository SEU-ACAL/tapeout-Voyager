"""
Basic tests using Sardine framework.
Simple script execution tests.
"""

import pytest
import logging
import time
from pathlib import Path


script_dir = Path(__file__).parent.parent.parent

# @pytest.mark.verilator  
# @pytest.mark.buckyball
# def test_verilator_ctest_mvin_mvout_multicore_fast(script_runner, caplog):
#   caplog.set_level(logging.INFO)
  
#   start_time = time.time()
#   result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_mvin_mvout_multicore"], timeout=600)
#   execution_time = time.time() - start_time
  
#   logging.info(f"Execution time: {execution_time:.2f} seconds")
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

#   # Check minimum execution time (e.g., at least 5 seconds)
#   min_execution_time = 5.0
#   assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
#   assert "ACC Test passed: Output matches expected result." in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
#   assert "SRAM Test passed: Output matches expected result." in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
#   # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
#   logging.info("Verilator hello test completed") 

# @pytest.mark.verilator  
# @pytest.mark.buckyball
# def test_verilator_ctest_acc_matmul_multicore_fast(script_runner, caplog):
#   caplog.set_level(logging.INFO)
  
#   start_time = time.time()
#   result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_acc_matmul_multicore"], timeout=600)
#   execution_time = time.time() - start_time
  
#   logging.info(f"Execution time: {execution_time:.2f} seconds")
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

#   # Check minimum execution time (e.g., at least 5 seconds)
#   min_execution_time = 5.0
#   assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
#   assert "Matmul Done" in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
#   # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
#   logging.info("Verilator hello test completed") 


# @pytest.mark.verilator  
# @pytest.mark.buckyball
# def test_verilator_ctest_bbfp_matmul_multicore_fast(script_runner, caplog):
#   caplog.set_level(logging.INFO)
  
#   start_time = time.time()
#   result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_bbfp_matmul_multicore"], timeout=600)
#   execution_time = time.time() - start_time
  
#   logging.info(f"Execution time: {execution_time:.2f} seconds")
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

#   # Check minimum execution time (e.g., at least 5 seconds)
#   min_execution_time = 5.0
#   assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
#   assert "Matmul Done" in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
#   # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
#   logging.info("Verilator hello test completed") 


# @pytest.mark.verilator  
# @pytest.mark.buckyball
# def test_verilator_ctest_bbfptest_multicore_fast(script_runner, caplog):
#   caplog.set_level(logging.INFO)
  
#   start_time = time.time()
#   result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_bbfptest_multicore"], timeout=600)
#   execution_time = time.time() - start_time
  
#   logging.info(f"Execution time: {execution_time:.2f} seconds")
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

#   # Check minimum execution time (e.g., at least 5 seconds)
#   min_execution_time = 5.0
#   assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
#   assert "288  288  288  288  288  288  288  288  288  288  288  288  288  288  288  288" in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
#   # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
#   logging.info("Verilator hello test completed") 

# @pytest.mark.verilator  
# @pytest.mark.buckyball
# def test_verilator_ctest_vecunit_matmul_multicore_fast(script_runner, caplog):
#   caplog.set_level(logging.INFO)
  
#   start_time = time.time()
#   result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_multicore"], timeout=600)
#   execution_time = time.time() - start_time
  
#   logging.info(f"Execution time: {execution_time:.2f} seconds")
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

#   # Check minimum execution time (e.g., at least 5 seconds)
#   min_execution_time = 5.0
#   assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
#   # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
#   logging.info("Verilator hello test completed") 

# @pytest.mark.verilator  
# @pytest.mark.buckyball
# def test_verilator_ctest_acc_matmul_multicore_fast(script_runner, caplog):
#   caplog.set_level(logging.INFO)
  
#   start_time = time.time()
#   result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_acc_matmul_multicore"], timeout=600)
#   execution_time = time.time() - start_time
  
#   logging.info(f"Execution time: {execution_time:.2f} seconds")
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

#   # Check minimum execution time (e.g., at least 5 seconds)
#   min_execution_time = 5.0
#   assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
#   # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
#   logging.info("Verilator hello test completed") 


@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_ones_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_ones_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_ones test PASSED" in result["stdout"], "vecunit_matmul_ones test did not pass as expected"
  logging.info("Verilator vecunit_matmul_ones multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_identity_random_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_identity_random_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_identity_random test PASSED" in result["stdout"], "vecunit_matmul_identity_random test did not pass as expected"
  logging.info("Verilator vecunit_matmul_identity_random multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_row_col_vector_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_row_col_vector_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_row_col_vector test PASSED" in result["stdout"], "vecunit_matmul_row_col_vector test did not pass as expected"
  logging.info("Verilator vecunit_matmul_row_col_vector multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_col_row_vector_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_col_row_vector_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_col_row_vector test PASSED" in result["stdout"], "vecunit_matmul_col_row_vector test did not pass as expected"
  logging.info("Verilator vecunit_matmul_col_row_vector multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_random1_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_random1_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_random1 test PASSED" in result["stdout"], "vecunit_matmul_random1 test did not pass as expected"
  logging.info("Verilator vecunit_matmul_random1 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_random2_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_random2_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_random2 test PASSED" in result["stdout"], "vecunit_matmul_random2 test did not pass as expected"
  logging.info("Verilator vecunit_matmul_random2 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_random3_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_random3_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_random3 test PASSED" in result["stdout"], "vecunit_matmul_random3 test did not pass as expected"
  logging.info("Verilator vecunit_matmul_random3 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_zero_random_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_zero_random_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_zero_random test PASSED" in result["stdout"], "vecunit_matmul_zero_random test did not pass as expected"
  logging.info("Verilator vecunit_matmul_zero_random multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_16xn_ones_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_16xn_ones_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_16xn_ones test PASSED" in result["stdout"], "vecunit_matmul_16xn_ones test did not pass as expected"
  logging.info("Verilator vecunit_matmul_16xn_ones multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_16xn_random1_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_16xn_random1_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_16xn_random1 test PASSED" in result["stdout"], "vecunit_matmul_16xn_random1 test did not pass as expected"
  logging.info("Verilator vecunit_matmul_16xn_random1 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_16xn_random2_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_16xn_random2_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_16xn_random2 test PASSED" in result["stdout"], "vecunit_matmul_16xn_random2 test did not pass as expected"
  logging.info("Verilator vecunit_matmul_16xn_random2 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_16xn_random3_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_16xn_random3_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_16xn_random3 test PASSED" in result["stdout"], "vecunit_matmul_16xn_random3 test did not pass as expected"
  logging.info("Verilator vecunit_matmul_16xn_random3 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_16xn_zero_random_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_16xn_zero_random_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "vecunit_matmul_16xn_zero_random test PASSED" in result["stdout"], "vecunit_matmul_16xn_zero_random test did not pass as expected"
  logging.info("Verilator vecunit_matmul_16xn_zero_random multicore test completed")



@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_matmul_ones_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_matmul_ones_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 1.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "Test All-ones matrices PASSED" in result["stdout"], "Mismatch the expected output"
  logging.info("Verilator vecunit_matmul_ones test completed") 


@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_mvin_mvout_acc_test_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_mvin_mvout_acc_test_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 1.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "ACC mvin/mvout pressure test PASSED" in result["stdout"], "Mismatch the expected output"
  logging.info("Verilator mvin_mvout_acc_test test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_mvin_mvout_alternate_test_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_mvin_mvout_alternate_test_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 1.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "Alternately mvin/mvout pressure test PASSED" in result["stdout"], "Mismatch the expected output"
  logging.info("Verilator mvin_mvout_alternative_test test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_vecunit_simple_nn_forward_pass_test_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_vecunit_simple_nn_forward_pass_test_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 1.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "Neural Network Test PASSED" in result["stdout"], "Mismatch the expected output"
  logging.info("Verilator vecunit simple nn forward pass test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_bbfp_matmul_random1_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_bbfp_matmul_random1_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "bbfp_matmul_random1 test PASSED" in result["stdout"], "bbfp_matmul_random1 test did not pass as expected"
  logging.info("Verilator bbfp_matmul_random1 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_bbfp_matmul_random2_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_bbfp_matmul_random2_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "bbfp_matmul_random2 test PASSED" in result["stdout"], "bbfp_matmul_random2 test did not pass as expected"
  logging.info("Verilator bbfp_matmul_random2 multicore test completed")

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.debug
def test_verilator_ctest_bbfp_matmul_random3_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_bbfp_matmul_random3_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert "bbfp_matmul_random3 test PASSED" in result["stdout"], "bbfp_matmul_random3 test did not pass as expected"
  logging.info("Verilator bbfp_matmul_random3 multicore test completed")
