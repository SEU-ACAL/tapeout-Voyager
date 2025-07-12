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
@pytest.mark.smoke
def test_verilator_hello(script_runner, caplog):
  """Test Verilator script hello function."""
  caplog.set_level(logging.INFO)
  
  logging.info("Testing Verilator hello script...")
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "hello", "--debug"], timeout=600)
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
  
  assert "Test is now completed:" in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  logging.info("Verilator hello test completed") 

@pytest.mark.verilator  
@pytest.mark.smoke
def test_verilator_bb_mvin_mvout(script_runner, caplog):
  """Test Verilator script bb_mvin_mvout function."""
  caplog.set_level(logging.INFO)
  
  logging.info("Testing Verilator bb_mvin_mvout script...")
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerVerilatorConfig", "bb_mvin_mvout_multi", "--debug"], timeout=600)
  execution_time = time.time() - start_time
  
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  # Check minimum execution time (e.g., at least 10 seconds for more complex test)
  min_execution_time = 10.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  
  assert "32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47" in result["stdout"], "Mismatch the expected output" # 这里检查输出中是否含有xxx，否则认定为失败
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}" # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  logging.info("Verilator bb_mvin_mvout_multi test completed") 
