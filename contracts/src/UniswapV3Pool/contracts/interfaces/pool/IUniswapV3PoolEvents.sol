// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;
pragma abicoder v2;

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    // struct for information about a swap
    struct SwapInfo {
        // The address that initiated the swap call, and that received the callback
        address sender;
        // The address that received the output of the swap
        address recipient;
        // The delta of the token0 balance of the pool
        int256 amount0;
        // The delta of the token1 balance of the pool
        int256 amount1;
        // The sqrt(price) of the pool after the swap, as a Q64.96
        uint160 sqrtPriceX96;
        // The liquidity of the pool after the swap
        uint128 liquidity;
        // The log base 1.0001 of price of the pool after the swap
        int24 tick;
    }

    // parent struct for structs used in ShadowMint and ShadowBurn events
    struct LiquidityLocalVars {
        PoolInfo poolInfo;
        PositionDetails positionDetails;
        LiquidityInRangeValues liquidityInRangeValues;
        PositionFeeValues positionFeeValues;
        TickSpaceLiquidity[] tickSpacesLiquidity;
    }
    
    // struct for general token information
    struct TokenInfo {
        // token address
        address tokenAddress;
        // token symbol, e.g. "WETH"
        string tokenSymbol;
        // token name, e.g. "Wrapped Ether"
        string tokenName;
        // token decimals
        uint8 tokenDecimals;
    }

    // struct for general token information
    struct PoolInfo {
        // token0 of the pool
        TokenInfo token0;
        // token1 of the pool
        TokenInfo token1;
        // fee for the pool, expressed in hundredths of a bip, i.e. 1e-6
        uint24 poolFee;
        // Shadow's name for the pool; in format "token0Symbol-token1Symbol poolFee bps"
        string poolName;
        // the tick spacing for the pool
        int24 tickSpacing;
    }

    // struct for general liquidity position information
    struct PositionDetails {
        // owner of the liquidity position; if minted through NonfungiblePositionManager this is msg.sender to mint() function of NonfungiblePositionManager
        address owner;
        // sender of the mint() function on the pool contract; may be different than owner, and will be NonfungiblePositionManager if it was used
        address sender;
        // The lower tick of the position
        int24 tickLower;
        // The upper tick of the position
        int24 tickUpper;
        // The amount of liquidity minted to the position range
        uint128 amount;
        // How much token0 was required for the minted liquidity
        uint256 amount0;
        // How much token1 was required for the minted liquidity
        uint256 amount1;
        // The Shadow positionId generated from keccak256 hash of owner, tickLower, and tickUpper
        bytes32 positionId;
    }

    // struct for liquidity position fee values; helpful for calculating position fees, used in ShadowMint and ShadowBurn events
    struct PositionFeeValues {
        // feeGrowthGlobal0E18 The fee growth global of token0, where feeGrowthGlobal0E18 = (feeGrowthGlobal0X128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthGlobal0E18;
        // feeGrowthGlobal1E18 The fee growth global of token1, where feeGrowthGlobal1E18 = (feeGrowthGlobal1X128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthGlobal1E18;
        // the fee growth outside of the upper tick of token0, where feeGrowthOutsideUpper0E18 = (feeGrowthOutsideUpper0X128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthOutsideUpper0E18;
        // the fee growth outside of the upper tick of token0, where feeGrowthOutsideLower0E18 = (feeGrowthOutsideLower0X128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthOutsideLower0E18;
        // the fee growth inside the tick range as of the last mint/burn/poke of token0, where feeGrowthInside0LastE18 = (feeGrowthInside0LastX128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthInside0LastE18;
        // the fee growth outside of the upper tick of token1, where feeGrowthOutsideUpper1E18 = (feeGrowthOutsideUpper1X128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthOutsideUpper1E18;
        // the fee growth outside of the upper tick of token1, where feeGrowthOutsideLower1E18 = (feeGrowthOutsideLower1X128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthOutsideLower1E18;
        // the fee growth inside the tick range as of the last mint/burn/poke of token1, where feeGrowthInside1LastE18 = (feeGrowthInside1LastX128 * 10**18) >> 128 to allow for downstream data storage with precision
        uint256 feeGrowthInside1LastE18;
    }

    // struct for liquidity in range values, used in ShadowMint and ShadowBurn events
    struct LiquidityInRangeValues {
        // the liquidity in range from the position
        uint128 positionLiquidityInRange;
        // the total liquidity in range before the event
        uint128 totalLiquidityInRangeBefore;
        // the total liquidity in range after the event
        uint128 totalLiquidityInRangeAfter;
    }

    // struct to store the liquidityNet in each tickSpace, where a tickSpace is a group of n=tickSpacing ticks (e.g. if tickSpacing = 10, then a ticksSpace could be [201250, 201260)) 
    struct TickSpaceLiquidity {
        // the lower tick of the tick space, which has a tick size equal to tick spacing (e.g. if tickSpacing = 10, then tickSpace 201250 corresponds to ticks [201250, 201260)
        int24 tickSpace;
        // the liquidityNet of the tick space of size n=tickSpacing; each tick within the tick space has the same liquidityNet
        int128 liquidityNet;
    }
    
    // struct for fees earned, used in ShadowBurn event
    struct FeesEarned {
        // the fees earned of token0
        uint128 token0;
        // the fees earned of token1
        uint128 token1;
    }

    /// @notice Emitted when liquidity is minted for a given position
    /// @param positionDetails struct with information about owner, sender, tick range, liquidity and token amounts, and Shadow positionId
    /// @param positionFeeValues struct with information about fee growth global, fee growth outside, and fee growth inside of token0 and token1, helpful for calculating position fees
    /// @param liquidityInRangeValues struct with information about position liquidity in range, and total liquidity in range before and after the event
    /// @param poolInfo Struct with basic info about the pool
    /// @param tick The log base 1.0001 of price of the pool after the mint
    event ShadowMint(
        PositionDetails positionDetails,
        PositionFeeValues positionFeeValues,
        LiquidityInRangeValues liquidityInRangeValues,
        PoolInfo poolInfo,
        int24 tick
    );

    /// @notice Emitted on liquidity mints and burns; includes liquidityNet on each tick space of the position
    /// @param tickSpaceLower The lower bound of the tick space; each tick space has a tick size of tickSpacing (e.g. if tickSpacing = 10, the tick space with tickSpaceLower of 201250 spans from [201250, 201260))
    /// @param liquidityNet the liquidityNet of the tick space; each tick within the tick space has the same liquidityNet
    /// @param tickSpacing The tick spacing for the pool
    /// @param positionId The Shadow positionId generated from keccak256 hash of owner, tickLower, and tickUpper
    event TickSpacesLiquidity (
        int24 tickSpaceLower,
        int128 liquidityNet,
        int24 tickSpacing,
        bytes32 positionId
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected; if called through NonfungiblePositionManager, will be msg.sender to NonfungiblePositionManager
    /// @param recipient The recipient of the fees that are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event ShadowCollect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param positionDetails struct with information about owner, sender, tick range, liquidity and token amounts, and Shadow positionId
    /// @param feesEarned struct with information about fees earned by the position; subtract feesEarned from amount0 and amount1 to calculate token0 and token1 used to mint position
    /// @param positionFeeValues struct with information about fee growth global, fee growth outside, and fee growth inside of token0 and token1, helpful for calculating position fees
    /// @param liquidityInRangeValues struct with information about position liquidity in range, and total liquidity in range before and after the event
    /// @param poolInfo Struct with basic info about the pool
    /// @param tick The log base 1.0001 of price of the pool after the burn
    event ShadowBurn(
        PositionDetails positionDetails,
        FeesEarned feesEarned,
        PositionFeeValues positionFeeValues,
        LiquidityInRangeValues liquidityInRangeValues,
        PoolInfo poolInfo,
        int24 tick
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param swapInfo Struct with basic info about the swap
    /// @param poolInfo Struct with basic info about the pool
    /// @param feeGrowthGlobal0E18 The fee growth global of token0, where feeGrowthGlobal0E18 = (feeGrowthGlobal0X128 * 10**18) >> 128 to allow for downstream data storage with precision
    /// @param feeGrowthGlobal1E18 The fee growth global of token1, where feeGrowthGlobal1E18 = (feeGrowthGlobal1X128 * 10**18) >> 128 to allow for downstream data storage with precision
    event ShadowSwap(
        SwapInfo swapInfo,
        PoolInfo poolInfo,
        uint256 feeGrowthGlobal0E18,
        uint256 feeGrowthGlobal1E18
    );

    /// @notice Emitted when a tick is crossed
    /// @param tick The index of the tick that was crossed
    /// @param liquidityGross The total position liquidity that references this tick
    /// @param liquidityNet Amount of net liquidity added (subtracted) when tick is crossed from left to right (right to left)
    /// @param feeGrowthOutside0E18 The token0 fee growth per unit of liquidity on the _other_ side of this tick (relative to the current tick). Only has relative meaning, not absolute — the value depends on when the tick is initialized. feeGrowthOutside0E18 = (feeGrowthOutside0X128 * 10**18) >> 128 to allow for downstream data storage with precision
    /// @param feeGrowthOutside1E18 The token1 fee growth per unit of liquidity on the _other_ side of this tick (relative to the current tick). Only has relative meaning, not absolute — the value depends on when the tick is initialized. feeGrowthOutside1E18 = (feeGrowthOutside1X128 * 10**18) >> 128 to allow for downstream data storage with precision
    /// @param tickCumulativeOutside The cumulative tick value on the other side of the tick
    /// @param secondsPerLiquidityOutsideX128 The seconds per unit of liquidity on the _other_ side of this tick (relative to the current tick). Only has relative meaning, not absolute — the value depends on when the tick is initialized
    /// @param secondsOutside The seconds spent on the other side of the tick (relative to the current tick). Only has relative meaning, not absolute — the value depends on when the tick is initialized
    event TickCrossed(
        int24 indexed tick,
        uint128 liquidityGross,
        int128 liquidityNet,
        uint256 feeGrowthOutside0E18,
        uint256 feeGrowthOutside1E18,
        int56 tickCumulativeOutside,
        uint160 secondsPerLiquidityOutsideX128,
        uint32 secondsOutside
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}