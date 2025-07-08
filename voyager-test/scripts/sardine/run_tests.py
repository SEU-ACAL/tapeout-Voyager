#!/usr/bin/env python3
"""
Simple test runner for Sardine framework.
"""

import sys
import subprocess
from pathlib import Path


def run_pytest(args=None):
  """Run pytest with given arguments."""
  args = args or []
  
  # 确保在正确的目录
  script_dir = Path(__file__).parent
  
  # 构建pytest命令，默认启用并行执行
  cmd = ["python", "-m", "pytest", "-s", "-v", "-n", "auto"] + args
  
  print(f"Running: {' '.join(cmd)}")
  print(f"Working directory: {script_dir}")
  
  # 运行pytest
  try:
    result = subprocess.run(cmd, cwd=script_dir)
    return result.returncode
  except KeyboardInterrupt:
    print("\nTest execution interrupted by user")
    return 1
  except Exception as e:
    print(f"Error running tests: {e}")
    return 1


def main():
  """Main entry point."""
  if len(sys.argv) > 1 and sys.argv[1] in ["-h", "--help"]:
    print("Sardine Test Runner")
    print()
    print("Usage:")
    print("  python run_tests.py [pytest arguments]")
    print()
    print("Examples:")
    print("  python run_tests.py                    # Run all tests in parallel (auto workers)")
    print("  python run_tests.py -m smoke           # Run smoke tests in parallel")
    print("  python run_tests.py -m verilator       # Run verilator tests in parallel")
    print("  python run_tests.py tests/test_basic.py # Run specific file")
    print("  python run_tests.py -v                 # Verbose output")
    print("  python run_tests.py -n 4               # Override to use 4 parallel workers")
    print("  python run_tests.py -n 0               # Disable parallel execution")
    return 0
  
  # 传递所有参数给pytest
  return run_pytest(sys.argv[1:])


if __name__ == "__main__":
  sys.exit(main()) 