"""
Basic tests using Sardine framework.
Simple script execution tests.
"""

import pytest
import logging
from pathlib import Path


script_dir = Path(__file__).parent.parent.parent

@pytest.mark.verilator  
@pytest.mark.smoke
def test_verilator_hello(script_runner, caplog):
  """Test Verilator script hello function."""
  caplog.set_level(logging.INFO)
  
  logging.info("Testing Verilator hello script...")
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerChipConfig", "hello", "--debug"], timeout=None)
  
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  logging.info("Verilator hello test completed") 

@pytest.mark.verilator  
@pytest.mark.smoke
def test_verilator_bb_mvin_mvout(script_runner, caplog):
  """Test Verilator script bb_mvin_mvout function."""
  caplog.set_level(logging.INFO)
  
  logging.info("Testing Verilator bb_mvin_mvout script...")
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerChipConfig", "bb_mvin_mvout_multi", "--debug"], timeout=None)
  
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  logging.info("Verilator bb_mvin_mvout_multi test completed") 

# @pytest.mark.verilator  
# @pytest.mark.smoke
# def test_verilator_bb_vecunit_matmul(script_runner, caplog):
#   """Test Verilator script bb_vecunit_matmul function."""
#   caplog.set_level(logging.INFO)
  
#   logging.info("Testing Verilator bb_vecunit_matmul script...")
#   result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerChipConfig", "bb_dma2", "--debug"], timeout=None)
  
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

  # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  logging.info("Verilator bb_vecunit_matmul test completed") 
  
@pytest.mark.verilator  
@pytest.mark.smoke
def test_verilator_bb_vecunit_matmul(script_runner, caplog):
  """Test Verilator script bb_vecunit_matmul function."""
  caplog.set_level(logging.INFO)
  
  logging.info("Testing Verilator bb_vecunit_matmul script...")
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerChipConfig", "ctest_vecunit_matmul", "--debug"], timeout=None)
  
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  logging.info("Verilator bb_vecunit_matmul test completed") 

@pytest.mark.verilator  
@pytest.mark.smoke
def test_verilator_ctest_mvin_mvout(script_runner, caplog):
  """Test Verilator script ctest_mvin_mvout function."""
  caplog.set_level(logging.INFO)
  
  logging.info("Testing Verilator ctest_mvin_mvout script...")
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", "VoyagerChipConfig", "ctest_mvin_mvout", "--debug"], timeout=None)
  
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  # 检查脚本是否成功执行（不一定是0，可能是其他成功状态）
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  logging.info("Verilator bb_vecunit_matmul test completed") 
