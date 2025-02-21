import math

Q96 = 2**96

def price_to_tick(p: float) -> int:
    """Convert price to tick index"""
    return math.floor(math.log(p, 1.0001))

def price_to_sqrtp(p: float) -> int:
    """Convert price to Q96.96 square root price"""
    return int(math.sqrt(p) * Q96)

def liquidity0(amount: int, pa: int, pb: int) -> int:
    """Calculate liquidity for token0 (ETH)
    
    Args:
        amount: Amount of token0 (ETH)
        pa: Square root price at point A in Q96.96 format
        pb: Square root price at point B in Q96.96 format
    
    Returns:
        Liquidity value for token0
    """
    if pa > pb:
        pa, pb = pb, pa
    return (amount * (pa * pb) // Q96) // (pb - pa)

def liquidity1(amount: int, pa: int, pb: int) -> int:
    """Calculate liquidity for token1 (USDC)
    
    Args:
        amount: Amount of token1 (USDC)
        pa: Square root price at point A in Q96.96 format
        pb: Square root price at point B in Q96.96 format
    
    Returns:
        Liquidity value for token1
    """
    if pa > pb:
        pa, pb = pb, pa
    return amount * Q96 // (pb - pa)

def calc_amount0(liq: int, pa: int, pb: int) -> int:
    """Calculate token0 (ETH) amount from liquidity
    
    Args:
        liq: Liquidity value
        pa: Square root price at point A in Q96.96 format
        pb: Square root price at point B in Q96.96 format
    
    Returns:
        Amount of token0
    """
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * Q96 * (pb - pa) // pa // pb)

def calc_amount1(liq: int, pa: int, pb: int) -> int:
    """Calculate token1 (USDC) amount from liquidity
    
    Args:
        liq: Liquidity value
        pa: Square root price at point A in Q96.96 format
        pb: Square root price at point B in Q96.96 format
    
    Returns:
        Amount of token1
    """
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * (pb - pa) // Q96)
