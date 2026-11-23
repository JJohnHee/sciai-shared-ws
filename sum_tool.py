#!/usr/bin/env python3
"""sum_tool.py — 计算 1 到 1,000,000 的整数求和并输出结果。"""


def sum_to(n: int) -> int:
    """计算 1..n 的和（等差数列公式，O(1)）。"""
    return n * (n + 1) // 2


def main() -> None:
    n = 1_000_000
    result = sum_to(n)
    # 交叉验证：用内置 sum 做一次独立计算
    check = sum(range(1, n + 1))
    assert result == check, f"校验失败: {result} != {check}"
    print(f"1 到 {n:,} 的求和结果: {result:,}")
    print(f"校验（内置 sum）：{check:,} -> {'一致' if result == check else '不一致'}")


if __name__ == "__main__":
    main()
