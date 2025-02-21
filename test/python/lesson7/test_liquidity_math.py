import pytest
from .liquidity_math import *

def test_price_to_tick():
    """Test conversion from price to tick index"""
    assert price_to_tick(5000) == 85176
    assert price_to_tick(4545) == 84222
    assert price_to_tick(5500) == 86129

def test_price_to_sqrtp():
    """Test conversion from price to square root price in Q96.96 format"""
    # sqrt(5000) * 2^96
    expected = 1771845812700853782795
    actual = price_to_sqrtp(5000)
    assert abs(actual - expected) < 100

def test_liquidity_calculation():
    """Test liquidity calculation with 1 ETH at 5000 USDC"""
    current_sqrtp = price_to_sqrtp(5000)   # Current price: 5000 USDC/ETH
    lower_sqrtp = price_to_sqrtp(4545)     # Lower bound: 4545 USDC/ETH
    upper_sqrtp = price_to_sqrtp(5500)     # Upper bound: 5500 USDC/ETH
    
    eth_amount = 10**18  # 1 ETH
    
    # Calculate liquidity for ETH (token0)
    liq = liquidity0(eth_amount, current_sqrtp, upper_sqrtp)
    
    # Verify amounts
    amount0 = calc_amount0(liq, current_sqrtp, upper_sqrtp)
    amount1 = calc_amount1(liq, current_sqrtp, lower_sqrtp)
    
    # Check that we get back approximately the same amount of ETH
    assert abs(amount0 - eth_amount) < 100  # Allow small rounding error
    
    # Test symmetry of calculations
    liq2 = liquidity1(amount1, current_sqrtp, lower_sqrtp)
    assert abs(liq - liq2) < 100  # Liquidity should be the same whether calculated from token0 or token1

def test_edge_cases():
    """Test edge cases and boundary conditions"""
    current_sqrtp = price_to_sqrtp(5000)
    
    # Test with zero amounts
    assert liquidity0(0, current_sqrtp, current_sqrtp * 2) == 0
    assert liquidity1(0, current_sqrtp, current_sqrtp * 2) == 0
    
    # Test with equal prices (should handle division by zero case)
    with pytest.raises(ZeroDivisionError):
        liquidity0(10**18, current_sqrtp, current_sqrtp)
    
    with pytest.raises(ZeroDivisionError):
        liquidity1(10**18, current_sqrtp, current_sqrtp)

def test_price_ordering():
    """Test that functions handle price ordering correctly"""
    amount = 10**18
    p1 = price_to_sqrtp(4000)
    p2 = price_to_sqrtp(6000)
    
    # Results should be the same regardless of price order
    liq1 = liquidity0(amount, p1, p2)
    liq2 = liquidity0(amount, p2, p1)
    assert liq1 == liq2
    
    liq3 = liquidity1(amount, p1, p2)
    liq4 = liquidity1(amount, p2, p1)
    assert liq3 == liq4
