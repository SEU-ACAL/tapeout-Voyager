"""
Basic tests using Sardine framework.
Simple script execution tests.
"""

import pytest
import logging
import time
from pathlib import Path


script_dir = Path(__file__).parent.parent.parent

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.smoke
def test_verilator_ctest_mvin_mvout_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_mvin_mvout_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  # Check minimum execution time (e.g., at least 5 seconds)
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
  assert "ACC Test passed: Output matches expected result." in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
  assert "SRAM Test passed: Output matches expected result." in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
  # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  logging.info("Verilator hello test completed") 

@pytest.mark.verilator  
@pytest.mark.buckyball
@pytest.mark.smoke
def test_verilator_ctest_acc_matmul_multicore(script_runner, caplog):
  caplog.set_level(logging.INFO)
  
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "ctest_acc_matmul_multicore", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  # Check minimum execution time (e.g., at least 5 seconds)
  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
  assert "Matmul Done" in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
  # assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  logging.info("Verilator hello test completed") 
