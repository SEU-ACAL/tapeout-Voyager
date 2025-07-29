import pytest
import logging
import time
from pathlib import Path


script_dir = Path(__file__).parent.parent.parent
embench_workload_dir = script_dir / ".." / "output" / "workloads" / "embench"

# Define all embench workloads with absolute paths and corresponding IDs
embench_workloads = [
  (f"{embench_workload_dir}/aha-mont64", "aha-mont64"),
  (f"{embench_workload_dir}/edn", "edn"), 
  (f"{embench_workload_dir}/minver", "minver"),
  (f"{embench_workload_dir}/nettle-sha256", "nettle-sha256"),
  # (f"{embench_workload_dir}/qrduino", "qrduino"), # about 50 minutes 
  (f"{embench_workload_dir}/st", "st"),
  # (f"{embench_workload_dir}/wikisort", "wikisort"),
  # (f"{embench_workload_dir}/crc32", "crc32"),
  # (f"{embench_workload_dir}/huffbench", "huffbench"),
  (f"{embench_workload_dir}/nbody", "nbody"),
  # (f"{embench_workload_dir}/nsichneu", "nsichneu"),
  # (f"{embench_workload_dir}/sglib-combined", "sglib-combined"),
  # (f"{embench_workload_dir}/statemate", "statemate"),
  (f"{embench_workload_dir}/cubic", "cubic"),
  (f"{embench_workload_dir}/matmult-int", "matmult-int"),
  (f"{embench_workload_dir}/nettle-aes", "nettle-aes"),
  # (f"{embench_workload_dir}/picojpeg", "picojpeg"),
  (f"{embench_workload_dir}/slre", "slre")
  # (f"{embench_workload_dir}/ud", "ud")
]

# Define configurations to test
configs = [
  "VoyagerVerilatorConfig"
]

@pytest.mark.verilator
@pytest.mark.embench
@pytest.mark.debug
@pytest.mark.parametrize("workload_path,workload_id", embench_workloads, ids=[w[1] for w in embench_workloads])
@pytest.mark.parametrize("config", configs)
def test_embench_workload_debug(script_runner, caplog, workload_path, workload_id, config):
  caplog.set_level(logging.INFO)
  
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", config, workload_path, "--debug"], timeout=60000)
  execution_time = time.time() - start_time
  
  logging.info(f"Workload: {workload_id}, Config: {config}")
  logging.info(f"Workload path: {workload_path}")
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  
  # Check for %Error in output
  if "%Error" in result["stdout"] or "%Error" in result["stderr"]:
    error_msg = "Found %Error in output"
    if "%Error" in result["stdout"]:
      error_msg += f" (stdout): {result['stdout']}"
    if "%Error" in result["stderr"]:
      error_msg += f" (stderr): {result['stderr']}"
    assert False, error_msg
  
  logging.info("test completed")


@pytest.mark.verilator
@pytest.mark.embench
@pytest.mark.parametrize("workload_path,workload_id", embench_workloads, ids=[w[1] for w in embench_workloads])
@pytest.mark.parametrize("config", configs)
def test_embench_workload_fast(script_runner, caplog, workload_path, workload_id, config):
  caplog.set_level(logging.INFO)
  
  start_time = time.time()
  result = script_runner(f"{script_dir}/run-verilator.sh", ["--config", config, workload_path], timeout=60000)
  execution_time = time.time() - start_time
  
  logging.info(f"Workload: {workload_id}, Config: {config}")
  logging.info(f"Workload path: {workload_path}")
  logging.info(f"Execution time: {execution_time:.2f} seconds")
  logging.info(f"Return code: {result['returncode']}")
  logging.info("Script output:")
  logging.info(f"  stdout: {result['stdout']}")
  if result['stderr']:
    logging.info(f"  stderr: {result['stderr']}")

  min_execution_time = 5.0
  assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
  assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  
  # Check for %Error in output
  if "%Error" in result["stdout"] or "%Error" in result["stderr"]:
    error_msg = "Found %Error in output"
    if "%Error" in result["stdout"]:
      error_msg += f" (stdout): {result['stdout']}"
    if "%Error" in result["stderr"]:
      error_msg += f" (stderr): {result['stderr']}"
    assert False, error_msg
  
  logging.info("test completed")
  
# vcs_config = [
#   "VoyagerVcsConfig"
# ]

# @pytest.mark.vcs
# @pytest.mark.embench
# @pytest.mark.parametrize("workload_path,workload_id", embench_workloads, ids=[w[1] for w in embench_workloads])
# @pytest.mark.parametrize("config", vcs_config)
# def test_embench_workload_fast(script_runner, caplog, workload_path, workload_id, config):
#   caplog.set_level(logging.INFO)
  
#   start_time = time.time()
#   result = script_runner(f"{script_dir}/run-vcs.sh", ["--config", config, workload_path], timeout=60000)
#   execution_time = time.time() - start_time
  
#   logging.info(f"Workload: {workload_id}, Config: {config}")
#   logging.info(f"Workload path: {workload_path}")
#   logging.info(f"Execution time: {execution_time:.2f} seconds")
#   logging.info(f"Return code: {result['returncode']}")
#   logging.info("Script output:")
#   logging.info(f"  stdout: {result['stdout']}")
#   if result['stderr']:
#     logging.info(f"  stderr: {result['stderr']}")

#   min_execution_time = 5.0
#   assert execution_time >= min_execution_time, f"Script executed too quickly: {execution_time:.2f}s < {min_execution_time}s"
#   assert result["returncode"] in [0, 1], f"Script failed with unexpected return code: {result['returncode']}"
  
#   # Check for %Error in output
#   if "%Error" in result["stdout"] or "%Error" in result["stderr"]:
#     error_msg = "Found %Error in output"
#     if "%Error" in result["stdout"]:
#       error_msg += f" (stdout): {result['stdout']}"
#     if "%Error" in result["stderr"]:
#       error_msg += f" (stderr): {result['stderr']}"
#     assert False, error_msg
  
#   logging.info("test completed")